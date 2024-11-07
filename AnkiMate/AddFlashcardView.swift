//
//  AddFlashcardView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI
import SwiftData

struct AddFlashcardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var frontText: String
    @State private var backText: String
    var flashcardToEdit: Flashcard?
    init(flashcardToEdit: Flashcard? = nil) {
        self.flashcardToEdit = flashcardToEdit
        _frontText = State(initialValue: flashcardToEdit?.frontText ?? "")
        _backText = State(initialValue: flashcardToEdit?.backText ?? "")
    }

    var body: some View {
        Form {
            TextField("Front Text", text: $frontText)
            TextField("Back Text", text: $backText)
            
            Button(flashcardToEdit == nil ? "Save Flashcard" : "Update Flashcard") {
                if let flashcard = flashcardToEdit {
                    flashcard.frontText = frontText
                    flashcard.backText = backText
                } else {
                    let newFlashcard = Flashcard(frontText: frontText, backText: backText, reviewDate: Date(), status: .notRemembered)
                    modelContext.insert(newFlashcard)
                }
                try? modelContext.save()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle(flashcardToEdit == nil ? "Add New Flashcard" : "Edit Flashcard")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddFlashcardView()
        .modelContainer(for: Flashcard.self)
}
