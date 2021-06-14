//
//  PrizeTableViewCell.swift
//  MKPrizes
//
//  Created by Mykola Korotun on 12.06.2021.
//

import UIKit

final class PrizeTableViewCell: UITableViewCell {

    @IBOutlet private weak var prizeNameLabel: UILabel!
    @IBOutlet private weak var prizeCostLabel: UILabel!
    @IBOutlet private weak var pickButton: UIButton!

    func configure(with prize: Prize) {
        guard !prize.isInvalidated else { return }

        prizeNameLabel.text = prize.name
        prizeCostLabel.text = String(prize.cost)

        let image = prize.isSelected ? UIImage.imageCheckmarkFill : UIImage.imageSquare
        pickButton.setImage(image, for: .normal)
    }

}

