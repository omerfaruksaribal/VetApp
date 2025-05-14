import UIKit

class PetDetailViewController: UIViewController {

    private let pet: Pet

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

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }
}
