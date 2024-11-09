//
//  TagView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI

struct TagView: View {
    let tag: String
    let isSelected: Bool

    var body: some View {
        Text(tag)
            .font(.footnote)
            .monospaced()
            .padding(6)
            .background(isSelected ? Color.accentColor : .gray)
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 2 : 0)
            )
            .animation(.default, value: isSelected)
    }
}

#Preview {
    TagView(tag: "tag1", isSelected: true)
}
