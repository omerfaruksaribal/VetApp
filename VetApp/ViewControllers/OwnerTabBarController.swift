//
//  OwnerTabBarController.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 4.05.2025.
//

import UIKit

class OwnerTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let petsVC = UINavigationController(rootViewController: PetsViewController())
        petsVC.tabBarItem = UITabBarItem(title: "Pets", image: UIImage(systemName: "pawprint"), tag: 0)

        let appointmentsVC = UINavigationController(rootViewController: OwnerAppointmentsViewController())
        appointmentsVC.tabBarItem = UITabBarItem(title: "Appointments", image: UIImage(systemName: "calendar"), tag: 1)

        let historyVC = UINavigationController(rootViewController: VisitHistoryViewController())
        historyVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "doc.plaintext"), tag: 2)

        viewControllers = [petsVC, appointmentsVC, historyVC]
    }
}
