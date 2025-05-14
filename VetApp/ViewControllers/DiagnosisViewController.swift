import UIKit

class DiagnosisViewController: UIViewController {

    private let appointment: VetAppointment

    private let diagnosisField = CustomTextField(placeholder: "Diagnosis")
    private let notesField = CustomTextField(placeholder: "Notes")
    private let medicineField = CustomTextField(placeholder: "Medicine (comma-separated)")

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Diagnosis", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(saveDiagnosis), for: .touchUpInside)
        return btn
    }()

    init(appointment: VetAppointment) {
        self.appointment = appointment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diagnosis"
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            diagnosisField, notesField, medicineField, saveButton
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

    @objc private func saveDiagnosis() {
        let description = diagnosisField.text ?? ""
        let notes = notesField.text ?? ""
        let medicineNames = medicineField
            .text?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []

        NetworkManager.shared.createDiagnosis(appointmentId: appointment.id, description: description, notes: notes) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let diagnosis):
                    let group = DispatchGroup()
                    var errorOccured = false

                    for name in medicineNames {
                        group.enter()
                        let prescription = Prescription(
                            id: 0,
                            diagnosisId: diagnosis.id,
                            medicineName: name,
                            dosage: "",
                            instructions: ""
                        )

                        NetworkManager.shared.addPrescription(prescription: prescription) { result in
                            if case .failure(_) = result {
                                errorOccured = true
                            }
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        if errorOccured {
                            self.showAlert(title: "Error", message: "Failed to add all prescriptions")
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }

                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
