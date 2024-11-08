//
//  StudyView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftData
import SwiftUI

struct StudyView: View {
    @Query(sort: \Flashcard.reviewDate, order: .forward) var flashcards: [Flashcard]
    @Environment(\.modelContext) private var modelContext

    // State variables
    @State private var sessionFlashcards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var isAnswerShown = false
    @State private var sessionStarted = false
    @State private var sessionCompleted = false

    // Computed properties
    var dueFlashcards: [Flashcard] {
        flashcards.filter { $0.reviewDate <= Date() }
    }

    var totalCards: Int {
        sessionFlashcards.count
    }

    var body: some View {
        VStack {
            if !sessionStarted {
                // Initial State
                if dueFlashcards.isEmpty {
                    // No cards available
                    Text("You've completed all cards for today!")
                        .font(.title)
                        .padding()
                } else {
                    // Cards are available
                    Text("Cards available to study: \(dueFlashcards.count)")
                        .font(.title2)
                        .padding()

                    Button(action: startSession) {
                        Text("Start Session")
                            .font(.headline)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            } else if sessionCompleted {
                // Session Completed
                Text("You've completed all cards for today!")
                    .font(.title)
                    .padding()

                Button(action: restartSession) {
                    Text("Restart Session")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            } else {
                // Session In Progress
                VStack {
                    // Current card number
                    Text("Card \(currentIndex + 1) of \(totalCards)")
                        .font(.headline)
                        .padding()

                    // Flashcard content
                    VStack {
                        Text(sessionFlashcards[currentIndex].frontText)
                            .font(.title)
                            .padding()
                            .onTapGesture {
                                withAnimation {
                                    isAnswerShown.toggle()
                                }
                            }

                        if isAnswerShown {
                            Divider()
                                .padding(.vertical)

                            Text(sessionFlashcards[currentIndex].backText)
                                .font(.title2)
                                .padding()

                            if let imageData = sessionFlashcards[currentIndex].image,
                               let uiImage = UIImage(data: imageData)
                            {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .padding()
                            }

                            // Rating Buttons
                            HStack(spacing: 10) {
                                ForEach(0 ..< 6) { quality in
                                    Button(action: {
                                        updateFlashcardStatus(flashcard: sessionFlashcards[currentIndex], quality: quality)
                                        provideHapticFeedback()
                                        showNextFlashcard()
                                    }) {
                                        VStack {
                                            Text("\(quality)")
                                                .font(.headline)
                                            Text(ratingLabel(for: quality))
                                                .font(.caption)
                                        }
                                        .frame(width: 60, height: 60)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        } else {
                            Text("Tap to reveal the answer")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("Study Mode")
        .onAppear {
            if dueFlashcards.isEmpty {
                sessionCompleted = true
            }
        }
    }

    // MARK: - Helper Functions

    private func startSession() {
        sessionFlashcards = dueFlashcards
        currentIndex = 0
        isAnswerShown = false
        sessionStarted = true
        sessionCompleted = sessionFlashcards.isEmpty
    }

    private func showNextFlashcard() {
        withAnimation {
            isAnswerShown = false
            if currentIndex < sessionFlashcards.count - 1 {
                currentIndex += 1
            } else {
                sessionCompleted = true
            }
        }
    }

    private func restartSession() {
        sessionStarted = false
        sessionCompleted = false
        currentIndex = 0
        isAnswerShown = false
    }

    private func updateFlashcardStatus(flashcard: Flashcard, quality: Int) {
        // Implementation of SM-2 Algorithm
        let minEF = 1.3
        var ef = flashcard.easinessFactor
        var repetitions = flashcard.repetitions
        var interval = flashcard.interval

        if quality >= 3 {
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * ef)
            }
            repetitions += 1
        } else {
            repetitions = 0
            interval = 1
        }

        ef = ef + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        ef = max(minEF, ef)

        flashcard.easinessFactor = ef
        flashcard.repetitions = repetitions
        flashcard.interval = interval
        flashcard.reviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()

        try? modelContext.save()
    }

    private func ratingLabel(for quality: Int) -> String {
        switch quality {
        case 0: "Again"
        case 1: "Hard"
        case 2: "Okay"
        case 3: "Good"
        case 4: "Easy"
        case 5: "Perfect"
        default: ""
        }
    }

    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    StudyView()
        .modelContainer(for: Flashcard.self)
}
