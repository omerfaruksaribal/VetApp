import UIKit

class LoginViewController: UIViewController {

    // MARK: - UI Elements
    private let emailField = CustomTextField(placeholder: "Email")
    private let passwordField: CustomTextField = {
        let field = CustomTextField(placeholder: "Password")
        field.isSecureTextEntry = true
        return field
    }()
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .systemBackground
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            emailField, passwordField, loginButton, registerButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Actions
    @objc private func handleLogin() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        Task {
            do {
                let response = try await NetworkService.shared.login(email: email, password: password)
                
                // Save user info
                UserDefaults.standard.set(response.id, forKey: "userId")
                UserDefaults.standard.set(response.role, forKey: "role")
                
                // Navigate to appropriate tab bar controller
                await MainActor.run {
                    let tabBarController: UITabBarController
                    if response.role == "VET" {
                        tabBarController = VetTabBarController()
                    } else {
                        tabBarController = OwnerTabBarController()
                    }
                    tabBarController.modalPresentationStyle = .fullScreen
                    present(tabBarController, animated: true)
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func handleRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
