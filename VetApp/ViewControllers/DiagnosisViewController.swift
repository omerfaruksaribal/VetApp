//
//  DiagnosisViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
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
        let diagnosis = Diagnosis(
            id: UUID().hashValue,
            appointmentId: appointment.id,
            description: diagnosisField.text ?? "",
            diagnosedAt: "2025-05-05T10:00:00",
            notes: notesField.text ?? ""
        )
        LocalDataWriter.append("diagnoses", item: diagnosis)

        let meds = medicineField.text?.components(separatedBy: ",") ?? []
        for med in meds {
            let prescription = Prescription(
                id: UUID().hashValue,
                diagnosisId: diagnosis.id,
                medicineName: med.trimmingCharacters(in: .whitespaces),
                dosage: "",
                instructions: ""
            )
            LocalDataWriter.append("prescriptions", item: prescription)
        }
        navigationController?.popViewController(animated: true)
    }
}
