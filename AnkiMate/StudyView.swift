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
    @State private var currentIndex = 0
    @State private var isAnswerShown = false
    @State private var sessionCompleted = false

    var dueFlashcards: [Flashcard] {
        flashcards.filter { $0.reviewDate <= Date() }
    }

    var progress: Double {
        guard !dueFlashcards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(dueFlashcards.count)
    }

    var body: some View {
        VStack {
            ProgressView(value: progress)
                .padding()
                .accentColor(.green)
                .progressViewStyle(LinearProgressViewStyle())
                .opacity(dueFlashcards.isEmpty ? 0 : 1)

            if sessionCompleted {
                // Session Completion View
                VStack {
                    Text("You've completed all cards for today!")
                        .font(.title)
                        .padding()

                    HStack {
                        Button(action: restartSession) {
                            Text("Restart Session")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }

                        Button(action: {
                            // Action to return to main menu or previous screen
                        }) {
                            Text("Main Menu")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            } else if !dueFlashcards.isEmpty, currentIndex < dueFlashcards.count {
                let currentFlashcard = dueFlashcards[currentIndex]

                VStack {
                    Text(currentFlashcard.frontText)
                        .font(.title)
                        .padding()
                        .transition(.slide)

                    if isAnswerShown {
                        Divider()
                            .padding(.vertical)

                        Text(currentFlashcard.backText)
                            .font(.title2)
                            .padding()
                            .transition(.slide)

                        if let imageData = currentFlashcard.image,
                           let uiImage = UIImage(data: imageData)
                        {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .padding()
                        }

                        // Rating Buttons with Labels
                        HStack(spacing: 10) {
                            ForEach(0 ..< 6) { quality in
                                Button(action: {
                                    updateFlashcardStatus(flashcard: currentFlashcard, quality: quality)
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
                        .padding()
                    } else {
                        Text("Tap to reveal the answer")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .onTapGesture {
                    withAnimation {
                        isAnswerShown.toggle()
                    }
                }

                Spacer()
            } else {
                // No Cards to Study View
                Text("No cards to study")
                    .font(.title)
                    .padding()
            }
        }
        .navigationTitle("Study Mode")
        .onChange(of: currentIndex) { _ in
            isAnswerShown = false
        }
        .onChange(of: dueFlashcards.count) { _ in
            if dueFlashcards.isEmpty {
                sessionCompleted = true
            }
        }
    }

    // MARK: - Helper Functions

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

    private func showNextFlashcard() {
        withAnimation {
            if currentIndex < dueFlashcards.count - 1 {
                currentIndex += 1
            } else {
                sessionCompleted = true
            }
        }
    }

    private func restartSession() {
        currentIndex = 0
        sessionCompleted = false
        isAnswerShown = false
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
