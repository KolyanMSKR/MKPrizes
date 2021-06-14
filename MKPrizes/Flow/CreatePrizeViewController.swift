//
//  CreatePrizeViewController.swift
//  MKPrizes
//
//  Created by Mykola Korotun on 12.06.2021.
//

import UIKit

final class CreatePrizeViewController: UIViewController {

    @IBOutlet private weak var prizeNameTextField: UITextField!
    @IBOutlet private weak var prizeCostTextField: UITextField!
    @IBOutlet private weak var createPrizeButton: UIButton!

    private let realmManager = RealmManager()

    private lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Cost is too big",
                                                message: "Cost should be a number in range 1-100",
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        return alertController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

}

private extension CreatePrizeViewController {

    func setupUI() {
        title = "New prize"
        createPrizeButton.setTitleColor(.init(white: 0, alpha: 0.6), for: .disabled)
        createPrizeButton.isEnabled = false

        prizeNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        prizeCostTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @IBAction private func createPrizeAction() {
        if let text = prizeCostTextField.text,
           let name = prizeNameTextField.text,
           let cost = Int(text),
           1...100 ~= cost {

            let prize = Prize(name: name, cost: cost, isSelected: false)
            realmManager.create(prize)

            navigationController?.popViewController(animated: true)
        } else {
            present(alertController, animated: true)
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let name = prizeNameTextField.text,
           let cost = prizeCostTextField.text,
           (name.count > 0 && cost.count > 0) {

            createPrizeButton.isEnabled = true
        } else {
            createPrizeButton.isEnabled = false
        }
    }

}
