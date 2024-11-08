//
//  ContentView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                FlashcardListView()
                    .navigationTitle("Cards")
            }
            .tabItem {
                Label("Cards", systemImage: "list.bullet.circle")
            }

            NavigationView {
                StudyView()
                    .navigationTitle("Study")
            }
            .tabItem {
                Label("Study", systemImage: "book.circle")
            }
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Flashcard.self)
}
