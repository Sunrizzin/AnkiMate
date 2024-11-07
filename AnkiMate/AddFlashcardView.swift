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
    @Environment(\.dismiss) private var dismiss // Для закрытия модального окна
    @State private var frontText: String = ""
    @State private var backText: String = ""
    
    var body: some View {
        Form {
            TextField("Front Text", text: $frontText)
            TextField("Back Text", text: $backText)
            
            Button("Save Flashcard") {
                let newFlashcard = Flashcard(frontText: frontText, backText: backText, reviewDate: Date(), status: .notRemembered)
                modelContext.insert(newFlashcard)
                try? modelContext.save()
                dismiss() // Закрытие модального окна
            }
        }
        .navigationTitle("Add New Flashcard")
    }
}

#Preview {
    AddFlashcardView()
        .modelContainer(for: Flashcard.self)
}
