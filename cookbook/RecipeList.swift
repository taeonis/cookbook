//
//  RecipeList.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct RecipeList: View {
    @EnvironmentObject var recipeData: RecipeData
    //@State private var isAddingNewEvent = false
    @State private var newRecipe = Recipe()
    @State private var searchText = ""
    
    var visibleRecipes: Binding<[Recipe]> {
        Binding<[Recipe]>(
            get: {
                recipeData.sortedRecipes().wrappedValue.filter { recipe in
                    guard !searchText.isEmpty else { return true }
                    
                    let matchesName = recipe.name.localizedCaseInsensitiveContains(searchText)
                    let matchesTag = recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
                    
                    return matchesName || matchesTag
                }
            },
            set: { newRecipes in
                for recipe in newRecipes {
                    if let index = recipeData.recipes.firstIndex(where: { $0.id == recipe.id }) {
                        recipeData.recipes[index] = recipe
                    }
                }
            }
        )
    }
    
    var body: some View {
        List {
            ForEach(visibleRecipes) { $recipe in
                NavigationLink {
                    RecipeEditor(recipe: $recipe)
                } label: {
                    RecipeRow(recipe: recipe)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        recipeData.delete(recipe)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button() {
                        recipeData.favorite(recipe)
                    } label: {
                        Label("Pin", systemImage: "pin")
                    }
                    .tint(.orange)
                }
            }
        }
        .navigationTitle("My Recipes")
        .searchable(text: $searchText, prompt: "Search by name or tag")
        .toolbar {
            ToolbarItem {
                Button {
                    newRecipe = Recipe()
                    //isAddingNewEvent = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
////        .sheet(isPresented: $isAddingNewEvent) {
////            NavigationView {
////                EventEditor(event: $newEvent, isNew: true)
////            }
////        }
    }
}

struct RecipeList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeList().environmentObject(RecipeData())
        }
    }
}
