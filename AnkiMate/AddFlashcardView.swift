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

    @FocusState private var isTagTextFieldFocused: Bool

    @Query var tags: [Tag]

    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var newTagText = ""
    @State private var selectedTags: Set<Tag> = []
    @State private var image: Data?
    @State private var showSaveSuccess = false
    @State private var selectedImage: PhotosPickerItem?

    @Binding var flashcardToEdit: Flashcard?

    private var filteredTags: [Tag] {
        let filtered = newTagText.isEmpty
            ? tags
            : tags.filter { $0.name.lowercased().contains(newTagText.lowercased()) }

        if filtered.isEmpty {
            return tags
        } else {
            return filtered.sorted { selectedTags.contains($0) && !selectedTags.contains($1) }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Content")) {
                    TextField("Front Text", text: $frontText)
                    TextField("Back Text", text: $backText)
                }

                Section(header: Text("Tags")) {
                    TextField("Write new tag", text: $newTagText, onCommit: addNewTag)
                        .focused($isTagTextFieldFocused)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(flashcardToEdit == nil ? "Save" : "Update") {
                        saveFlashcard()
                    }
                    .disabled(frontText.isEmpty || backText.isEmpty)
                    .animation(.default, value: frontText.isEmpty || backText.isEmpty)
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
        .onAppear {
            if let flashcardToEdit {
                frontText = flashcardToEdit.frontText
                backText = flashcardToEdit.backText
                selectedTags = Set(flashcardToEdit.tags)
                image = flashcardToEdit.image
            }
        }
    }

    private func addNewTag() {
        var trimmedTagName = newTagText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedTagName.hasPrefix("#") {
            trimmedTagName = "#" + trimmedTagName
        }
        guard !trimmedTagName.isEmpty, trimmedTagName != "#" else {
            return
        }

        if let existingTag = tags.first(where: { $0.name == trimmedTagName }) {
            selectedTags.insert(existingTag)
        } else {
            let newTag = Tag(name: trimmedTagName)
            modelContext.insert(newTag)
            selectedTags.insert(newTag)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            newTagText = ""
            isTagTextFieldFocused = false
        }
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
            let newFlashcard = Flashcard(
                frontText: frontText,
                backText: backText,
                tags: tags,
                image: image,
                reviewDate: .now
            )
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
    AddFlashcardView(flashcardToEdit: .constant(nil))
        .modelContainer(for: Flashcard.self)
}
