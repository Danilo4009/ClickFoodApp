import SwiftUI

struct ContentView: View {
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Bem - Vindo")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.top, 40)

                Image("Logo") // Verifique o nome exato no Assets
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
                    // Ação do cadastro
                    print("Cadastrado: \(nome), \(email)")
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
                
                Spacer()
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.black)
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
            .foregroundColor(.black)
            .cornerRadius(8)
            .autocapitalization(.none)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
