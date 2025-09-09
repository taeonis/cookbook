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
    
    @State private var isAdding = false
    
    private var isRecipeDeleted: Bool {
        !recipeData.exists(recipe) && !isNew
    }
    
    var body: some View {
        VStack {
            RecipeDetail(recipe: $recipeCopy, isEditing: isNew ? true : isEditing)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if isNew {
                            Button("Cancel", role: .cancel) {
                                dismiss()
                            }
                            .opacity(0.8)
                        }
                    }
                    ToolbarItem {
                        Button {
                            recipeCopy.instructions = recipeCopy.instructions.filter { !$0.text.isEmpty }
                            if isNew {
                                recipeData.recipes.append(recipeCopy)
                                dismiss()
                            } else {
                                if isEditing && !isDeleted {
                                    withAnimation {
                                        recipe = recipeCopy
                                    }
                                }
                                isEditing.toggle()
                            }
                        } label: {
                            Text(isNew ? "Add" : (isEditing ? "Done" : "Edit"))
                        }
                        .disabled(recipeCopy.name.isEmpty)
                    }
                }
                .onAppear {
                    recipeCopy = recipe
                }
                .disabled(isRecipeDeleted)
        }
    }
}

#Preview {
    RecipeEditor(recipe: .constant(Recipe.example))
        .environmentObject(RecipeData())
}
