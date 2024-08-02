//
//  EditImage.swift
//  PhotoSaver
//
//  Created by Rumit Singh Tuteja on 6/8/24.
//

import SwiftUI

struct EditImage: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                
                if let uiimage = UIImage(data: viewModel.photoItem.data) {
                    Image(uiImage: uiimage)
                        .resizable()
                        .scaledToFit()
                }
                
                Section {
                    TextField("Enter name", text: $viewModel.name)
                    TextField("Enter description", text: $viewModel.description)
                }
                
                Section {
                    
                    Button("Save") {
                        viewModel.saveImage()
                        dismiss()
                    }
                    
                    
                    Button("Delete") {
                        viewModel.delete()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
       
    }
    
    init(photo: PhotoItem, onSave: @escaping (PhotoItem) -> (), onDelete: @escaping (PhotoItem) -> ()) {
        self.viewModel = ViewModel(item: photo, onSave: onSave, onDelete: onDelete)
    }
}

extension EditImage {
    
    @Observable
    class ViewModel {
        
        private(set) var photoItem: PhotoItem
        var name: String
        var description: String
        
        private var onSave: (PhotoItem) -> ()
        private var onDelete: (PhotoItem) -> ()

        
        init(item: PhotoItem, onSave: @escaping (PhotoItem) -> (), onDelete: @escaping (PhotoItem) -> ()) {
            self.photoItem = item
            name = item.name
            description = item.description
            self.onSave = onSave
            self.onDelete = onDelete
        }
        
        func saveImage() {
            var item = photoItem
            item.name = name
            item.description = description
            onSave(item)
        }
        
        func delete() {
            onDelete(photoItem)
        }
        
    }
}

#Preview {
    EditImage(photo: PhotoItem(id: UUID(), name: "New Photo", description: "", data: Data()), onSave: {_ in }, onDelete: {_ in })
}
