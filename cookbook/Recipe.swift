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


struct Recipe: Identifiable, Hashable, Equatable {
    var id = UUID()
    var source: String?
    var name: String = ""
    var tags: [String] = []
    var totalTime = 0
    var notes: String = ""
    var ingredients: [Ingredient] = []
    var instructions: [Instruction] = []
    var isPinned = false
    
    static var example = Recipe(
        source: "https://www.allrecipes.com/recipe/21014/good-old-fashioned-pancakes/",
        name: "Good Old-Fashioned Pancakes",
        tags: ["Pancakes", "Breakfast"],
        totalTime: 15,
        notes: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        ingredients: [
            .init(text: "1.5 cups all-purpose flour"),
            .init(text: "3.5 teaspoons baking powder"),
            .init(text: "1 tablespoon white sugar"),
            .init(text: "0.25 teaspoon salt, or more to taste"),
            .init(text: "1.25 cups milk"),
            .init(text: "3 tablespoons butter, melted"),
            .init(text: "1 egg")
         ],
        instructions: [
            .init(text: "Gather all ingredients. "),
            .init(text: "Sift flour, baking powder, sugar, and salt together in a large bowl. Make a well in the center and add milk, melted butter, and egg; mix until smooth. "),
            .init(text: "Heat a lightly oiled griddle or pan over medium-high heat. Pour or scoop the batter onto the griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes."),
            .init(text: "Flip and cook until browned on the other side. Repeat with remaining batter. "),
            .init(text: "Serve and enjoy! ")
        ],
        isPinned: true
    )
}

