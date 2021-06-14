//
//  PrizesViewController.swift
//  MKPrizes
//
//  Created by Mykola Korotun on 12.06.2021.
//

import UIKit
import RealmSwift

final class PrizesViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet private weak var prizesTableView: UITableView!

    private let realmManager = RealmManager()
    private var selectedPrizes = [Prize]()
    private var itemsToken: NotificationToken?

    private var prizes: [Prize] {
        realmManager.fetchAll()
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        observeDeletingPrizes()
        deselectAllPrizes()
        setupUI()
    }

    deinit {
        itemsToken?.invalidate()
    }

}

//MARK: - Private methods
private extension PrizesViewController {

    @objc private func createPrize() {
        if let createPrizeVC = R.storyboard.main.createPrizeViewController() {
            navigationController?.pushViewController(createPrizeVC, animated: true)
        }
    }

    private func setupUI() {
        setupTableView()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createPrize))
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.backButtonTitle = "Back"
        title = "0"
    }

    private func setupTableView() {
        prizesTableView.register(R.nib.prizeTableViewCell)
        prizesTableView.allowsSelectionDuringEditing = true
        prizesTableView.dataSource = self
        prizesTableView.delegate = self
    }

    private func deselectAllPrizes() {
        prizes.forEach {
            if $0.isSelected {
                let dict: [String: Any?] = ["isSelected": false]
                realmManager.update($0, with: dict)
            }
        }
    }

    private func observeDeletingPrizes() {
        itemsToken = realmManager.observeUpdateChanges(type: Prize.self, { [weak self] result in
            switch result {

            case .initial(_):
                self?.prizesTableView.reloadData()

            case .update(_, deletions: let deletions, insertions: let insertions, _):
                let deleteIndex = deletions.map({ IndexPath(row: $0, section: 0)})
                let insertIndex = insertions.map({ IndexPath(row: $0, section: 0)})

                self?.prizesTableView.beginUpdates()
                self?.prizesTableView.deleteRows(at: deleteIndex, with: .fade)
                self?.prizesTableView.insertRows(at: insertIndex, with: .fade)
                self?.prizesTableView.endUpdates()

            case .error(_):
                break
            }
        })
    }

    private func prizeDidSelect(_ prize: Prize) {
        if !prize.isSelected {
            selectedPrizes.append(prize)
        } else {
            if let index = selectedPrizes.firstIndex(where: { $0.name == prize.name }) {
                selectedPrizes.remove(at: index)
            }
        }

        var total = selectedPrizes
            .map{$0.cost}
            .reduce(0, +)

        if total > 100 {
            while total > 100 {
                if let firstSelected = selectedPrizes.first {
                    total -= firstSelected.cost

                    let dict: [String: Any?] = ["isSelected": false]
                    realmManager.update(firstSelected, with: dict)
                    selectedPrizes.removeFirst()

                    if let index = prizes.firstIndex(where: { $0.name == firstSelected.name }) {
                        prizesTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }
        }

        navigationItem.title = String(total)
    }

}

//MARK: - UITableViewDataSource
extension PrizesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        prizes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = R.reuseIdentifier.prizeTableViewCell.identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            as? PrizeTableViewCell {

            return cell
        }
        return .init()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if prizes[indexPath.row].isSelected {
                prizeDidSelect(prizes[indexPath.row])
            }
            realmManager.delete(prizes[indexPath.row])
        }
    }

}

//MARK: - UITableViewDelegate
extension PrizesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PrizeTableViewCell {
            cell.configure(with: prizes[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        prizeDidSelect(prizes[indexPath.row])

        let prize = prizes[indexPath.row]
        let isSelected = !prize.isSelected
        let dict: [String: Any?] = ["isSelected": isSelected]
        realmManager.update(prize, with: dict)

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

