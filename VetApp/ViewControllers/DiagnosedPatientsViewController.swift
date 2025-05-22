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
        loadDiagnosedPatients()

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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }

    private func loadDiagnosedPatients() {
        diagnosedList = []
        guard let vetId = UserDefaults.standard.object(forKey: "userId") as? Int else {
            print("Error: Could not get vetId from UserDefaults")
            showAlert(title: "Error", message: "User info could not be found")
            return
        }

        print("Loading diagnosed patients for vet ID: \(vetId)")
        NetworkManager.shared.getVetAppointments(vetId: vetId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let appointments):
                print("Successfully fetched \(appointments.count) appointments")
                let group = DispatchGroup()
                
                // Only process completed appointments
                let completedAppointments = appointments.filter { $0.status == "COMPLETED" }
                print("Found \(completedAppointments.count) completed appointments")
                
                for appointment in completedAppointments {
                    group.enter()
                    let petId = appointment.pet.id
                    print("Fetching diagnoses for pet ID: \(petId)")
                    
                    NetworkManager.shared.getDiagnosesByPetId(petId: petId) { diagResult in
                        switch diagResult {
                        case .success(let diagnoses):
                            print("Found \(diagnoses.count) diagnoses for pet ID: \(petId)")
                            if !diagnoses.isEmpty {
                                for diag in diagnoses {
                                    group.enter()
                                    print("Fetching prescriptions for diagnosis ID: \(diag.id)")
                                    NetworkManager.shared.getPrescriptionsByDiagnosisId(diag.id) { presResult in
                                        switch presResult {
                                        case .success(let prescriptions):
                                            print("Found \(prescriptions.count) prescriptions for diagnosis ID: \(diag.id)")
                                            let medNames = prescriptions.map { $0.medicineName }
                                            let diagnosed = DiagnosedPatient(
                                                petName: appointment.pet.name,
                                                diagnosis: diag.description,
                                                prescription: medNames
                                            )
                                            self.diagnosedList.append(diagnosed)
                                        case .failure(let error):
                                            print("Error fetching prescriptions: \(error.localizedDescription)")
                                            // If prescriptions are missing, still add the diagnosis
                                            if error.localizedDescription.contains("missing") {
                                                let diagnosed = DiagnosedPatient(
                                                    petName: appointment.pet.name,
                                                    diagnosis: diag.description,
                                                    prescription: []
                                                )
                                                self.diagnosedList.append(diagnosed)
                                            }
                                        }
                                        group.leave()
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Error fetching diagnoses: \(error.localizedDescription)")
                            // Don't show error if there are no diagnoses yet
                            if !error.localizedDescription.contains("missing") {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Error", message: "Failed to load diagnoses: \(error.localizedDescription)")
                                }
                            }
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("Finished loading all data. Total diagnosed patients: \(self.diagnosedList.count)")
                    if self.diagnosedList.isEmpty {
                        self.showAlert(title: "No Patients", message: "You don't have any diagnosed patients yet.")
                    }
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Error fetching appointments: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to load appointments: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
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
