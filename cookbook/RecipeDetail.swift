//
//  RecipeDetail.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct RecipeDetail: View {
    @Binding var recipe: Recipe
    let isEditing: Bool
    
    @State private var isEditingTags = false
    
    var body: some View {
        List {
            if isEditing {
                TextField("New Recipe", text: $recipe.name)
                    .font(.title)
            } else {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            if isEditing {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            TagChip(tag: tag, isSelected: false, onDelete: {})
                                .font(.caption2)
                        }
                    }
                }
                .onTapGesture {
                    isEditingTags.toggle()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            TagChip(tag: tag, isSelected: false, onDelete: {})
                                .font(.caption2)
                        }
                    }
                }
            }
            
            Text("Ingredients")
                .font(.title2)
                .fontWeight(.semibold)
            if isEditing {
                
            } else {
                ForEach($recipe.ingredients) { $ingredient in
                    HStack {
                        Button {
                            ingredient.isChecked.toggle()
                            print(ingredient.isChecked)
                        } label: {
                            Image(systemName: ingredient.isChecked ? "heart" : "circle")
                                .foregroundColor(ingredient.isChecked ? .green : .gray)
                        }
                        .buttonStyle(.plain)
                        .id(ingredient.isChecked)
                        
                        Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                    }
                }
            }
            
            Text("Directions")
                .font(.title2)
                .fontWeight(.semibold)
            if isEditing {
                
            } else {
                ForEach(recipe.directions.indices, id: \.self) { idx in
                    Text("Step \(idx + 1)")
                        .fontWeight(.semibold)
                    Text(recipe.directions[idx])
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isEditingTags) {
            TagEditor(tags: $recipe.tags)
        }
    }
}



#Preview {
    RecipeDetail(recipe: .constant(Recipe.example), isEditing: true)
        .environmentObject(RecipeData())
}
