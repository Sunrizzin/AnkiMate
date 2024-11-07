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
            .padding(6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
            .cornerRadius(10)
            .foregroundColor(isSelected ? .white : .black)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
            )
            .animation(.easeInOut, value: isSelected)
    }
}
