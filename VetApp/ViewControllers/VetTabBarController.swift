import UIKit

class VetTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let todayVC = UINavigationController(rootViewController: VetAppointmentsViewController())
        todayVC.tabBarItem = UITabBarItem(title: "Appointments", image: UIImage(systemName: "stethoscope"), tag: 0)

        viewControllers = [todayVC]
    }
}
