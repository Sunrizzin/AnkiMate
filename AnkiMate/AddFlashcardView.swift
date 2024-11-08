//
//  AddFlashcardView.swift
//  AnkiMate
//
//  Created by Sunrizz on 7/11/24.
//

import PhotosUI
import SwiftData
import SwiftUI

struct AddFlashcardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query var tags: [Tag]

    @State private var frontText: String
    @State private var backText: String
    @State private var newTagText = ""
    @State private var selectedTags: Set<Tag> = []
    @State private var image: Data?
    @State private var showSaveSuccess = false
    @State private var selectedImage: PhotosPickerItem?

    var flashcardToEdit: Flashcard?

    private var filteredTags: [Tag] {
        let filtered = newTagText.isEmpty
            ? tags
            : tags.filter { $0.name.lowercased().contains(newTagText.lowercased()) }

        return filtered.sorted { selectedTags.contains($0) && !selectedTags.contains($1) }
    }

    init(flashcardToEdit: Flashcard? = nil) {
        self.flashcardToEdit = flashcardToEdit
        _frontText = State(initialValue: flashcardToEdit?.frontText ?? "")
        _backText = State(initialValue: flashcardToEdit?.backText ?? "")
        _selectedTags = State(initialValue: Set(flashcardToEdit?.tags ?? []))
        _image = State(initialValue: flashcardToEdit?.image)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Content")) {
                    TextField("Front Text", text: $frontText)
                        .focusable()
                    TextField("Back Text", text: $backText)
                }

                Section(header: Text("Tags")) {
                    TextField("Write new tag", text: $newTagText, onCommit: addNewTag)
                        .textInputAutocapitalization(.never)
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(filteredTags, id: \.id) { tag in
                                    TagView(tag: tag.name, isSelected: selectedTags.contains(tag))
                                        .onTapGesture {
                                            toggleTagSelection(tag)
                                        }
                                }
                                .animation(.interactiveSpring, value: newTagText)
                            }
                        }
                    }
                }

                Section(header: Text("Image")) {
                    PhotosPicker("Select Image", selection: $selectedImage, matching: .images)
                        .onChange(of: selectedImage) { newItem, _ in
                            if let newItem {
                                loadImage(from: newItem)
                            }
                        }

                    if let imageData = image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle(flashcardToEdit == nil ? "Add New Flashcard" : "Edit Flashcard")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(flashcardToEdit == nil ? "Save" : "Update") {
                        saveFlashcard()
                    }
                    .disabled(frontText.isEmpty || backText.isEmpty)
                }
            }
            .alert("Flashcard Saved!", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
                Button("Add Next") {
                    clearFieldsForNextEntry()
                }
            } message: {
                Text("Your flashcard has been successfully \(flashcardToEdit == nil ? "saved" : "updated").")
            }
        }
    }

    private func addNewTag() {
        var trimmedTagName = newTagText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedTagName.hasPrefix("#") {
            trimmedTagName = "#" + trimmedTagName
        }

        guard !trimmedTagName.isEmpty else { return }

        if let existingTag = tags.first(where: { $0.name == trimmedTagName }) {
            selectedTags.insert(existingTag)
        } else {
            let newTag = Tag(name: trimmedTagName)
            modelContext.insert(newTag)
            selectedTags.insert(newTag)
        }
        newTagText = ""
    }

    private func toggleTagSelection(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func saveFlashcard() {
        let tags = Array(selectedTags)

        if let flashcard = flashcardToEdit {
            flashcard.frontText = frontText
            flashcard.backText = backText
            flashcard.tags = tags
            flashcard.image = image
        } else {
            let newFlashcard = Flashcard(frontText: frontText, backText: backText, tags: tags, image: image, reviewDate: Date(), status: .notRemembered)
            modelContext.insert(newFlashcard)
        }

        try? modelContext.save()
        showSaveSuccess = true
    }

    private func clearFieldsForNextEntry() {
        frontText = ""
        backText = ""
        selectedTags = []
        newTagText = ""
        image = nil
    }

    private func loadImage(from pickerItem: PhotosPickerItem) {
        Task {
            if let data = try? await pickerItem.loadTransferable(type: Data.self) {
                image = data
            }
        }
    }
}

#Preview {
    AddFlashcardView()
        .modelContainer(for: Flashcard.self)
}
