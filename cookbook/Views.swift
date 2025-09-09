//
//  Views.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/21/25.
//

import SwiftUI

struct TextEntryBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3))
            )
    }
}

struct TagBackgroundShape: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
            )
    }
}

struct DeleteButtonShape: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}


extension View {
    func textEntryBorder() -> some View {
        self.modifier(TextEntryBorder())
    }
    
    func tagBackgroundShape() -> some View {
        self.modifier(TagBackgroundShape())
    }
}
