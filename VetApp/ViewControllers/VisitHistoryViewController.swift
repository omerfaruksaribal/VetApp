import UIKit

class VisitHistoryViewController: UIViewController {
    private var diagnoses: [Diagnosis] = []
    private let petId: Int
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(petId: Int) {
        self.petId = petId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Visit History"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadVisitHistory()

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
    
    private func loadVisitHistory() {
        print("Loading visit history for pet ID: \(petId)")
        NetworkManager.shared.getDiagnosesByPetId(petId: petId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let diagnoses):
                    print("Successfully fetched \(diagnoses.count) diagnoses")
                    self.diagnoses = diagnoses
                    
                    // Verify prescriptions data
                    for diagnosis in diagnoses {
                        print("Diagnosis ID: \(diagnosis.id)")
                        print("Description: \(diagnosis.description)")
                        print("Number of prescriptions: \(diagnosis.prescriptions.count)")
                        for prescription in diagnosis.prescriptions {
                            print("Prescription: \(prescription.medicineName)")
                        }
                    }
                    
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error loading visit history: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to load visit history: \(error.localizedDescription)")
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
}

extension VisitHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diagnoses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let diagnosis = diagnoses[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateString: String
        if let date = ISO8601DateFormatter().date(from: diagnosis.diagnosedAt) {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = diagnosis.diagnosedAt
        }
        
        let prescriptionText = diagnosis.prescriptions.isEmpty ? "No prescriptions" : 
            diagnosis.prescriptions.map { "• \($0.medicineName)" }.joined(separator: "\n")
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
            Date: \(dateString)
            Diagnosis: \(diagnosis.description)
            Notes: \(diagnosis.notes)
            
            Prescriptions:
            \(prescriptionText)
            """
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let diagnosis = diagnoses[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateString: String
        if let date = ISO8601DateFormatter().date(from: diagnosis.diagnosedAt) {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = diagnosis.diagnosedAt
        }
        
        var message = """
            Date: \(dateString)
            Diagnosis: \(diagnosis.description)
            Notes: \(diagnosis.notes)
            
            Prescriptions:
            """
        
        if diagnosis.prescriptions.isEmpty {
            message += "\nNo prescriptions"
        } else {
            for prescription in diagnosis.prescriptions {
                message += "\n\nMedicine: \(prescription.medicineName)"
                message += "\nDosage: \(prescription.dosage)"
                message += "\nInstructions: \(prescription.instructions)"
            }
        }
        
        let alert = UIAlertController(title: "Visit Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
