//
//  cookbookApp.swift
//  cookbook
//
//  Created by Taeoni Norgaar on 8/5/25.
//

import SwiftUI

@main
struct CookBookApp: App {
    @StateObject private var recipeData = RecipeData()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                RecipeList()
                Text("Select a Recipe")
                    .foregroundStyle(.secondary)
            }
            .environmentObject(recipeData)

        }
    }
}
