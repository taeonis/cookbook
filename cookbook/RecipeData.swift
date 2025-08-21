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
               instructions: [.init(text: "prep"), .init(text: "cook")],
               isPinned: false),
        Recipe(name: "Good Old-Fashioned Pancakes",
               tags: ["Pancakes", "Breakfast", "Yummy", "Breakfast-food", "Simple", "Quick", "Family"],
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
               instructions: [.init(text: "Gather all ingredients. "),
                              .init(text: "Sift flour, baking powder, sugar, and salt together in a large bowl. Make a well in the center and add milk, melted butter, and egg; mix until smooth. "),
                              .init(text: "Heat a lightly oiled griddle or pan over medium-high heat. Pour or scoop the batter onto the griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes."),
                              .init(text: "Flip and cook until browned on the other side. Repeat with remaining batter. "),
                              .init(text: "Serve and enjoy! ")
                           ],
               isPinned: true),
        Recipe(name: "Chicken Tikka Masala",
                tags: ["Indian", "Curry"],
                totalTime: 40,
                servings: 4,
                ingredients: [
                    .init(name: "Boneless, skinless chicken breasts", quantity: 1.5, unit: "pounds"),
                    .init(name: "Yogurt", quantity: 1.0, unit: "cup"),
                ],
               instructions: [.init(text: "prep"), .init(text: "cook")],
                isPinned: false),
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
            recipes[index].isPinned.toggle()
        }
    }

    
    func sortedRecipes() -> Binding<[Recipe]> {
        Binding<[Recipe]>(
            get: {
                self.recipes.sorted {
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned && !$1.isPinned
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
