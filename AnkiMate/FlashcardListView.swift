//
//  FlashcardListView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftData
import SwiftUI

struct FlashcardListView: View {
    @Query var flashcards: [Flashcard]
    @Query var tags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @State private var isAddCardPresented = false
    @State private var selectedTag: Tag?
    @State private var showRememberedOnly = false
    @State private var searchText = ""

    @State var editFlashcard: Flashcard? = nil
    @State private var flashcardToDelete: Flashcard?
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            ForEach(filteredFlashcards()) { flashcard in
                CardView(card: flashcard, selectedTag: $selectedTag)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            flashcardToDelete = flashcard
                            showDeleteConfirmation.toggle()
                        }
                        Button("Edit", role: .cancel) {
                            editFlashcard(flashcard)
                        }
                    }
            }
        }
        .navigationTitle("Anki Mate")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button("Clear filter") {
                        withAnimation {
                            selectedTag = nil
                        }
                    }
                    Divider()
                    ForEach(tags, id: \.id) { tag in
                        Button(tag.name) {
                            withAnimation {
                                selectedTag = tag
                            }
                        }
                        .monospaced()
                    }
                } label: {
                    Label("Tags", systemImage: selectedTag == nil ? "tag" : "tag.fill")
                }
                .disabled(tags.isEmpty)
            }

            ToolbarItem(placement: .bottomBar) {
                Toggle("Not Remembered Only", isOn: $showRememberedOnly)
                    .disabled(flashcards.isEmpty)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editFlashcard = nil
                    isAddCardPresented.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .hoverEffect()
                }
            }
        }
        .sheet(isPresented: $isAddCardPresented) {
            AddFlashcardView(flashcardToEdit: $editFlashcard)
        }
        .confirmationDialog("Are you sure you want to delete this flashcard?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let flashcard = flashcardToDelete {
                    deleteFlashcard(flashcard)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .searchable(text: $searchText, prompt: "Search flashcards")
        .searchPresentationToolbarBehavior(.avoidHidingContent)
    }

    private func editFlashcard(_ flashcard: Flashcard) {
        editFlashcard = flashcard
        isAddCardPresented.toggle()
    }

    private func deleteFlashcard(_ flashcard: Flashcard) {
        modelContext.delete(flashcard)
        try? modelContext.save()
    }

    private func filteredFlashcards() -> [Flashcard] {
        var filtered = flashcards

        if showRememberedOnly {
            filtered = filtered.filter { $0.status == .notRemembered }
        }

        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.frontText.localizedCaseInsensitiveContains(searchText) ||
                    $0.backText.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered
    }
}

#Preview {
    FlashcardListView()
        .modelContainer(for: Flashcard.self)
}
