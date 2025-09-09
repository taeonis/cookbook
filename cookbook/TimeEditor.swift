//
//  TimeEditor.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/31/25.
//

import Foundation
import SwiftUI


struct TimeEditor: View {
    @Binding var time: Int
    
    @State var hours: Int = 0
    @State var minutes: Int = 0
    
    @State var originalTime: Int = 0
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("Adjust total time:")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.top)
        
        HStack() {
            // Hours wheel
            HStack(spacing: 0) {
                Picker("Hours", selection: $hours) {
                    ForEach(0...23, id: \.self) { number in
                        Text("\(number)").tag(number)
                            .fontWeight(number == hours ? .bold : .regular)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 70, height: 150) // narrow column

                Text("hours")
                    .foregroundColor(.secondary)
                    .fixedSize()
            }

            // Minutes wheel
            HStack(spacing: 0) {
                Picker("Minutes", selection: $minutes) {
                    ForEach(0...59, id: \.self) { number in
                        Text("\(number)").tag(number)
                            .fontWeight(number == minutes ? .bold : .regular)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 70, height: 150)
                .clipped()

                Text("min")
                    .foregroundColor(.secondary)
                    .fixedSize()
            }
        }
        .padding()
        .font(.title)
        .onAppear {
            originalTime = time
            hours = time / 60
            minutes = time % 60
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    time = originalTime
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem {
                Button {
                    time = hours * 60 + minutes
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
        Spacer()
    }
}

#Preview {
    StatefulPreviewWrapper(125) { time in
        TimeEditor(time: time)
            .padding()
    }
}

