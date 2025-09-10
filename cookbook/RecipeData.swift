//
//  RecipeDat.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

class RecipeData: ObservableObject {
    @Published var recipes: [Recipe] = [
        Recipe(
            source: "https://cooking.nytimes.com/recipes/1023675-gochujang-caramel-cookies",
            name: "Gochujang Caramel Cookies",
            tags: [],
            totalTime: 45,
            ingredients: [
                .init(text:"1/2 cup (8 tablespoons)/115 grams unsalted butter, very soft"),
                .init(text: "2 packed tablespoons dark brown sugar"),
                .init(text: "1 heaping tablespoon gochujang"),
                .init(text: "1 cup/200 grams granulated sugar"),
                .init(text: "1 large egg, at room temperature"),
                .init(text: "1/2 teaspoon coarse kosher salt or 3/4 teaspoon kosher salt (such as Diamond Crystal)"),
                .init(text: "1/4 teaspoon ground cinnamon"),
                .init(text: "1 teaspoon vanilla extract"),
                .init(text: "1/2 teaspoon baking soda"),
                .init(text: "1 1/2 cups/185 grams all-purpose flour")
            ],
            instructions: [
                .init(text: "In a small bowl, stir together 1 tablespoon butter, the brown sugar and gochujang until smooth. Set aside for later, at room temperature."),
                .init(text: "In a large bowl, by hand, whisk together the remaining 7 tablespoons butter, the granulated sugar, egg, salt, cinnamon and vanilla until smooth, about 1 minute. Switch to a flexible spatula and stir in the baking soda. Add the flour and gently stir to combine. Place this large bowl in the refrigerator until the dough is less sticky but still soft and pliable, 15 to 20 minutes."),
                .init(text: "While the dough is chilling, heat the oven to 350 degrees and line 2 large sheet pans with parchment."),
                .init(text: "Remove the dough from the refrigerator. In 3 to 4 separately spaced out blobs, spoon the gochujang mixture over the cookie dough. Moving in long circular strokes, swirl the gochujang mixture into the cookie dough so you have streaks of orange-red rippled throughout the beige. Be sure not to overmix at this stage, as you want wide, distinct strips of gochujang."),
                .init(text: "Use an ice cream scoop to plop out ¼-cup rounds spaced at least 3 inches apart on the sheet pans. (You should get 4 to 5 cookies per pan.) Bake until lightly golden at the edges and dry and set in the center, 11 to 13 minutes, rotating the pans halfway through. Let cool completely on the sheet pan; the cookies will flatten slightly and continue cooking as they cool. The cookies will keep in an airtight container at room temperature for up to 2 days.")
            ],
            isPinned: false
        ),
        Recipe(
           source: "https://www.allrecipes.com/recipe/21014/good-old-fashioned-pancakes/",
           name: "Good Old-Fashioned Pancakes",
           tags: ["Pancakes", "Breakfast", "Yummy", "Breakfast-food", "Simple", "Quick", "Family"],
           totalTime: 15,
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
                .init(text: "Heat a lightly oiled griddle or pan over medium-high heat. Pour or scoop the batter onto the  griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes."),
                .init(text: "Flip and cook until browned on the other side. Repeat with remaining batter. "),
                .init(text: "Serve and enjoy! ")
            ],
            isPinned: true
        ),
        Recipe(
            name: "Chicken Tikka Masala",
            tags: ["Indian", "Curry"],
            totalTime: 140,
            ingredients: [],
            instructions: [
                .init(text: "prep"),
                .init(text: "cook")
            ],
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
