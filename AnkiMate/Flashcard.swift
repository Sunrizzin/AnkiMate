//
//  Flashcard.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import Foundation
import SwiftData

@Model
final class Flashcard {
    @Attribute(.unique) var id: UUID = UUID()
    var frontText: String
    var backText: String
    var tags: [Tag] = []
    var image: Data?
    var reviewDate: Date
    var easinessFactor: Double
    var interval: Int
    var repetitions: Int

    init(frontText: String, backText: String, tags: [Tag] = [], image: Data? = nil, reviewDate: Date = Date(), easinessFactor: Double = 2.5, interval: Int = 0, repetitions: Int = 0) {
        self.frontText = frontText
        self.backText = backText
        self.tags = tags
        self.image = image
        self.reviewDate = reviewDate
        self.easinessFactor = easinessFactor
        self.interval = interval
        self.repetitions = repetitions
    }
}

@Model
final class Tag {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var flashcards: [Flashcard] = []

    init(name: String) {
        self.name = name
    }
}
