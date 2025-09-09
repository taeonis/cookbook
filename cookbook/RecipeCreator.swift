//
//  RecipeCreator.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/22/25.
//

import SwiftUI

struct RecipeCreator: View {
    @Binding var recipe: Recipe
    var isNew: Bool = false
    
    @State private var sourceURL: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Paste a url to a recipe")
            
            HStack {
                Image(systemName: "link")
                    .foregroundStyle(.blue)
                
                TextField("example.com/recipe-url", text: $sourceURL)
                    .textEntryBorder()
                
                Button {
                    Task {
                        do {
                            recipe = try await createRecipe(url: sourceURL)
                        } catch {
                            print("error")
                        }
                    }
                } label: {
                    Text("Go")
                }
                .buttonStyle(.bordered)
                
            }
            .padding(.horizontal)
            
            Text("or")
            
            Button  {
                print()
            } label: {
                Image(systemName: "long.text.page.and.pencil")
                Text("Create from scratch")
            }
            .buttonStyle(.bordered)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isNew {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .opacity(0.8)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        RecipeCreator(recipe: .constant(Recipe.example))
    }
}
