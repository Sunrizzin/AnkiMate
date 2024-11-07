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
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTag: String?
    @State private var showRememberedOnly = false

    // Уникальные теги из всех карточек
    private var uniqueTags: [String] {
        Array(Set(flashcards.flatMap { $0.tags })).sorted()
    }

    var body: some View {
            List(filteredFlashcards()) { flashcard in
                VStack(alignment: .leading) {
                    Text(flashcard.frontText)
                        .font(.headline)
                    Text(flashcard.backText)
                        .font(.subheadline)
                }
                .swipeActions(edge: .trailing) {
                    Button("Delete", role: .destructive) {
                        modelContext.delete(flashcard)
                        try? modelContext.save()
                    }
                }
            }
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        Button("All Tags") { selectedTag = nil }
                        Divider()
                        ForEach(uniqueTags, id: \.self) { tag in
                            Button(tag) { selectedTag = tag }
                        }
                    } label: {
                        Label("Tags", systemImage: "tag")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Toggle("Not Remembered Only", isOn: $showRememberedOnly)
                }
            }
    }
    
    private func filteredFlashcards() -> [Flashcard] {
        var filtered = flashcards
        if showRememberedOnly {
            filtered = filtered.filter { $0.status == .notRemembered }
        }
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        return filtered
    }
}

#Preview {
    FlashcardListView()
        .modelContainer(for: Flashcard.self)
}
