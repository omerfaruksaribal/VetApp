//
//  RegisterViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: - UI Elements
    private let nameTextField = CustomTextField(placeholder: "Name")
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Şifre")
        tf.isSecureTextEntry = true
        tf.textContentType = .oneTimeCode 
        return tf
    }()
    private let phoneTextField = CustomTextField(placeholder: "Phone")

    private let roleSegmentedControl: UISegmentedControl = {
        let items = ["OWNER", "VET"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            nameTextField, emailTextField,
            passwordTextField, phoneTextField,
            roleSegmentedControl, registerButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Action
    @objc private func handleRegister() {
        guard
            let name = nameTextField.text, !name.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let phone = phoneTextField.text, !phone.isEmpty

        else {
            showAlert(title: "Error", message: "Fill all empty fields")
            return
        }
        
        let role = roleSegmentedControl.titleForSegment(at: roleSegmentedControl.selectedSegmentIndex) ?? "OWNER"
        
        let req = RegisterRequest(name: name, email: email, password: password, phone: phone, role: role)

        NetworkManager.shared.register(user: req) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.showAlert(title: "Başarılı", message: "Kayıt başarılı, şimdi giriş yapabilirsiniz.")
                case .failure(let error):
                    self.showAlert(title: "Kayıt Hatası", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    private func navigateToHome(for role: String) {
        let nextVC: UIViewController

        if role == "OWNER" {
            nextVC = OwnerAppointmentsViewController()
        } else if role == "VET" {
            nextVC = VetAppointmentsViewController()
        } else {
            showAlert(title: "Unknown role", message: role)
            return
        }

        let nav = UINavigationController(rootViewController: nextVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
