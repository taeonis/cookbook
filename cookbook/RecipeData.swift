//
//  RecipeDat.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

class RecipeData: ObservableObject {
    @Published var recipes: [Recipe] = [
        Recipe(name: "Spaghetti Carbonara",
               tags: ["Italian", "Pasta"],
               totalTime: 20,
               servings: 2,
               ingredients: [
                   .init(name: "Spaghetti", quantity: 1.0, unit: "pound"),
                   .init(name: "Guanciale or pancetta", quantity: 2.0, unit: "ounces"),
               ],
               directions: ["prep", "cook"],
               isFavorite: false),
        Recipe(name: "Pancakes",
                tags: ["Breakfast"],
                totalTime: 10,
                servings: 4,
                ingredients: [
                    .init(name: "flour", quantity: 1.5, unit: "cup"),
                    .init(name: "eggs", quantity: 2.0, unit: "self"),
                ],
                directions: ["prep", "cook"],
                isFavorite: true),
        Recipe(name: "Chicken Tikka Masala",
                tags: ["Indian", "Curry"],
                totalTime: 40,
                servings: 4,
                ingredients: [
                    .init(name: "Boneless, skinless chicken breasts", quantity: 1.5, unit: "pounds"),
                    .init(name: "Yogurt", quantity: 1.0, unit: "cup"),
                ],
                directions: ["prep", "cook"],
                isFavorite: false),
    ]
    
    func delete(_ recipe: Recipe) {
        recipes.removeAll() { $0.id == recipe.id }
    }
    
    func add(_ recipe: Recipe) {
        recipes.append(recipe)
    }
    
    func exists(_ recipe: Recipe) -> Bool {
        recipes.contains(recipe)
    }
    
    func favorite(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite.toggle()
        }
    }
    
    func sortedRecipes() -> Binding<[Recipe]> {
        Binding<[Recipe]>(
            get: {
                self.recipes.sorted {
                    if $0.isFavorite != $1.isFavorite {
                        return $0.isFavorite && !$1.isFavorite
                    } else {
                        return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    }
                }
            },
            set: { newRecipes in
                for recipe in newRecipes {
                    if let index = self.recipes.firstIndex(where: { $0.id == recipe.id }) {
                        self.recipes[index] = recipe
                    }
                }
            }
        )
    }
}
