//
//  Recipe.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct Recipe: Identifiable, Hashable {
    var id = UUID()
    var source = ""
    var name = ""
    var tags: [String] = []
    var totalTime = 0
    var servings = 0
    var ingredients: [Ingredient] = []
    var directions: [String] = []
    var isPinned = false
    
    static var example = Recipe(
        name: "Good Old-Fashioned Pancakes",
        tags: ["Pancakes", "Breakfast"],
        totalTime: 15,
        servings: 8,
        ingredients: [
            .init(isChecked: false, name: "flour", quantity: 1.5, unit: "cups"),
            .init(isChecked: false, name: "baking powder", quantity: 3.5, unit: "teaspoons"),
            .init(isChecked: false, name: "white sugar", quantity: 1, unit: "tablespoon"),
            .init(isChecked: false, name: "salt", quantity: 0.25, unit: "teaspoon"),
            .init(isChecked: false, name: "milk", quantity: 1.25, unit: "cups"),
            .init(isChecked: false, name: "butter", quantity: 3, unit: "tablespoons"),
            .init(isChecked: false, name: "large eggs", quantity: 1, unit: "self"),
        ],
        directions: ["Gather all ingredients. ",
                     "Sift flour, baking powder, sugar, and salt together in a large bowl. Make a well in the center and add milk, melted butter, and egg; mix until smooth. ",
                     "Heat a lightly oiled griddle or pan over medium-high heat. Pour or scoop the batter onto the griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes.",
                     "Flip and cook until browned on the other side. Repeat with remaining batter. ",
                     "Serve and enjoy! "
                    ],
        isPinned: true
    )
}

