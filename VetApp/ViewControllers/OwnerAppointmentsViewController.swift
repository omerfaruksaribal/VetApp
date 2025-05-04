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

    @objc private func handleCreateAppointment() {
        let pet = petField.text ?? ""
        let vet = vetField.text ?? ""
        let date = dateField.text ?? ""
        let time = timeField.text ?? ""

        print("📅 Appointment has created:")
        print("Pet: \(pet), Vet: \(vet), Date: \(date), Time: \(time)")

        // API çağrısı backend aktif olunca buraya gelecek
    }
}
