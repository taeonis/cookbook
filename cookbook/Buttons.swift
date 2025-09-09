//
//  Buttons.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/21/25.
//

import SwiftUI

struct DeleteButton: View {
    @Binding var deleteTarget: UUID?
    var itemID: UUID
    let onDelete: () -> Void
    @State var mybool: Bool = false
    
    var buttonSelected: Bool {
        deleteTarget == itemID
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                onDelete()
            }
        }) {
            Text(buttonSelected ? "Delete" : "")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(buttonSelected ? .red : Color.clear)
                        .overlay {
                            if !buttonSelected {
                                Image(systemName: "minus.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .red)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                )
                .foregroundColor(.white)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .fixedSize()
    }
}

#Preview {
    struct DeleteButtonPreview: View {
        @State private var deleteTarget: UUID? = nil
        private let testID = UUID()

        var body: some View {
            DeleteButton(
                deleteTarget: $deleteTarget,
                itemID: testID,
                onDelete: {
                    deleteTarget = (deleteTarget == testID ? nil : testID)
                }
            )
            .padding()
        }
    }

    return DeleteButtonPreview()
}
