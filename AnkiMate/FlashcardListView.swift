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
    @State private var selectedTag: Tag? // Теперь это Tag, а не String
    @State private var showRememberedOnly = false
    @State private var searchText = ""
    
    // Словарь для хранения случайного цвета для каждого тега
    @State private var tagColors: [UUID: Color] = [:] // Используем UUID тега в качестве ключа
    
    // Уникальные теги из всех карточек
    private var uniqueTags: [Tag] {
        Array(Set(flashcards.flatMap { $0.tags })).sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List {
            ForEach(filteredFlashcards()) { flashcard in
                VStack(alignment: .leading, spacing: 8) {
                    Text(flashcard.frontText)
                        .font(.headline)
                    
                    Text(flashcard.backText)
                        .font(.subheadline)
                    
                    // Отображение тегов карточки с выделением выбранных тегов
                    HStack {
                        ForEach(flashcard.tags, id: \.id) { tag in
                            TagView(tag: tag.name, isSelected: selectedTag == tag)
                                .onTapGesture {
                                    // Устанавливаем или убираем выбранный тег
                                    selectedTag = (selectedTag == tag) ? nil : tag
                                }
                        }
                    }
                }
                .padding(.vertical, 5)
                .swipeActions(edge: .trailing) {
                    Button("Delete", role: .destructive) {
                        deleteFlashcard(flashcard)
                    }
                }
            }
        }
        .navigationTitle("Flashcards")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button("All Tags") { selectedTag = nil }
                    Divider()
                    ForEach(uniqueTags, id: \.id) { tag in
                        Button(tag.name) { selectedTag = tag }
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
        .searchable(text: $searchText, prompt: "Search flashcards")
    }
    
    // Метод для удаления карточки
    private func deleteFlashcard(_ flashcard: Flashcard) {
        modelContext.delete(flashcard)
        try? modelContext.save()
    }
    
    private func generateTagColors() {
        uniqueTags.forEach { tag in
            if tagColors[tag.id] == nil {
                tagColors[tag.id] = Color(
                    red: Double.random(in: 0.5...1.0),
                    green: Double.random(in: 0.5...1.0),
                    blue: Double.random(in: 0.5...1.0)
                )
            }
        }
    }
    
    private func filteredFlashcards() -> [Flashcard] {
        var filtered = flashcards
        
        if showRememberedOnly {
            filtered = filtered.filter { $0.status == .notRemembered }
        }
        
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        
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
