//
//  TagEditor.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/20/25.
//

import SwiftUI

struct TagDropDelegate: DropDelegate {
    let currentTag: String
    @Binding var tags: [String]

    func performDrop(info: DropInfo) -> Bool {
        print("Drop performed!")
        return true
    }

    func dropEntered(info: DropInfo) {
        print("Drop entered!")
        guard let from = info.itemProviders(for: [.text]).first else { return }
        from.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, _) in
            if let data = data as? Data,
               let draggedTag = String(data: data, encoding: .utf8),
               let fromIndex = tags.firstIndex(of: draggedTag),
               let toIndex = tags.firstIndex(of: currentTag),
               fromIndex != toIndex {
                DispatchQueue.main.async {
                    withAnimation {
                        tags.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                    }
                }
            }
        }
    }
}

struct TagEditor: View {
    @Binding var tags: [String]

    @State var tagRows: [[String]] = []
    @State var selectedTag: String = ""
    
    @State var lastRowWidth: CGFloat = 0
    
    @State private var addingNewTag: Bool = false
    @State private var newTag: String = ""
    @FocusState private var newTagFieldFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done")
            }
            .padding()
        }
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(tagRows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id:\.self) { tag in
                                TagChip(
                                    tag: tag,
                                    isSelected: selectedTag == tag,
                                    onDelete: { deleteTag(for: tag, width: geometry.size.width) }
                                )
                                .onTapGesture {
                                    selectTag(for: tag)
                                }
                                .onDrag {
                                        print("Dragging \(tag)")
                                        return NSItemProvider(object: tag as NSString)
                                    }
                                .onDrop(of: [.text], delegate: TagDropDelegate(
                                    currentTag: tag,
                                    tags: $tags
                                ))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if !addingNewTag {
                        Button(action: {
                            withAnimation(.spring()) { // animate toggle
                                addingNewTag.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.2))
                        )
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        TextField("...", text: $newTag, onCommit: { commitTag(width: geometry.size.width) })
                            .focused($newTagFieldFocused)
                            .fixedSize()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.gray.opacity(0.2))
                            )
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

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

#Preview {
    StatefulPreviewWrapper([
            "tag1", "ksjdfhksfgj", "ffssf", "akjfhkf", "dfjhgjbg", "dfjhgfjhd", "sajfgjd"
        ]) { tags in
            TagEditor(tags: tags)
        }
}
