//
//  ContentView.swift
//  PhotoSaver
//
//  Created by Rumit Singh Tuteja on 6/7/24.
//
import PhotosUI
import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ViewModel()
    
    var columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        NavigationStack {
            if !viewModel.pickedImages.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.pickedImages) { img in
                            VStack {
                                Image(uiImage: UIImage(data: img.data) ?? .remove)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(.rect(cornerRadius: 10.0))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .onLongPressGesture {
                                        viewModel.tempSelected = img
                                        viewModel.longPressed = true
                                    }
                                Text(img.name)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        PhotosPicker(selection: $viewModel.pickedItem) {
                            Image(systemName: "photo.badge.plus")
                                .frame(width: 100, height: 100)
                                .scaledToFill()
                        }
                        .onChange(of: viewModel.pickedItem, viewModel.processAndSaveImage)
                    }
                }
                .padding([.bottom, .horizontal])
                .navigationTitle("Photos Library")
                .sheet(item: $viewModel.selectedItem) { image in
                    EditImage(photo: image) { item in
                        viewModel.addImage(item)
                    } onDelete: { item in
                        viewModel.remove(item)
                    }
                }
                .confirmationDialog("Edit picture", isPresented: $viewModel.longPressed) {
                    Button("Edit") {
                        viewModel.selectedItem = viewModel.tempSelected
                    }
                    
                    Button("Delete", role: .destructive) {
                        viewModel.remove(viewModel.tempSelected!)
                    }
                }
                .onAppear {
                    viewModel.loadImages()
                }
                
            } else {
                PhotosPicker(selection: $viewModel.pickedItem) {
                    ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                }
                .navigationTitle("Photos Library")
                .onChange(of: viewModel.pickedItem, viewModel.processAndSaveImage)
                .sheet(item: $viewModel.selectedItem) { image in
                    EditImage(photo: image) { item in
                        viewModel.addImage(item)
                    } onDelete: { item in
                        viewModel.remove(item)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadImages()
        }
    }
}

extension ContentView {
    @Observable
    class ViewModel {
        
        var pickedItem: PhotosPickerItem?
        var selectedItem: PhotoItem?
        var pickedImages = [PhotoItem]()
        var longPressed = false
        var tempSelected: PhotoItem?
        
        private let imagesPath = URL.documentsDirectory.appendingPathComponent("photo-saver-images")
        
        func processAndSaveImage() {
            Task {
                guard let imageData = try await pickedItem?.loadTransferable(type: Data.self) else { return }
                let photoItem = PhotoItem(id: UUID(), name: "Untitled", description: "", data: imageData)
                selectedItem = photoItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.pickedItem = nil
                }
                //                pickedImages.append(photoItem)
            }
        }
        
        func addImage(_ img: PhotoItem) {
            pickedImages.append(img)
            saveImages()
        }
        
        func remove(_ img: PhotoItem) {
            if let index = pickedImages.firstIndex(of: img) {
                pickedImages.remove(at: index)
                saveImages()
            }
        }
        
        func loadImages() {
            do {
                let imagesData = try Data(contentsOf: imagesPath)
                pickedImages = try JSONDecoder().decode([PhotoItem].self, from: imagesData)
            } catch {
                print("Failed to load images: \(error.localizedDescription)")
            }
        }
        
        func saveImages() {
            do {
                let data = try JSONEncoder().encode(pickedImages)
                try data.write(to: imagesPath, options: [.completeFileProtection, .atomic])
            } catch {
                print("Unknown error occured: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
