//
//  VisitHistoryViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class VisitHistoryViewController: UIViewController {

    private var visits: [Visit] = []

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(VisitCell.self, forCellReuseIdentifier: "VisitCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Visit History"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadVisitHistory()
    }

    private func loadVisitHistory() {
        visits = []
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
                                        let visit = Visit(
                                            vetName: "Vet \(diag.id)", // MARK: Temporary soluition
                                            date: String(diag.diagnosedAt.prefix(10)),
                                            diagnosis: diag.description,
                                            prescription: medNames
                                        )
                                        self.visits.append(visit)
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
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertContoller.addAction(.init(title: "OK", style: .default))
        present(alertContoller, animated: true)
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
}

extension VisitHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VisitCell", for: indexPath) as? VisitCell else {
            return UITableViewCell()
        }
        let visit = visits[indexPath.row]
        cell.configure(with: visit)
        return cell
    }
}
