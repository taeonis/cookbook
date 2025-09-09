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
    
    @State var isEditingTags = false
    @State private var isEditingIngredient = false
    @State private var ingredientMultiplier: Float = 1.0
    @State private var wasCancelled: Bool = false
    @State private var isCreatingNew: Bool = false
    @State private var selectedIngredient: Ingredient = Ingredient()
    @State private var isEditingTime = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var deleteTarget: UUID? = nil
    
    @Namespace private var deleteAnimation
    
    var body: some View {
        List {
            // TITLE
            if isEditing {
                TextField("New Recipe", text: $recipe.name, axis: .vertical)
                    .font(.title)
                    .lineLimit(1...5)
                    .textEntryBorder()
                    .fontWeight(.semibold)
            } else {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // TAGS
            if isEditing {
                if recipe.tags.isEmpty {
                    TagScrollView(tags: ["Add a tag..."])
                        .opacity(0.5)
                        .textEntryBorder()
                        .onTapGesture {
                            isEditingTags.toggle()
                        }
                } else {
                    TagScrollView(tags: recipe.tags)
                        .textEntryBorder()
                        .onTapGesture {
                            isEditingTags.toggle()
                        }
                }
            } else {
                if !recipe.tags.isEmpty {
                    TagScrollView(tags: recipe.tags)
                }
            }
            
            // SOURCE
            HStack() {
                Text("Source:")
                    
                if !recipe.source.isEmpty, let url = URL(string: recipe.source) {
                    Link(destination: url) {
                        Text(recipe.source)
                            .foregroundColor(.blue)
                            .underline()
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fontWeight(.regular)
                    }
                } else {
                    Text("N/A")
                        .fontWeight(.regular)
                }
                
                Spacer()
                Divider()
                
                if isEditing {
                    Button {
                        isEditingTime.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                            Text(getTotalTime(for: recipe))
                                .fontWeight(.regular)
                        }
                    }
                    .textEntryBorder()
                } else {
                    HStack {
                        Image(systemName: "clock")
                        Text(getTotalTime(for: recipe))
                            .fontWeight(.regular)
                    }
                }
            }
            .buttonStyle(.plain)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            
            // INGREDIENTS
            Section (
                header:
                    HStack {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        if !isEditing {
                            Spacer()
                            Picker("Multiplier", selection: $ingredientMultiplier) {
                                Text("1/2×").tag(0.5 as Float)
                                Text("1×").tag(1 as Float)
                                Text("2×").tag(2 as Float)
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                        }
                    }
            ) {
                if isEditing {
                    ForEach($recipe.ingredients) { $ingredient in
                        HStack {
                            DeleteButton(
                                deleteTarget: $deleteTarget,
                                itemID: ingredient.id,
                                onDelete: { deleteIngredient(ingredient) })
                            IngredientView(ingredient: $ingredient, ingredientMultiplier: $ingredientMultiplier)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textEntryBorder()
                                .onTapGesture {
                                    editIngredient(ingredient)
                                }
                        }
                        
                    }
                    HStack{
                        Text("Add Ingredient")
                            .fontWeight(.semibold)
                            .opacity(0.3)
                        Spacer()
                        Button { editIngredient()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                        
                    }
                } else {
                    ForEach($recipe.ingredients) { $ingredient in
                        HStack {
                            Button {
                                ingredient.isChecked.toggle()
                            } label: {
                                Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(ingredient.isChecked ? .green : .gray)
                            }
                            .buttonStyle(.plain)
                            .id(ingredient.isChecked)
                            
                            IngredientView(ingredient: $ingredient, ingredientMultiplier: $ingredientMultiplier)
                        }
                    }
                }
            }
            
            // INSTRUCTIONS
            Section(
                header:
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
            ) {
                //if isEditing {
                ForEach($recipe.instructions) { $instruction in
                    HStack {
                        if isEditing {
                            DeleteButton(
                                deleteTarget: $deleteTarget,
                                itemID: instruction.id,
                                onDelete: { deleteInstruction(instruction) })
                        }
                        Text("Step \(recipe.instructions.firstIndex(of: instruction)! + 1)")
                            .fontWeight(.semibold)
                    }
                    
                    if isEditing {
                        TextField("", text: $instruction.text, axis: .vertical)
                            .lineLimit(1...10)
                            .textEntryBorder()
                    } else {
                        Text(instruction.text)
                    }
                }
                if isEditing {
                    HStack {
                        Text("Step \(recipe.instructions.count + 1)")
                            .fontWeight(.semibold)
                            .opacity(0.3)
                        Spacer()
                        Button(action: addInstruction) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isEditingTags) {
            TagEditor(tags: $recipe.tags)
        }
        .sheet(isPresented: $isEditingTime) {
            NavigationStack {
                TimeEditor(time: $recipe.totalTime)
            }
        }
        .sheet(isPresented: $isEditingIngredient, onDismiss: {
            if !wasCancelled && isCreatingNew {
                recipe.ingredients.append(selectedIngredient)
            } else if !wasCancelled, let idx = recipe.ingredients.firstIndex(where: { $0.id == selectedIngredient.id }) {
                recipe.ingredients[idx] = selectedIngredient
            }
            isCreatingNew = false
            wasCancelled = false
        }) {
            NavigationStack {
                IngredientEditor(ingredient: $selectedIngredient, wasCancelled: $wasCancelled)
            }
        }
    }
    
    private func deleteIngredient(_ ingredient: Ingredient) {
        if deleteTarget == ingredient.id {
            recipe.ingredients.removeAll { $0.id == ingredient.id }
            deleteTarget = nil
        }
        else {
            deleteTarget = ingredient.id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // reset after 2 seconds if not pressed again
                if deleteTarget == ingredient.id {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        deleteTarget = nil
                    }
                }
            }
        }
    }
    
    private func editIngredient(_ ingredient: Ingredient? = nil) {
        if let ingredient {
            selectedIngredient = ingredient
        } else {
            isCreatingNew = true
            selectedIngredient = Ingredient()
        }
        isEditingIngredient.toggle()
    }
    
    private func deleteInstruction(_ instruction: Instruction) {
        if deleteTarget == instruction.id {
            recipe.instructions.removeAll { $0.id == instruction.id }
            deleteTarget = nil
        }
        else {
            deleteTarget = instruction.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // reset after 2 seconds if not pressed again
                if deleteTarget == instruction.id {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        deleteTarget = nil
                    }
                }
            }
        }
    }
    
    private func addInstruction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            recipe.instructions.append(Instruction(text: ""))
        }
    }
}


#Preview {
    StatefulPreviewWrapper(Recipe.example) { recipe in
        RecipeDetail(recipe: recipe, isEditing: true)
            .environmentObject(RecipeData())
    }
}
