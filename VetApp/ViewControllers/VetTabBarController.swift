import UIKit

class VetTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let todayVC = UINavigationController(rootViewController: VetAppointmentsViewController())
        todayVC.tabBarItem = UITabBarItem(title: "Appointments", image: UIImage(systemName: "stethoscope"), tag: 0)

        let patientsVC = UINavigationController(rootViewController: DiagnosedPatientsViewController())
        patientsVC.tabBarItem = UITabBarItem(title: "Patients", image: UIImage(systemName: "person.3.fill"), tag: 1)

        viewControllers = [todayVC, patientsVC]
    }
}
