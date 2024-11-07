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
    var tags: [Tag]
    var image: Data?
    var reviewDate: Date
    var status: ReviewStatus

    enum ReviewStatus: String, Codable {
        case remembered
        case notRemembered
    }

    init(frontText: String, backText: String, tags: [Tag] = [], image: Data? = nil, reviewDate: Date = Date(), status: ReviewStatus = .notRemembered) {
        self.frontText = frontText
        self.backText = backText
        self.tags = tags
        self.image = image
        self.reviewDate = reviewDate
        self.status = status
    }
}

@Model
final class Tag {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String

    init(name: String) {
        self.name = name
    }
}
