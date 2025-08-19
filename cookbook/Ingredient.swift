//
//  Ingredient.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import Foundation

struct Ingredient: Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var quantity: Float = 0
    var unit : String = ""
    
}

