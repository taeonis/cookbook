//
//  Recipe.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct Instruction: Identifiable, Hashable, Codable {
    var id = UUID()
    var text: String = ""
}

func getTotalTime(for recipe: Recipe) -> String {
    if recipe.totalTime < 60 {
        return String("\(recipe.totalTime)m")
    }
    if recipe.totalTime % 60 == 0 {
        return String("\(recipe.totalTime / 60)h")
    }
    return String("\(recipe.totalTime / 60)h \(recipe.totalTime % 60)m")
}


struct Recipe: Identifiable, Hashable {
    var id = UUID()
    var source = ""
    var name = ""
    var tags: [String] = []
    var totalTime = 0
    var servings = 0
    var ingredients: [Ingredient] = []
    var instructions: [Instruction] = []
    var isPinned = false
    
    static var example = Recipe(
        source: "https://www.allrecipes.com/recipe/21014/good-old-fashioned-pancakes/",
        name: "Good Old-Fashioned Pancakes",
        tags: ["Pancakes", "Breakfast"],
        totalTime: 15,
        servings: 8,
        ingredients: [
         .init(isChecked: false, name: "range test", quantityIsRange: true, quantityRange: [1, 3], unit: .lb),
         .init(isChecked: false, name: "custom unit test", quantityRange: [40, 40], unit: .custom, customUnit: "myCustomUnit"),
         .init(isChecked: false, name: "flour", quantityRange: [1.5, 1.5], unit: .cup),
         .init(isChecked: false, name: "baking powder", quantityRange: [3.5, 3.5], unit: .tsp),
         .init(isChecked: false, name: "white sugar", quantityRange: [1, 1], unit: .tbsp),
         .init(isChecked: false, name: "salt", quantityRange: [0.25, 0.25], unit: .tsp),
         .init(isChecked: false, name: "milk", quantityRange: [1.25, 1.25], unit: .cup),
         .init(isChecked: false, name: "butter", quantityRange: [3, 3], unit: .tbsp),
         .init(isChecked: false, name: "large eggs", quantityRange: [1, 1], unit: .n_a),
        ],
        instructions: [.init(text: "Gather all ingredients. "),
                       .init(text: "Sift flour, baking powder, sugar, and salt together in a large bowl. Make a well in the center and add milk, melted butter, and egg; mix until smooth. "),
                       .init(text: "Heat a lightly oiled griddle or pan over medium-high heat. Pour or scoop the batter onto the griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes."),
                       .init(text: "Flip and cook until browned on the other side. Repeat with remaining batter. "),
                       .init(text: "Serve and enjoy! ")
                    ],
        isPinned: true
    )
}

