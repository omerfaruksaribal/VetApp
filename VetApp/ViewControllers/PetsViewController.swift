import UIKit

class PetsViewController: UIViewController {

    private var pets: [Pet] = []

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Pets"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupNavigationBar()
        loadPets()

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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPetTapped)
        )
    }

    private func loadPets() {
        let ownerId = UserDefaults.standard.integer(forKey: "userId")

        /* if ownerId == 0 {
            showAlert(title: "Error", message: "User info could not not be decoded.")
            return
        } */

        NetworkManager.shared.getPetsByOwner(ownerId: ownerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPets):
                    self.pets = fetchedPets
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        present(alert, animated: true)
    }

    @objc private func addPetTapped() {
        let vc = AddPetViewController()
        vc.onPetAdded = { [weak self] _ in
            self?.loadPets()
        }
        
        navigationController?.pushViewController(vc, animated: true)
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

extension PetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pet = pets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(pet.name) • \(pet.species) • \(pet.breed)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pet = pets[indexPath.row]
        let detailVC = PetDetailViewController(pet: pet)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
