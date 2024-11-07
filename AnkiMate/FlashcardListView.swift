//
//  FlashcardListView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI
import SwiftData

struct FlashcardListView: View {
    @Query var flashcards: [Flashcard]
    
    var body: some View {
        List(flashcards) { flashcard in
            VStack(alignment: .leading) {
                Text(flashcard.frontText)
                    .font(.headline)
                Text(flashcard.backText)
                    .font(.subheadline)
            }
        }
        .navigationTitle("Flashcards")
    }
}

#Preview {
    FlashcardListView()
        .modelContainer(for: Flashcard.self)
}
