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
    
    var progress: Double {
        guard !flashcards.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(flashcards.count)
    }

    var body: some View {
        VStack {
            ProgressView(value: progress)
                .padding()
                .accentColor(.green)
                .progressViewStyle(LinearProgressViewStyle())
            
            if !flashcards.isEmpty {
                let currentFlashcard = flashcards[currentIndex]
                
                Text(isAnswerShown ? currentFlashcard.backText : currentFlashcard.frontText)
                    .font(.title)
                    .padding()
                    .transition(.slide) // Анимация при смене карточки
                
                Spacer()
                
                Button(isAnswerShown ? "Hide Answer" : "Show Answer") {
                    withAnimation {
                        isAnswerShown.toggle()
                    }
                }
                .padding(.bottom, 20)
                
                HStack {
                    Button("Forgot") {
                        updateFlashcardStatus(currentFlashcard, remembered: false)
                        showNextFlashcard()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button("Remembered") {
                        updateFlashcardStatus(currentFlashcard, remembered: true)
                        showNextFlashcard()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                Text("No cards to study")
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
        withAnimation {
            if currentIndex < flashcards.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }
}

#Preview {
    StudyView()
        .modelContainer(for: Flashcard.self)
}
