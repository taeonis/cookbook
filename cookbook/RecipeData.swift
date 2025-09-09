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
               totalTime: 120,
               servings: 2,
               ingredients: [
                .init(name: "Spaghetti", quantityRange: [1.0, 1.0], unit: .lb),
                .init(name: "Guanciale or pancetta", quantityRange: [2.0, 2.0], unit: .oz),
               ],
               instructions: [.init(text: "prep"), .init(text: "cook")],
               isPinned: false),
        Recipe(source: "https://www.allrecipes.com/recipe/21014/good-old-fashioned-pancakes/",
               name: "Good Old-Fashioned Pancakes",
               tags: ["Pancakes", "Breakfast", "Yummy", "Breakfast-food", "Simple", "Quick", "Family"],
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
               isPinned: true),
        Recipe(name: "Chicken Tikka Masala",
                tags: ["Indian", "Curry"],
                totalTime: 140,
                servings: 4,
                ingredients: [
                    .init(name: "Boneless, skinless chicken breasts", quantityRange: [1.5, 1.5], unit: .lb),
                    .init(name: "Yogurt", quantityRange: [1.0, 1.0], unit: .cup),
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
