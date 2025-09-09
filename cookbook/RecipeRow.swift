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
                
                HStack {
                    Image(systemName: "clock")
                    Text(getTotalTime(for: recipe))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 5)
                
                TagScrollView(tags: recipe.tags)
            }
        }
    }
}



#Preview {
    RecipeRow(recipe: Recipe.example)
        .environmentObject(RecipeData())
}
