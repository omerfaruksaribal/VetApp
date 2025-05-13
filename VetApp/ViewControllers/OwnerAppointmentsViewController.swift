//
//  OwnerAppointmentsViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class OwnerAppointmentsViewController: UIViewController {
    private let petField = CustomTextField(placeholder: "Pet Name")
    private let vetField = CustomTextField(placeholder: "Vet Name")
    private let dateField = CustomTextField(placeholder: "Appointment Date (YYYY-MM-DD)")
    private let timeField = CustomTextField(placeholder: "Time (e.g., 14:00)")

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle( "Create Appointment", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCreateAppointment), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Book Appointments"
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            petField, vetField, dateField, timeField, createButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }


    @objc private func handleCreateAppointment() {
        guard let petName = petField.text,
              let vetName = vetField.text,
              let date = dateField.text,
              let time = timeField.text else {
            showAlert(title: "Missing", message: "Fill all empty fields!")
            return
        }

        let datetime = "\(date)T\(time)"

        let ownerId = UserDefaults.standard.integer(forKey: "userId")

        /* if ownerId == 0 {
            showAlert(title: "Error", message: "User info could not not be decoded.")
            return
        } */

        NetworkManager.shared.getPetsByOwner(ownerId: ownerId) { petResult in
            switch petResult {
            case .success(let pets):
                guard let petId = pets.first(where: { $0.name == petName })?.id else {
                    self.showAlert(title: "Error", message: "Could not find pet!")
                    return
                }

                NetworkManager.shared.getAllVets { vetResult in
                    switch vetResult {
                    case .success(let vets):
                        guard let vetId = vets.first(where: { $0.name == vetName })?.id else {
                            self.showAlert(title: "Error", message: "Could not find vet!")
                            return
                        }

                        let appointmentRequest = CreateAppointmentRequest(
                            petID: petId,
                            vetID: vetId,
                            appointmentTime: datetime
                        )

                        NetworkManager.shared.createAppointment(request: appointmentRequest) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(_):
                                    self.showAlert(title: "Success", message: "Appointment Created Successfully")
                                case .failure(let error):
                                    self.showAlert(title: "Error", message: error.localizedDescription)
                                }
                            }
                        }

                    case .failure(let error):
                        self.showAlert(title: "Vet Error", message: error.localizedDescription)
                    }
                }

            case .failure(let error):
                self.showAlert(title: "Pet Error", message: error.localizedDescription)
            }
        }
    }
}
