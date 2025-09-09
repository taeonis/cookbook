//
//  TagEditor.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/20/25.
//

import SwiftUI

struct TagEditor: View {
    @Binding var tags: [String]

    @State var tagRows: [[String]] = []
    @State var selectedTag: String = ""
    
    @State private var dropTarget: String? = nil
    
    @State private var addingNewTag: Bool = false
    @State private var newTag: String = ""
    @FocusState private var newTagFieldFocused: Bool
    
    @State private var draggedTag: String?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done")
            }
            .font(.headline)
        }
        .padding()
        
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    tagGrid(width: geometry.size.width)
                    
                    if !addingNewTag {
                        Button(action: {
                            withAnimation(.spring()) { // animate toggle
                                addingNewTag.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.green)
                        }
                        .tagBackgroundShape()
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        TextField("...", text: $newTag, onCommit: { commitTag(width: geometry.size.width) })
                            .focused($newTagFieldFocused)
                            .fixedSize()
                            .tagBackgroundShape()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    newTagFieldFocused = true
                                }
                            }
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTag = ""
                    addingNewTag = false
                    newTag = ""
                }
                .onAppear() {
                    calculateRows(for: geometry.size.width)
                }
            }
            .onChange(of: tags) {
                calculateRows(for: geometry.size.width)
            }
        }
    }
    
    private func tagGrid(width: CGFloat) -> some View {
        ForEach(tagRows, id: \.self) { row in
            HStack(spacing: 8) {
                ForEach(row, id:\.self) { tag in
                    if dropTarget == tag {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 2, height: 20)
                            .padding(.trailing, 2)
                            .transition(.opacity)
                    }
                    
                    TagChip(
                        tag: tag,
                        isSelected: selectedTag == tag,
                        onDelete: { deleteTag(for: tag, width: width) }
                    )
                    .onTapGesture {
                        selectTag(for: tag)
                    }
                    .draggable(tag)
                    .dropDestination(for: String.self) { items, _ in
                        guard let fromTag = items.first,
                              let fromIndex = tags.firstIndex(of: fromTag),
                              let toIndex   = tags.firstIndex(of: tag),
                              fromIndex != toIndex else { return false }
                        
                        withAnimation {
                            let item = tags.remove(at: fromIndex)
                            let dest = (fromIndex < toIndex) ? max(0, toIndex - 1) : toIndex
                            tags.insert(item, at: dest)
                        }
                        return true
                    } isTargeted: { isHovering in
                        withAnimation {
                            dropTarget = isHovering ? tag : nil
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func commitTag(width: CGFloat) {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            addingNewTag = false
            return
        }
        
        tags.append(trimmed)
        addingNewTag = false
        DispatchQueue.main.async {
            newTag = ""
        }
        calculateRows(for: width)
    }
    
    private func deleteTag(for tag: String, width: CGFloat) {
        tags.removeAll { $0 == tag }
        selectedTag = ""
        calculateRows(for: width)
        selectedTag = ""
    }
    
    private func selectTag(for tag: String) {
        if selectedTag != tag {
            selectedTag = tag
        } else {
            selectedTag = ""
        }
    }
        
    private func calculateRows(for availableWidth: CGFloat) {
        tagRows = []
        var currentRow: [String] = []
        var currentRowWidth: CGFloat = 17 // account for one possible delete icon per row
        for tag in tags {
            let tagWidth = tag.calculateWidth(usingFont: .systemFont(ofSize: 16)) + 16
            if currentRowWidth + tagWidth <= availableWidth {
                currentRow.append(tag)
                currentRowWidth += tagWidth
            } else {
                tagRows.append(currentRow)
                currentRow = [tag]
                currentRowWidth = tagWidth
            }
        }
        
        if !currentRow.isEmpty {
            if currentRowWidth + 17 > availableWidth { // account for add tag icon
                let lastTag: String = currentRow.popLast()!
                tagRows.append(currentRow)
                currentRow = [lastTag]
            }
            tagRows.append(currentRow)
        }
    }
}

extension String {
    func calculateWidth(usingFont font: UIFont) -> CGFloat {
        let textWidth = (self as NSString).size(withAttributes: [.font: font]).width
        let paddingWidth = 24
        return textWidth + CGFloat(paddingWidth)
    }
}


#Preview {
    StatefulPreviewWrapper([
            "tag1", "ksjdfhksfgj", "ffssf", "akjfhkf", "dfjhgjbg", "dfjhgfjhd", "sajfgjd"
        ]) { tags in
            TagEditor(tags: tags)
        }
}
