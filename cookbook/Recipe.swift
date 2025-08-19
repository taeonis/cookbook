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
    var isFavorite = false
    
    static var example = Recipe(
        name: "Spaghetti Carbonara",
        tags: ["Italian", "Pasta"],
        totalTime: 20,
        servings: 2,
        ingredients: [
            .init(name: "Spaghetti", quantity: 1.0, unit: "pound"),
            .init(name: "Guanciale or pancetta", quantity: 2.0, unit: "ounces"),
        ],
        directions: ["prep", "cook"],
        isFavorite: true
    )
}

