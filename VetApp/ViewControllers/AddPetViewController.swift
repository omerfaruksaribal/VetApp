//
//  AddPetViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class AddPetViewController: UIViewController {

    var onPetAdded: ((Pet) -> Void)?

    private let nameField = CustomTextField(placeholder: "Pet Name")
    private let speciesField = CustomTextField(placeholder: "Species")
    private let breedField = CustomTextField(placeholder: "Breed")
    private let genderField = CustomTextField(placeholder: "Gender")
    private let birthDateField = CustomTextField(placeholder: "Birth Date (YYYY-MM-DD)")

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(savePet), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Pet"
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            nameField, speciesField, breedField, genderField, birthDateField, saveButton
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

    @objc private func savePet() {
        let newPet = Pet(
            id: 1,
            name: nameField.text ?? "",
            species: speciesField.text ?? "",
            breed: breedField.text ?? "",
            gender: genderField.text ?? "",
            birthDate: birthDateField.text ?? ""
        )
        LocalDataWriter.append("pets", item: newPet) // <- Custom file writer helper
        onPetAdded?(newPet)
        navigationController?.popViewController(animated: true)
    }
}
