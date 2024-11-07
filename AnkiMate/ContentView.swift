//
//  ContentView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isAddCardPresented = false
    var body: some View {
        TabView {
            NavigationView {
                FlashcardListView()
                    .navigationTitle("Cards")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isAddCardPresented.toggle()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    .sheet(isPresented: $isAddCardPresented) {
                        AddFlashcardView()
                    }
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Flashcard.self)
}
