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
        let ownerId = UserDefaults.standard.integer(forKey: "userId")

        NetworkManager.shared.getPetsByOwner(ownerId: ownerId) { petResult in
            switch petResult {
            case .success(let pets):
                let group = DispatchGroup()

                for pet in pets {
                    group.enter()
                    NetworkManager.shared.getDiagnosesByPetId(pet.id ?? 0) { diagResult in
                        switch diagResult {
                        case .success(let diagnoses):
                            for diag in diagnoses {
                                group.enter()
                                NetworkManager.shared.getPrescriptionsByDiagnosisId(diag.id) { presResult in
                                    switch presResult {
                                    case .success(let prescriptions):
                                        let medNames = prescriptions.map { $0.medicineName }
                                        let diagnosed = DiagnosedPatient(
                                            petName: pet.name,
                                            diagnosis: diag.description,
                                            prescription: medNames
                                        )
                                        self.diagnosedList.append(diagnosed)
                                    case .failure(_): break
                                    }
                                    group.leave()
                                }
                            }
                        case .failure(_): break
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Hata", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertContoller.addAction(.init(title: "OK", style: .default))
        present(alertContoller, animated: true)
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

        // LoginViewController
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
