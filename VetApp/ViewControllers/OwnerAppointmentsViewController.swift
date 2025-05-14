import UIKit

class OwnerAppointmentsViewController: UIViewController {

    private let petPicker = UIPickerView()
    private let vetPicker = UIPickerView()

    private var pets: [Pet] = []
    private var vets: [UserResponse] = []

    private var selectedPetId: Int?
    private var selectedVetId: Int?

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

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()

    private let timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        return timePicker
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Book Appointments"
        view.backgroundColor = .systemBackground
        setupLayout()

        /* navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackbutton)
        ) */

        setupFieldsAndPickers()
        loadPickerData()

        let tapGestures = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestures)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(showUserOptions)
        )
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

    private func loadPickerData() {
        let userId = UserDefaults.standard.integer(forKey: "userId")

        NetworkManager.shared.getPetsByOwner(ownerId: userId) { result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self.pets = data
                    self.petPicker.reloadAllComponents()
                }
            }
        }

        NetworkManager.shared.getAllVets { result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self.vets = data
                    self.vetPicker.reloadAllComponents()
                }
            }
        }
    }

    private func setupFieldsAndPickers() {
        dateField.inputView = datePicker
        timeField.inputView = timePicker
        petField.inputView = petPicker
        vetField.inputView = vetPicker

        datePicker.tintColor = .clear
        timePicker.tintColor = .clear
        petField.tintColor = .clear
        vetField.tintColor = .clear

        dateField.delegate = self
        timeField.delegate = self
        petField.delegate = self
        vetField.delegate = self

        petPicker.delegate = self
        petPicker.dataSource = self

        vetPicker.delegate = self
        vetPicker.dataSource = self

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)


    }

    @objc private func handleCreateAppointment() {
        guard
            let date = dateField.text,
            let time = timeField.text,
            let petId = self.selectedPetId,
            let vetId = self.selectedVetId
        else {
            showAlert(title: "Missing", message: "Fill all missing fields")
            return
        }

        let datetime = "\(date)T\(time)"
        let request = CreateAppointmentRequest(petId: petId, vetId: vetId, appointmentTime: datetime)

        NetworkManager.shared.createAppointment(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.petField.text = ""
                    self.vetField.text = ""
                    self.dateField.text = ""
                    self.timeField.text = ""
                    self.showAlert(title: "Success", message: "Appointment created successfully") {
                        self.tabBarController?.selectedIndex = 0
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func handleBackbutton() {
        tabBarController?.selectedIndex = 0
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateField.text = formatter.string(from: datePicker.date)
    }

    @objc private func timeChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeField.text = formatter.string(from: timePicker.date)
    }

    private func showAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { _ in
            onOK?()
        })
        present(alert, animated: true)
    }

    @objc private func showUserOptions() {
        let alert = UIAlertController(title: "Account", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.handleLogout()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "role")

        // LoginViewController'a yönlendirme
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }


}

extension OwnerAppointmentsViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dateField || textField == timeField || textField == petField || textField == vetField {
            return false
        }
        return true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == petPicker { return pets.count }
        if pickerView == vetPicker { return vets.count }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == petPicker { return pets[row].name }
        if pickerView == vetPicker { return vets[row].name }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == petPicker {
            let selected = pets[row]
            petField.text = selected.name
            selectedPetId = selected.id
        }
        if pickerView == vetPicker {
            let selected = vets[row]
            vetField.text = selected.name
            selectedVetId = selected.id
        }
    }
}
