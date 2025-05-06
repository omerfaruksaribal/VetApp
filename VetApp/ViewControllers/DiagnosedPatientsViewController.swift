//
//  DiagnosedPatientsViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class DiagnosedPatientsViewController: UIViewController {

    private var diagnosedList: [DiagnosedPatient] = []

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Patients"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadDummyData()
        loadDiagnosedPatients()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }

    private func loadDummyData() {
        diagnosedList = [
            DiagnosedPatient(petName: "Tarçın", diagnosis: "Cilt enfeksiyonu", prescription: ["Krem A", "Antibiyotik"]),
            DiagnosedPatient(petName: "Fıstık", diagnosis: "İç parazit", prescription: ["Şurup X", "Vitamin"])
        ]
    }

    private func loadDiagnosedPatients() {
        let diagnoses = DummyDataLoader.load("diagnoses", as: [Diagnosis].self)
        let prescriptions = DummyDataLoader.load("prescriptions", as: [Prescription].self)
        let pets = DummyDataLoader.load("pets", as: [Pet].self)

        diagnosedList = diagnoses.map { d in
            let pet = pets.first { $0.id == d.appointmentId }?.name ?? "Unknown"
            let meds = prescriptions.filter { $0.diagnosisId == d.id }.map { $0.medicineName }
            return DiagnosedPatient(petName: pet, diagnosis: d.description, prescription: meds)
        }

        tableView.reloadData()
    }
}

extension DiagnosedPatientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diagnosedList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let patient = diagnosedList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(patient.petName) • \(patient.diagnosis)"
        cell.detailTextLabel?.text = patient.prescription.joined(separator: ", ")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = diagnosedList[indexPath.row]
        let vc = DiagnosisDetailViewController(patient: selected)
        navigationController?.pushViewController(vc, animated: true)
    }
}
