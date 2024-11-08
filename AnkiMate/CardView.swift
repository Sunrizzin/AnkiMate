//
//  CardView.swift
//  AnkiMate
//
//  Created by Sunrizz on 8/11/24.
//

import SwiftUI

struct CardView: View {
    var card: Flashcard

    @Binding var selectedTag: Tag?

    var body: some View {
        VStack(alignment: .leading) {
            Text(card.frontText)
                .font(.title3)
            Text(card.backText)
                .font(.subheadline)

            HStack {
                ForEach(card.tags, id: \.id) { tag in
                    TagView(tag: tag.name, isSelected: selectedTag == tag)
                        .onTapGesture {
                            selectedTag = (selectedTag == tag) ? nil : tag
                        }
                }
            }
        }
    }
}

#Preview {
    CardView(
        card: Flashcard(
            frontText: "Front Text",
            backText: "BackText",
            tags: [
                Tag(name: "tag1"),
                Tag(name: "tag2"),
                Tag(name: "tag3"),
            ],
            image: nil,
            reviewDate: .now,
            status: .notRemembered
        ), selectedTag: .constant(nil)
    )
}
