import UIKit

class OwnerTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let petsVC = UINavigationController(rootViewController: PetsViewController())
        petsVC.tabBarItem = UITabBarItem(title: "Pets", image: UIImage(systemName: "pawprint"), tag: 0)

        let appointmentsVC = UINavigationController(rootViewController: OwnerAppointmentsViewController())
        appointmentsVC.tabBarItem = UITabBarItem(title: "Appointments", image: UIImage(systemName: "calendar"), tag: 1)

        viewControllers = [petsVC, appointmentsVC]
    }
}
