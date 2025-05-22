import UIKit

class DiagnosisViewController: UIViewController {

    private let appointment: VetAppointment
    private let onDiagnosisCreated: () -> Void

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

    init(appointment: VetAppointment, onDiagnosisCreated: @escaping () -> Void) {
        self.appointment = appointment
        self.onDiagnosisCreated = onDiagnosisCreated
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

        NetworkManager.shared.createDiagnosis(appointmentId: appointment.id, description: description, notes: notes) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let diagnosis):
                    if medicineNames.isEmpty {
                        self.onDiagnosisCreated()
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    let group = DispatchGroup()
                    var prescriptionErrors: [String] = []
                    var successfulPrescriptions: [String] = []
                    
                    for name in medicineNames {
                        group.enter()
                        NetworkManager.shared.createPrescription(
                            diagnosisId: diagnosis.id,
                            medicineName: name,
                            dosage: "As prescribed",
                            instructions: "Follow doctor's instructions"
                        ) { result in
                            switch result {
                            case .success(let prescription):
                                successfulPrescriptions.append(prescription.medicineName)
                            case .failure(let error):
                                prescriptionErrors.append("\(name): \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        if !prescriptionErrors.isEmpty {
                            var message = ""
                            if !successfulPrescriptions.isEmpty {
                                message += "Successfully added: \(successfulPrescriptions.joined(separator: ", "))\n\n"
                            }
                            message += "Failed to add:\n" + prescriptionErrors.joined(separator: "\n")
                            self.showAlert(title: "Prescription Status", message: message)
                        } else {
                            self.showAlert(title: "Success", message: "Successfully added all prescriptions")
                        }
                        self.onDiagnosisCreated()
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to create diagnosis: \(error.localizedDescription)")
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
