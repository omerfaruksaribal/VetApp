import UIKit

class AddPetViewController: UIViewController {

    var onPetAdded: ((Pet) -> Void)?

    private let nameField = CustomTextField(placeholder: "Pet Name")
    private let speciesField = CustomTextField(placeholder: "Species")
    private let breedField = CustomTextField(placeholder: "Breed")
    private let genderField = CustomTextField(placeholder: "Gender")
    private let birthDateField = CustomTextField(placeholder: "Birth Date (YYYY-MM-DD)")

    private let birthDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        return datePicker
    }()

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

        birthDateField.inputView = birthDatePicker
        birthDateField.delegate = self
        birthDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
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
        // Validate fields
        guard let name = nameField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a pet name")
            return
        }
        
        guard let species = speciesField.text, !species.isEmpty else {
            showAlert(title: "Error", message: "Please enter the species")
            return
        }
        
        guard let breed = breedField.text, !breed.isEmpty else {
            showAlert(title: "Error", message: "Please enter the breed")
            return
        }
        
        guard let gender = genderField.text, !gender.isEmpty else {
            showAlert(title: "Error", message: "Please enter the gender")
            return
        }
        
        guard let birthDate = birthDateField.text, !birthDate.isEmpty else {
            showAlert(title: "Error", message: "Please select a birth date")
            return
        }
        
        guard let ownerId = UserDefaults.standard.object(forKey: "userId") as? Int else {
            showAlert(title: "Error", message: "User info could not be found")
            return
        }

        print("Creating pet with data:")
        print("Name: \(name)")
        print("Species: \(species)")
        print("Breed: \(breed)")
        print("Gender: \(gender)")
        print("Birth Date: \(birthDate)")
        print("Owner ID: \(ownerId)")

        let pet = Pet(
            id: nil,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            registeredAt: nil,
            owner: nil
        )

        NetworkManager.shared.createPet(pet: pet, ownerId: ownerId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let savedPet):
                    print("Successfully created pet with ID: \(savedPet.id ?? -1)")
                    self.onPetAdded?(savedPet)
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Error creating pet: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to create pet: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        birthDateField.text = formatter.string(from: birthDatePicker.date)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddPetViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthDateField {
            return false
        }
        return true
    }
}
