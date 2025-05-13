//
//  VetAppointmentsViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class VetAppointmentsViewController: UIViewController {

    private var appointments: [VetAppointment] = []

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

    private func loadAppointments() {
        let vetId = UserDefaults.standard.integer(forKey: "vetId")

        /* if vetId == 0 {
            showAlert(title: "Error", message: "Could not get veterinary info.")
            return
        } */

        NetworkManager.shared.getAppointmentsForVet(vetId: vetId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appointments):
                    self.appointments = appointments
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "Ok", style: .default))
        present(alertController, animated: true)
    }
}

extension VetAppointmentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let app = appointments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(app.petName) - \(app.appointmentTime) (\(app.status))"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = appointments[indexPath.row]
        let vc = DiagnosisViewController(appointment: selected)
        navigationController?.pushViewController(vc, animated: true)
    }
}
