//
//  AnkiMateApp.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI
import SwiftData

@main
struct AnkiMateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Flashcard.self)
        }
    }
}
