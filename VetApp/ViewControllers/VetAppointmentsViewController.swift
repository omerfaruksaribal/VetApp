//
//  VetAppointmentsViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class VetAppointmentsViewController: UIViewController {
    private var appointments: [VetAppointment] = [] // Dummy data

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Appointments"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadDummyAppointments()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadDummyAppointments() {
        appointments = [
            VetAppointment(id: 1, petName: "Karabaş", ownerName: "Ali", date: "2025-05-06", status: "PENDING"),
            VetAppointment(id: 2, petName: "Boncuk", ownerName: "Zeynep", date: "2025-05-07", status: "PENDING")
        ]
    }
}

extension VetAppointmentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let app = appointments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(app.petName) - \(app.date) (\(app.status))"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = appointments[indexPath.row]
        let vc = DiagnosisViewController(appointment: selected)
        navigationController?.pushViewController(vc, animated: true)
    }
}
