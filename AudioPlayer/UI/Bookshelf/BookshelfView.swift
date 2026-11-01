//
//  BookshelfView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftData
import SwiftUI
import TipKit

struct BookshelfView: View {
	@Binding var selectedBook: Book?
	@Binding var compactColumn: NavigationSplitViewColumn
	let showChapters: (Book) -> Void
	let editBook: (Book) -> Void
	let deleteBook: (Book) -> Void
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.metaInfoService) private var metaInfoService
	@Environment(\.fileService) private var fileService
	@Environment(\.spotlightService) private var spotlightService
	@Environment(\.playerService) private var playerService
	
	@Query(sort: \Book.title, animation: .default) private var books: [Book]
	
	@State private var isFilePickerPresented = false
	@ScaledMetric(relativeTo: .body) private var expandedPlayerMargin: CGFloat = 90
	
	var body: some View {
		Group {
			if books.isEmpty {
				noContentView
			} else {
				contentView
			}
		}
		.navigationTitle("Мои книги")
		.fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.audio], allowsMultipleSelection: true, onCompletion: { results in
			switch results {
			case .success(let files):
				handle(files: files)
				
			case .failure(let error):
				Log.error(error.localizedDescription)
			}
		})
	}
	
	private var noContentView: some View {
		ContentUnavailableView(
			"Здесь пусто",
			systemImage: "book.circle",
			description: Text("Добавьте аудиокниги, выбрав их в Файлах")
		)
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				Button {
					isFilePickerPresented = true
				} label: {
					Text("Добавить аудиокниги")
				}
			}
		}
	}
	
	private var contentView: some View {
		ScrollView {
			LazyVStack(spacing: 4) {
				TipView(HowToDeleteBookTip())

				ForEach(books) { book in
					BookView(book: book, isSelected: selectedBook?.id == book.id) {
						book.prepareCache()
						selectedBook = book
						compactColumn = .detail
					}
					.onAppear {
						book.prepareCache()
					}
					.contextMenu {
						menuContent(for: book)
					}
				}
			}
			.padding()
		}
		.scrollIndicators(.hidden)
		.contentMargins(.bottom, playerOverlayMargin, for: .scrollContent)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					isFilePickerPresented = true
				} label: {
					Image(systemName: "plus")
				}
				.popoverTip(HowToAddBookTip(), arrowEdge: .top)
			}
		}
	}

	private var playerOverlayMargin: CGFloat {
		if #available(iOS 26.0, *), playerService.currentBook != nil { return expandedPlayerMargin }
		return 0
	}
	
	@ViewBuilder
	private func menuContent(for book: Book) -> some View {
		Button {
			editBook(book)
		} label: {
			Label("Переименовать книгу", systemImage: "pencil")
		}

		Button {
			showChapters(book)
		} label: {
			Label("Показать главы", systemImage: "list.bullet")
		}
		
		Button(role: .destructive) {
			deleteBook(book)
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
				guard !files.isEmpty else {
					Log.error("Массив файлов пуст")
					return
				}
				
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
				
                let book = Book(id: id, title: bookMeta.albumName ?? String(localized: "Неизвестно"), author: bookMeta.artist ?? String(localized: "Без названия"), artworkData: bookMeta.artworkData, chapters: chapters)
				modelContext.insert(book)
				spotlightService.index(book: book)
			} catch {
				Log.error(error.localizedDescription)
			}
		}
	}
}

#if DEBUG
private let bannerId = "demo-banner-yandex"
#else
private let bannerId = "R-M-13884287-1"
#endif
