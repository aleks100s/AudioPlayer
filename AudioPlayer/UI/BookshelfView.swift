//
//  BookshelfView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftData
import SwiftUI

struct BookshelfView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.metaInfoService) private var metaInfoService
	
	@Query(animation: .default) private var books: [Book]
	
	@State private var isFilePickerPresented = false
	
	var body: some View {
		ZStack {
			ScrollView {
				LazyVStack(spacing: 16) {
					ForEach(books) { book in
						// let isPlaying = viewStore.currentBook == book && viewStore.playerState == .playing
						BookView(book: book, isPlaying: false) {
							menuContent(for: book)
						}
						.highPriorityGesture(
							TapGesture()
								.onEnded { _ in
									// viewStore.send(.bookTapped(book))
								}
						)
						.contextMenu {
							menuContent(for: book)
						}
					}
					
					Spacer()
						.frame(height: 176)
				}
				.padding()
			}
			.scrollIndicators(.hidden)
			
//			if viewStore.playerState != .hidden {
//				VStack {
//					Spacer()
//					playerView(viewStore)
//				}
//			}
			
//			if let time = viewStore.sliderProgress {
//				VStack {
//					Text(time)
//						.font(.title2)
//						.monospaced()
//						.padding(.horizontal, 16)
//						.padding(.vertical, 32)
//						.background(.regularMaterial)
//						.clipShape(RoundedRectangle(cornerRadius: 16))
//					
//					Spacer()
//						.frame(height: 50)
//				}
//			}
		}
		.navigationTitle("Мои книги")
		.onFirstAppear {
			// viewStore.send(.viewDidLoad)
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					isFilePickerPresented = true
				} label: {
					Image(systemName: "plus.circle")
				}
			}
		}
		.fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.audio], allowsMultipleSelection: true, onCompletion: { results in
			switch results {
			case .success(let files):
				handle(files: files)
				
			case .failure(let error):
				Log.error(error.localizedDescription)
			}
		})
	}
	
	@ViewBuilder
	private func menuContent(for book: Book) -> some View {
		Button {
			// store.send(.bookOpened(book))
		} label: {
			Label("Показать главы", systemImage: "list")
		}
		
		Button(role: .destructive) {
			// store.send(.deleteBook(book))
		} label: {
			Label("Удалить книгу", systemImage: "trash")
		}
	}
	
	private func handle(files: [URL]) {
		guard !files.isEmpty, files.first?.startAccessingSecurityScopedResource() == true else { return }
		
		Task {
			do {
				let bookTitle = try await metaInfoService.extractAlbumName(from: files.first)
				if bookTitle == nil {
					Log.error("Не удалось извлечь название книги")
				}
				
				let author = try await metaInfoService.extractAuthor(from: files.first)
				if author == nil {
					Log.error("Не удалось извлечь автора")
				}
				
				var chapters = [Chapter]()
				for file in files {
					guard file.startAccessingSecurityScopedResource() else {
						continue
					}
					
					let data = try await metaInfoService.extractArtwork(from: file)
					let name = try await metaInfoService.extractTitle(from: file) ?? file.lastPathComponent
					let chapter = Chapter(name: name, url: file, artworkData: data)
					chapters.append(chapter)
				}
				
				let book = Book(title: bookTitle ?? "-", author: author ?? "-", chapters: chapters)
				modelContext.insert(book)
			} catch {
				Log.error(error.localizedDescription)
			}
		}
	}
}
