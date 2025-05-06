//
//  PetsViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class PetsViewController: UIViewController {

    private var pets = DummyDataLoader.load("pets", as: [Pet].self)

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

        // Test verisi
        pets.append(Pet(id: 1, name: "Pamuk", species: "Cat", breed: "Van", gender: "Female", birthDate: "2020-01-01"))
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

    @objc private func addPetTapped() {
        let vc = AddPetViewController()
        vc.onPetAdded = { [weak self] newPet in
            self?.pets.append(newPet)
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
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
}
