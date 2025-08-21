//
//  RecipeRow.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            Image(systemName: "pin.fill")
                .sfSymbolStyling()
                .foregroundStyle(.orange)
                .opacity(recipe.isPinned ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.name)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(recipe.totalTime) min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            TagChip(tag: tag, isSelected: false, onDelete: {})
                                .font(.caption2)
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    RecipeRow(recipe: Recipe.example)
        .environmentObject(RecipeData())
}
