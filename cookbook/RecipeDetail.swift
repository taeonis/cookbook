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
    @State private var isEditingIngredient = false
    @State private var editingIngredient: Ingredient? = nil
    
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
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3))
                    )
            } else {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // TAGS
            if isEditing {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            TagChip(tag: tag, isSelected: false, onDelete: {})
                                .font(.caption2)
                        }
                    }
                    
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
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
            
            // INGREDIENTS
            Text("Ingredients")
                .font(.title2)
                .fontWeight(.semibold)
            if isEditing {
                ForEach($recipe.ingredients) { $ingredient in
                    HStack {
                        Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                        Spacer()
                        
                        Button { deleteIngredient(ingredient)
                        } label: {
                            if (deleteTarget == ingredient.id) {
                                Text("Delete")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.red)
                                            .matchedGeometryEffect(id: "deleteButton\(ingredient.id)", in: deleteAnimation)
                                    )
                            } else {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .fill(.red.opacity(0.2))
                                            .matchedGeometryEffect(id: "deleteButton\(ingredient.id)", in: deleteAnimation)
                                    )
                            }
                        }
                        .buttonStyle(.borderless)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: deleteTarget)
                        
                        Button { editingIngredient = ingredient
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack{
                    Text("Add Ingredient")
                        .fontWeight(.semibold)
                        .opacity(0.3)
                    Spacer()
                    Button {
                        addIngredient()
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.green)
                    }
                    
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
                        
                        Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                    }
                }
            }
            
            // INSTRUCTIONS
            Text("Instructions")
                .font(.title2)
                .fontWeight(.semibold)
            if isEditing {
                ForEach($recipe.instructions) { $instruction in
                    HStack {
                        Text("Step \(recipe.instructions.firstIndex(of: instruction)! + 1)")
                            .fontWeight(.semibold)
                        Spacer()
                        
                        Button {
                            deleteInstruction(instruction)
                            print("deleting")
                        } label: {
                            if (deleteTarget == instruction.id) {
                                Text("Delete")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.red)
                                            .matchedGeometryEffect(id: "deleteButton\(instruction.id)", in: deleteAnimation)
                                )
                            } else {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .fill(.red.opacity(0.2))
                                            .matchedGeometryEffect(id: "deleteButton\(instruction.id)", in: deleteAnimation)
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: deleteTarget)
                    }
                    TextField("", text: $instruction.text, axis: .vertical)
                        .lineLimit(1...10)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                HStack{
                    Text("Step \(recipe.instructions.count + 1)")
                        .fontWeight(.semibold)
                        .opacity(0.3)
                    Spacer()
                    Button {
                        addInstruction()
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.green)
                    }
                    
                }
            } else {
                ForEach(recipe.instructions.indices, id: \.self) { idx in
                    Text("Step \(idx + 1)")
                        .fontWeight(.semibold)
                    Text(recipe.instructions[idx].text)
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
    
    private func deleteIngredient(_ ingredient: Ingredient) {
        if deleteTarget == ingredient.id {
            recipe.ingredients.removeAll { $0.id == ingredient.id }
            deleteTarget = nil
        }
        else {
            deleteTarget = ingredient.id
        }
    }
    
    private func addIngredient() {
        
    }
    
    private func deleteInstruction(_ instruction: Instruction) {
        if deleteTarget == instruction.id {
            recipe.instructions.removeAll { $0.id == instruction.id }
            deleteTarget = nil
        }
        else {
            deleteTarget = instruction.id
        }
    }
    
    private func addInstruction() {
        recipe.instructions.append(Instruction(text: ""))
    }
}


#Preview {
    StatefulPreviewWrapper(Recipe.example) { recipe in
        RecipeDetail(recipe: recipe, isEditing: true)
            .environmentObject(RecipeData())
    }
}
