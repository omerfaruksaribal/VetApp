//
//  DiagnosisDetailViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
import UIKit

class DiagnosisDetailViewController: UIViewController {

    private let patient: DiagnosedPatient

    private let titleLabel = UILabel()
    private let diagnosisLabel = UILabel()
    private let prescriptionLabel = UILabel()

    init(patient: DiagnosedPatient) {
        self.patient = patient
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Diagnosis Details"
        view.backgroundColor = .systemBackground
        setupUI()
        populateData()
    }

    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        diagnosisLabel.font = UIFont.systemFont(ofSize: 18)
        prescriptionLabel.font = UIFont.systemFont(ofSize: 18)
        prescriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, diagnosisLabel, prescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func populateData() {
        titleLabel.text = "🐾 \(patient.petName)"
        diagnosisLabel.text = "Diagnosis: \(patient.diagnosis)"
        prescriptionLabel.text = "Prescription: \(patient.prescription.joined(separator: ", "))"
    }
}
