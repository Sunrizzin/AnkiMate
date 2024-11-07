//
//  TagView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//


import SwiftUI

struct TagView: View {
    let tag: String
    let color: Color

    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(5)
            .background(color)
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}