//
//  Prize.swift
//  MKPrizes
//
//  Created by Mykola Korotun on 12.06.2021.
//

import Foundation
import RealmSwift

@objcMembers class Prize: Object {

    dynamic var name: String = ""
    dynamic var cost: Int = 0
    dynamic var isSelected: Bool = false

    convenience init(name: String, cost: Int, isSelected: Bool) {
        self.init()

        self.name = name
        self.cost = cost
        self.isSelected = isSelected
    }

}
