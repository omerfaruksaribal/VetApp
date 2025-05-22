import UIKit

class PetListViewController: UIViewController {
    private var pets: [Pet] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPets()
    }
    
    private func setupUI() {
        title = "My Pets"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PetCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Enable swipe actions
        tableView.allowsSelection = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadPets() {
        // Assuming you have the owner ID stored somewhere
        let ownerId = UserDefaults.standard.integer(forKey: "userId")
        
        NetworkManager.shared.getPetsByOwner(ownerId: ownerId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pets):
                    self.pets = pets
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to load pets: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deletePet(at indexPath: IndexPath) {
        let pet = pets[indexPath.row]
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Pet",
            message: "Are you sure you want to delete \(pet.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Call your delete API endpoint here
            NetworkManager.shared.deletePet(petId: pet.id ?? -1) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.pets.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    case .failure(let error):
                        self.showAlert(title: "Error", message: "Failed to delete pet: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PetListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath)
        let pet = pets[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = pet.name
        content.secondaryText = "\(pet.species) - \(pet.breed)"
        cell.contentConfiguration = content
        
        return cell
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.deletePet(at: indexPath)
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // Optional: Add leading swipe actions if needed
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            // Add edit functionality here if needed
            completion(true)
        }
        
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
} 