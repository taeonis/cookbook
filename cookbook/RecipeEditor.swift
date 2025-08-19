//
//  RecipeEditor.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct RecipeEditor: View {
    @Binding var recipe: Recipe
    var isNew = false
    
    @State private var isDeleted = false
    @EnvironmentObject var recipeData: RecipeData
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipeCopy = Recipe()
    @State private var isEditing = false
    
    private var isRecipeDeleted: Bool {
        !recipeData.exists(recipe) && !isNew
    }
    
    var body: some View {
        VStack {
            RecipeDetail(recipe: $recipeCopy, isEditing: isNew ? true : isEditing)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if isNew {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                    ToolbarItem {
                        Button {
                            if isNew {
                                recipeData.recipes.append(recipeCopy)
                                dismiss()
                            } else {
                                if isEditing && !isDeleted {
                                    print("Done, saving any changes to \(recipe.name).")
                                    withAnimation {
                                        recipe = recipeCopy // Put edits (if any) back in the store.
                                    }
                                }
                                isEditing.toggle()
                            }
                        } label: {
                            Text(isNew ? "Add" : (isEditing ? "Done" : "Edit"))
                        }
                    }
                }
                .onAppear {
                    recipeCopy = recipe // Grab a copy in case we decide to make edits.
                }
                .disabled(isRecipeDeleted)
        }
    }
}

#Preview {
    RecipeEditor(recipe: .constant(Recipe.example))
        .environmentObject(RecipeData())
}
