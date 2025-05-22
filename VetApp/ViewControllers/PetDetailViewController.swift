import UIKit

class PetDetailViewController: UIViewController {
    private let pet: Pet
    private var appointments: [VetAppointment] = []
    private var diagnoses: [Diagnosis] = []
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    init(pet: Pet) {
        self.pet = pet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = pet.name
        view.backgroundColor = .systemBackground
        setupUI()
        loadData()
    }

    private func setupUI() {
        let nameLabel = makeLabel("Name: \(pet.name)")
        let speciesLabel = makeLabel("Species: \(pet.species)")
        let breedLabel = makeLabel("Breed: \(pet.breed)")
        let genderLabel = makeLabel("Gender: \(pet.gender)")
        let birthDateLabel = makeLabel("Birth Date: \(pet.birthDate)")

        let stack = UIStackView(arrangedSubviews: [
            nameLabel, speciesLabel, breedLabel, genderLabel, birthDateLabel
        ])

        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            tableView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }
    
    private func loadData() {
        guard let petId = pet.id else {
            showAlert(title: "Error", message: "Pet ID not found")
            return
        }
        
        // Load appointments for this pet
        NetworkManager.shared.getAppointmentsByPetId(petId: petId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let appointments):
                self.appointments = appointments.map { VetAppointment(from: $0) }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error loading appointments: \(error.localizedDescription)")
            }
        }
        
        // Load diagnoses
        NetworkManager.shared.getDiagnosesByPetId(petId: petId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let diagnoses):
                self.diagnoses = diagnoses
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error loading diagnoses: \(error.localizedDescription)")
                // Don't show error to user if there are no diagnoses yet
                if error.localizedDescription.contains("missing") {
                    print("No diagnoses found for pet ID: \(petId)")
                } else {
                    self.showAlert(title: "Error", message: "Failed to load diagnoses: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PetDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Appointments" : "Diagnoses"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? appointments.count : diagnoses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            let appointment = appointments[indexPath.row]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: appointment.appointmentTime)
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = """
                Date: \(dateString)
                Status: \(appointment.status)
                """
        } else {
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
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = """
                Date: \(dateString)
                Diagnosis: \(diagnosis.description)
                Notes: \(diagnosis.notes)
                """
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let diagnosis = diagnoses[indexPath.row]
            var message = """
                Date: \(diagnosis.diagnosedAt)
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
}
