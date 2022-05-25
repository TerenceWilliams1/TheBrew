//
//  BrewItem.swift
//  The Brew
//
//  Created by Terence Williams on 5/24/22.
//

import Foundation

struct Brew {
    var name: String
    var imageURL: URL?
    var type: DrinkType?
    var steps: [String]
}

enum DrinkType {
    case tea
    case coldDrinks
    case hotDrinks
    case frappuccino
}
