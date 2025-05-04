//
//  VisitHistoryViewController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//
import UIKit

class VisitHistoryViewController: UIViewController {

    private var visits: [Visit] = [] // Dummy data

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
        loadDummyData()
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

    private func loadDummyData() {
        visits.append(
            Visit(
                vetName: "Dr. Ayşe K.",
                date: "2024-12-15",
                diagnosis: "Kedi gribi",
                prescription: ["Antibiyotik", "Vitamin C"]
            )
        )
        visits.append(
            Visit(
                vetName: "Dr. Mehmet T.",
                date: "2025-01-10",
                diagnosis: "Aşı takibi",
                prescription: ["Aşı A", "Aşı B"]
            )
        )
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
