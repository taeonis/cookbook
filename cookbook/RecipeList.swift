//
//  RecipeList.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct RecipeList: View {
    @EnvironmentObject var recipeData: RecipeData
    @State private var isAddingNewRecipe = false
    @State private var newRecipe = Recipe()
    @State private var searchText = ""
    @State private var showUrlPrompt = false
    @State private var urlParseLoading = false
    @State private var failedToParse = false
    @State private var url = ""
    
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
        ZStack {
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
            if urlParseLoading {
                VStack(spacing: 12) {
                    ProgressView("Parsing recipe...")
                        .progressViewStyle(.circular)
                        .tint(.blue)
                        .padding()
                }
                .background(Color.secondary.opacity(0.3))
                .cornerRadius(12)
                .padding()
            }
        }
        .navigationTitle("My Recipes")
        .searchable(text: $searchText, prompt: "Search by name or tag")
        .toolbar {
            ToolbarItem {
                Menu {
                    Button {
                        showUrlPrompt = true
                    } label: {
                        Label("Create from url", systemImage: "doc.on.clipboard")
                    }
                    
                    Button {
                        newRecipe = Recipe()
                        isAddingNewRecipe = true
                    } label: {
                        Label("Create from scratch", systemImage: "long.text.page.and.pencil")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Paste a link to a recipe", isPresented: $showUrlPrompt) {
            TextField("example.com/recipe", text: $url)
            HStack {
                Button("Cancel") {
                    showUrlPrompt = false
                }
                
                Button("Enter") {
                    showUrlPrompt = false
                    urlParseLoading = true
                    Task {
                        do {
                            newRecipe = try await createRecipe(url: url) // implement
                            url = ""
                            urlParseLoading = false
                            
                            if newRecipe.name.isEmpty {
                               throw URLError(.badURL)
                            }
                            print("creating new recipe: " + newRecipe.name)
                            isAddingNewRecipe = true
                        } catch {
                            failedToParse = true
                        }
                        
                        urlParseLoading = false
                    }
                }
            }
        } message: {
            Text("CookbookApp will automatically create a recipe from a url.")
        }
        
        .alert("Failed to parse recipe from site", isPresented: $failedToParse) {
            Button("Ok", role: .cancel) {
                failedToParse = false
            }
        } message: {
            Text("Please enter recipe manually or use a different link.")
        }
        
        .sheet(isPresented: $isAddingNewRecipe) {
            NavigationView {
                RecipeEditor(recipe: $newRecipe, isNew: true)
            }
        }
            
    }
}

//#Preview {
//    NavigationStack {
//        RecipeList()
//            .environmentObject(RecipeData())
//    }
//}
#Preview {
//    Color.black.opacity(0.3)
//        .ignoresSafeArea()
    
    VStack(spacing: 12) {
        ProgressView("Parsing recipe...")
            .progressViewStyle(.circular)
            .tint(.blue)
            .padding()
//        Text("Parsing recipe...")
//            .foregroundColor(.primary)
    }
    .padding()
//    .background(.tertiary)
//    .cornerRadius(12)
}

