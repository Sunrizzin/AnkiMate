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
    @State private var isEditPresented = false
    @State private var selectedFlashcard: Flashcard?
    @State private var flashcardToDelete: Flashcard?
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            ForEach(flashcards) { flashcard in
                VStack(alignment: .leading) {
                    Text(flashcard.frontText)
                        .font(.headline)
                    Text(flashcard.backText)
                        .font(.subheadline)
                }
                .contentShape(Rectangle())
                .swipeActions(edge: .trailing) {
                    Button("Delete", role: .destructive) {
                        flashcardToDelete = flashcard
                        showDeleteConfirmation.toggle()
                    }
                    
                    Button("Edit") {
                        selectedFlashcard = flashcard
                        isEditPresented.toggle()
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("Flashcards")
        .sheet(isPresented: $isEditPresented) {
            if let selectedFlashcard = selectedFlashcard {
                AddFlashcardView(flashcardToEdit: selectedFlashcard)
            }
        }
        .confirmationDialog("Are you sure you want to delete this card?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let flashcardToDelete = flashcardToDelete {
                    modelContext.delete(flashcardToDelete)
                    try? modelContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    FlashcardListView()
        .modelContainer(for: Flashcard.self)
}
