//
//  StudyView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI
import SwiftData

struct StudyView: View {
    @Query(sort: \Flashcard.reviewDate, order: .forward) var flashcards: [Flashcard]
    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex = 0
    @State private var isAnswerShown = false
    
    var body: some View {
        VStack {
            if !flashcards.isEmpty {
                let currentFlashcard = flashcards[currentIndex]
                
                Text(isAnswerShown ? currentFlashcard.backText : currentFlashcard.frontText)
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button(isAnswerShown ? "Hide Answer" : "Show Answer") {
                    isAnswerShown.toggle()
                }
                .padding(.bottom, 20)
                
                HStack {
                    Button("Не помню") {
                        updateFlashcardStatus(currentFlashcard, remembered: false)
                        showNextFlashcard()
                    }
                    .padding()
                    
                    Button("Помню") {
                        updateFlashcardStatus(currentFlashcard, remembered: true)
                        showNextFlashcard()
                    }
                    .padding()
                }
            } else {
                Text("Нет карточек для изучения")
            }
        }
        .navigationTitle("Study Mode")
        .onChange(of: currentIndex) {
            isAnswerShown = false
        }
    }
    
    private func updateFlashcardStatus(_ flashcard: Flashcard, remembered: Bool) {
        flashcard.status = remembered ? .remembered : .notRemembered
        flashcard.reviewDate = remembered ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date() : Date()
        
        try? modelContext.save()
    }
    
    private func showNextFlashcard() {
        if currentIndex < flashcards.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
}

#Preview {
    StudyView()
        .modelContainer(for: Flashcard.self)
}
