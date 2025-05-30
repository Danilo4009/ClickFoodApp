import SwiftUI

// MARK: - MODELO DE PRODUTO
struct Produto: Identifiable, Hashable {
    let id = UUID()
    let nome: String
    let preco: Double
    let descricao: String
    let categoria: String
    let imagemNome: String
}

// MARK: - CARRINHO (SIMPLES)
class CartManager: ObservableObject {
    @Published var itens: [Produto] = []

    func adicionar(_ produto: Produto) {
        itens.append(produto)
    }

    func remover(_ produto: Produto) {
        itens.removeAll { $0.id == produto.id }
    }

    func total() -> Double {
        itens.reduce(0) { $0 + $1.preco }
    }
    
    func limpar() {
        itens.removeAll()
    }
}

// MARK: - TELA DE PRODUTOS ESTILO IFOOD
struct ProductsView: View {
    let todosProdutos: [Produto]

    @State private var busca = ""
    @State private var categoriaSelecionada: String? = nil

    @EnvironmentObject var cartManager: CartManager

    var categorias: [String] {
        Array(Set(todosProdutos.map { $0.categoria })).sorted()
    }

    var produtosFiltrados: [Produto] {
        todosProdutos.filter {
            (categoriaSelecionada == nil || $0.categoria == categoriaSelecionada) &&
            (busca.isEmpty || $0.nome.localizedCaseInsensitiveContains(busca))
        }
    }

    let colunas = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            // Busca
            TextField("Buscar alimentos...", text: $busca)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding([.horizontal, .top])

            // Categorias
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { categoriaSelecionada = nil }) {
                        Text("Todos")
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(categoriaSelecionada == nil ? Color.red : Color.gray.opacity(0.2))
                            .foregroundColor(categoriaSelecionada == nil ? .white : .black)
                            .cornerRadius(15)
                    }

                    ForEach(categorias, id: \.self) { categoria in
                        Button(action: { categoriaSelecionada = categoria }) {
                            Text(categoria)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(categoriaSelecionada == categoria ? Color.red : Color.gray.opacity(0.2))
                                .foregroundColor(categoriaSelecionada == categoria ? .white : .black)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Grid de produtos
            ScrollView {
                LazyVGrid(columns: colunas, spacing: 20) {
                    ForEach(produtosFiltrados, id: \.self) { produto in
                        VStack(alignment: .leading) {
                            Image(produto.imagemNome)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(10)

                            Text(produto.nome)
                                .font(.headline)

                            Text(produto.descricao)
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack {
                                Text(String(format: "R$ %.2f", produto.preco))
                                    .font(.subheadline)
                                    .bold()

                                Spacer()

                                Button(action: {
                                    cartManager.adicionar(produto)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Cardápio")
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            NavigationLink {
                CartView()
                    .environmentObject(cartManager)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart")
                        .font(.title2)
                        .foregroundColor(.red)

                    if !cartManager.itens.isEmpty {
                        Text("\(cartManager.itens.count)")
                            .font(.caption2).bold()
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                }
            }
        }
            }
        }
    


// MARK: - TELA DO CARRINHO
struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var navegarParaPagamento = false

    var body: some View {
        VStack {
            if cartManager.itens.isEmpty {
                Text("Carrinho vazio")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(cartManager.itens, id: \.id) { produto in
                        HStack {
                            Text(produto.nome)
                            Spacer()
                            Text(String(format: "R$ %.2f", produto.preco))
                            Button(action: {
                                cartManager.remover(produto)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "R$ %.2f", cartManager.total()))
                        .font(.headline)
                }
                .padding()

                Button(action: {
                    navegarParaPagamento = true
                }) {
                    Text("Finalizar Pedido")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Carrinho")
        .navigationDestination(isPresented: $navegarParaPagamento) {
            PaymentView()
                .environmentObject(cartManager)
        }
    }
}

// MARK: - TELA DE PAGAMENTO
struct PaymentView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var metodoPagamento = "Cartão de Crédito"
    @State private var navegarParaTracking = false

    let metodos = ["Cartão de Crédito", "Pix", "Boleto", "Dinheiro"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Escolha o método de pagamento")
                .font(.title2)
                .padding(.top)

            Picker("Método de pagamento", selection: $metodoPagamento) {
                ForEach(metodos, id: \.self) { metodo in
                    Text(metodo)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()

            Spacer()

            Button(action: {
                // Aqui você pode adicionar lógica real de pagamento
                // Ao concluir, navega para tracking
                navegarParaTracking = true
            }) {
                Text("Concluir Pagamento")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Pagamento")
        .navigationDestination(isPresented: $navegarParaTracking) {
            TrackingView()
                .environmentObject(cartManager)
        }
    }
}

// MARK: - TELA DE ACOMPANHAMENTO DE PEDIDO
struct TrackingView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var etapa = 0
    @State private var timer: Timer? = nil

    let etapas = [
        "Pedido sendo preparado...",
        "Pedido pronto!",
        "Saiu para entrega",
        "Pedido chegou! Bom apetite!"
    ]

    var body: some View {
        VStack(spacing: 40) {
            Text("Status do Pedido")
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)

            Text(etapas[etapa])
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Image(systemName: statusIcon())
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)

            Spacer()

            if etapa == etapas.count - 1 {
                Button(action: {
                    cartManager.limpar()
                }) {
                    Text("Finalizar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            iniciarTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .navigationBarBackButtonHidden(true)
    }

    func iniciarTimer() {
        etapa = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            if etapa < etapas.count - 1 {
                etapa += 1
            } else {
                timer?.invalidate()
            }
        }
    }

    func statusIcon() -> String {
        switch etapa {
        case 0: return "clock.fill"
        case 1: return "checkmark.seal.fill"
        case 2: return "scooter"
        case 3: return "house.fill"
        default: return "questionmark"
        }
    }
}

// MARK: - TELA DE CADASTRO (COM NAVEGAÇÃO)
struct ContentView: View {
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var mostrarAlerta = false
    @State private var navegarParaProdutos = false

    let produtos = [
        Produto(nome: "Hambúrguer", preco: 24.90, descricao: "Pão, carne, queijo e salada", categoria: "Lanches", imagemNome: "burger"),
        Produto(nome: "Pizza Margherita", preco: 39.90, descricao: "Molho, mussarela e manjericão", categoria: "Lanches", imagemNome: "pizza"),
        Produto(nome: "Refrigerante", preco: 6.00, descricao: "350ml gelado", categoria: "Bebidas", imagemNome: "refrigerante"),
        Produto(nome: "Açaí", preco: 14.00, descricao: "Tigela 300ml com banana", categoria: "Sobremesas", imagemNome: "acai"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Bem - Vindo")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.top, 40)

                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 10)

                Text("Cadastre-se")
                    .font(.title2)
                    .foregroundColor(.gray)

                VStack(spacing: 20) {
                    CustomTextField(placeholder: "Nome", text: $nome)
                    CustomTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                    CustomSecureField(placeholder: "Senha", text: $senha)
                }
                .padding(.horizontal, 30)

                Button(action: {
                    mostrarAlerta = true
                }) {
                    Text("Cadastrar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .alert("Cadastro realizado!", isPresented: $mostrarAlerta) {
                    Button("OK") {
                        navegarParaProdutos = true
                    }
                }

                Spacer()
            }
            .navigationDestination(isPresented: $navegarParaProdutos) {
                ProductsView(todosProdutos: produtos)
                    .environmentObject(CartManager())
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - CAMPOS DE TEXTO CUSTOMIZADOS
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .autocapitalization(.none)
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CartManager())
    }
}
