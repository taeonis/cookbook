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
    
    @State private var isPickingSymbol = false
    
    var body: some View {
        List {
            if isEditing {
                TextField("New Recipe", text: $recipe.name)
                    .font(.title2)
            } else {
                Text(recipe.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            
            if isEditing {
                
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RecipeDetail(recipe: .constant(Recipe.example), isEditing: false)
}
