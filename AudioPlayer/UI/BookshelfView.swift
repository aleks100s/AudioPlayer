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
	@Environment(\.fileService) private var fileService
	@Environment(\.spotlightService) private var spotlightService
	@Environment(\.playerService) private var playerService
	
	@Query(animation: .default) private var books: [Book]
	
	@State private var isFilePickerPresented = false
	
	var body: some View {
		ScrollView {
			LazyVStack(spacing: 16) {
				ForEach(books) { book in
					BookView(book: book)
						.onTapGesture {
							// open the book
						}
						.contextMenu {
							menuContent(for: book)
						}
				}
			}
			.padding()
		}
		.scrollIndicators(.hidden)
		.safeAreaInset(edge: .bottom) {
			if playerService.currentBook != nil {
				CompactPlayerView()
			}
		}
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
		.navigationTitle("Мои книги")
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
			Label("Показать главы", systemImage: "list.bullet")
		}
		
		Button(role: .destructive) {
			Task {
				do {
					try fileService.deleteBookFiles(book)
					spotlightService.deindex(book: book)
					playerService.remove(book: book)
					modelContext.delete(book)
				} catch {
					Log.error(error.localizedDescription)
				}
			}
		} label: {
			Label("Удалить книгу", systemImage: "trash")
		}
	}
	
	private func handle(files: [URL]) {
		guard !files.isEmpty else {
			Log.error("Массив файлов пуст")
			return
		}
		
		Task {
			do {
				let id = UUID()
				let files = try fileService.saveBookFiles(files, id: id)
				
				var chapters = [Chapter]()
				for (index, file) in files.enumerated() {
					guard let chapterMeta = try await metaInfoService.extractChapterMetadata(from: file) else {
						Log.error("Проблема с обработкой файла \(file.absoluteString)")
						continue
					}
					
					let chapter = Chapter(name: chapterMeta.title, duration: chapterMeta.duration, urlLastPathComponent: file.lastPathComponent, artworkData: chapterMeta.artworkData, order: index)
					chapters.append(chapter)
				}
				
				guard let bookMeta = try await metaInfoService.extractBookMetadata(from: files.first) else {
					Log.debug("Не удалось извлечь информацию о книге")
				return
				}
				
				let book = Book(id: id, title: bookMeta.albumName, author: bookMeta.artist, chapters: chapters)
				modelContext.insert(book)
				spotlightService.index(book: book)
			} catch {
				Log.error(error.localizedDescription)
			}
		}
	}
}
