import UIKit

class VetAppointmentsViewController: UIViewController {

    private var appointments: [VetAppointment] = []
    private var diagnosesCache: [Int: [Diagnosis]] = [:] // Cache for diagnoses

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
        loadAppointments()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(showUserOptions)
        )
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
        guard let vetId = UserDefaults.standard.object(forKey: "userId") as? Int else {
            showAlert(title: "Error", message: "User info could not be found")
            return
        }
        
        NetworkManager.shared.getVetAppointments(vetId: vetId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let appointments):
                    self.appointments = appointments.map { VetAppointment(from: $0) }
                    self.tableView.reloadData()
                    
                    // Load diagnoses for completed appointments
                    self.loadDiagnosesForCompletedAppointments()
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func loadDiagnosesForCompletedAppointments() {
        let completedAppointments = appointments.filter { $0.status == "COMPLETED" }
        
        for appointment in completedAppointments {
            guard let petId = appointment.pet?.id else { continue }
            
            // Skip if we already have diagnoses for this pet
            if diagnosesCache[petId] != nil { continue }
            
            NetworkManager.shared.getDiagnosesByPetId(petId: petId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let diagnoses):
                    DispatchQueue.main.async {
                        self.diagnosesCache[petId] = diagnoses
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching diagnoses for pet \(petId): \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        print("Showing alert - Title: \(title), Message: \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func showUserOptions() {
        let alert = UIAlertController(title: "Account", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.handleLogout()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "role")
        
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func completeAppointment(_ appointment: VetAppointment) {
        print("Completing appointment ID: \(appointment.id)")
        NetworkManager.shared.completeAppointment(appointmentId: appointment.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedAppointment):
                    print("Successfully completed appointment ID: \(appointment.id)")
                    if let index = self.appointments.firstIndex(where: { $0.id == appointment.id }) {
                        self.appointments[index] = VetAppointment(from: updatedAppointment)
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        
                        // Show diagnosis creation option
                        let alert = UIAlertController(title: "Add Diagnosis", message: "Would you like to add a diagnosis for this appointment?", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Add Diagnosis", style: .default) { [weak self] _ in
                            self?.showDiagnosisViewController(for: appointment)
                        })
                        
                        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
                        
                        self.present(alert, animated: true)
                    }
                case .failure(let error):
                    print("Error completing appointment: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to complete appointment: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showDiagnosisViewController(for appointment: VetAppointment) {
        let diagnosisVC = DiagnosisViewController(appointment: appointment) { [weak self] in
            self?.loadAppointments()
        }
        navigationController?.pushViewController(diagnosisVC, animated: true)
    }
}

extension VetAppointmentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let appointment = appointments[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: appointment.appointmentTime)
        
        var cellText = """
            Pet: \(appointment.pet?.name ?? "Unknown")
            Date: \(dateString)
            Status: \(appointment.status)
            """
        
        // If the appointment is completed, show diagnosis and prescriptions
        if appointment.status == "COMPLETED", let petId = appointment.pet?.id {
            if let diagnoses = diagnosesCache[petId],
               let diagnosis = diagnoses.first(where: { $0.appointmentId == appointment.id }) {
                cellText += "\n\nDiagnosis: \(diagnosis.description)"
                if !diagnosis.notes.isEmpty {
                    cellText += "\nNotes: \(diagnosis.notes)"
                }
                
                if !diagnosis.prescriptions.isEmpty {
                    cellText += "\n\nPrescriptions:"
                    for prescription in diagnosis.prescriptions {
                        cellText += "\n• \(prescription.medicineName)"
                    }
                }
            }
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = cellText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let appointment = appointments[indexPath.row]
        
        if appointment.status == "PENDING" {
            let alert = UIAlertController(title: "Complete Appointment", message: "Would you like to complete this appointment?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Complete", style: .default) { [weak self] _ in
                self?.completeAppointment(appointment)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
}
