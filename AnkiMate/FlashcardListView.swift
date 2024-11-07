//
//  FlashcardListView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import SwiftUI
import SwiftData

struct FlashcardListView: View {
    @Query var flashcards: [Flashcard]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTag: String?
    @State private var showRememberedOnly = false
    @State private var searchText = "" // Для хранения текста поиска
    
    // Словарь для хранения случайного цвета для каждого тега
    @State private var tagColors: [String: Color] = [:]
    
    // Уникальные теги из всех карточек
    private var uniqueTags: [String] {
        Array(Set(flashcards.flatMap { $0.tags })).sorted()
    }
    
    var body: some View {
        List(filteredFlashcards()) { flashcard in
            VStack(alignment: .leading, spacing: 8) {
                Text(flashcard.frontText)
                    .font(.headline)
                
                Text(flashcard.backText)
                    .font(.subheadline)
                
                // Отображение тегов карточки
                HStack {
                    ForEach(flashcard.tags, id: \.self) { tag in
                        TagView(tag: tag, color: colorForTag(tag))
                    }
                }
            }
            .padding(.vertical, 5)
            .swipeActions(edge: .trailing) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(flashcard)
                    try? modelContext.save()
                }
            }
        }
        .navigationTitle("Flashcards")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button("All Tags") { selectedTag = nil }
                    Divider()
                    ForEach(uniqueTags, id: \.self) { tag in
                        Button(tag) { selectedTag = tag }
                    }
                } label: {
                    Label("Tags", systemImage: "tag")
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Toggle("Not Remembered Only", isOn: $showRememberedOnly)
            }
        }
        .onAppear {
            generateTagColors()
        }
        .searchable(text: $searchText, prompt: "Search flashcards") // Добавляем поисковую строку
    }
    
    // Метод для получения цвета тега
    private func colorForTag(_ tag: String) -> Color {
        if let color = tagColors[tag] {
            return color
        } else {
            let color = Color(
                red: Double.random(in: 0.5...1.0),
                green: Double.random(in: 0.5...1.0),
                blue: Double.random(in: 0.5...1.0)
            )
            tagColors[tag] = color
            return color
        }
    }
    
    private func generateTagColors() {
        uniqueTags.forEach { tag in
            if tagColors[tag] == nil {
                tagColors[tag] = Color(
                    red: Double.random(in: 0.5...1.0),
                    green: Double.random(in: 0.5...1.0),
                    blue: Double.random(in: 0.5...1.0)
                )
            }
        }
    }
    
    private func filteredFlashcards() -> [Flashcard] {
        var filtered = flashcards
        
        // Фильтрация по статусу
        if showRememberedOnly {
            filtered = filtered.filter { $0.status == .notRemembered }
        }
        
        // Фильтрация по тегу
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        
        // Фильтрация по поисковому тексту
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.frontText.localizedCaseInsensitiveContains(searchText) ||
                $0.backText.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
}

#Preview {
    FlashcardListView()
        .modelContainer(for: Flashcard.self)
}
