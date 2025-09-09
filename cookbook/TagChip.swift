//
//  TagChip.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/20/25.
//

import SwiftUI

struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack() {
            Text(tag)
            
            if isSelected {
                Button(action: onDelete) {
                    Image(systemName: "x.circle")
                        .foregroundColor(.white)
                }
                .tint(.white)
            }
        }
        .padding(.horizontal, isSelected ? 0 : 10)
        .padding(.leading, isSelected ? 10 : 0)
        .padding(.trailing, isSelected ? 5 : 0)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? .red : .gray.opacity(0.2))
        )
        .foregroundColor(.primary)
        .fixedSize()
        .scaleEffect(isSelected ? 0.9 : 1.0)
        .animation(.spring, value: isSelected)
    }
}

struct TagScrollView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    TagChip(tag: tag, isSelected: false, onDelete: {})
                        .font(.caption2)
                }
            }
        }
    }
}

#Preview {
    TagChip(
        tag: "tag",
        isSelected: false,
        onDelete: {}
    )
}
