//
//  ChaptersListView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI
import TipKit

struct ChaptersListView: View {
	let book: Book
	
	@State private var isFilePickerPresented = false
	@State private var refreshId = UUID()
	@State private var isEditChapterAlertShown = false
	@State private var chapterToEdit: Chapter?
	@State private var chapterName = ""

	@Environment(\.modelContext) private var modelContext
	@Environment(\.playerService) private var playerService
	@Environment(\.fileService) private var fileService
	@Environment(\.metaInfoService) private var metaInfoService
	@Environment(\.spotlightService) private var spotlightService
	
	private var isPlaying: Bool {
		playerService.isPlaying
	}
	
	private var currentChapter: Chapter? {
		playerService.currentBook?.currentChapter
	}
	
	var body: some View {
		NavigationView {
			List {
				TipView(HowToMarkChapterTip())
				
				ForEach(book.orderedChapters) { chapter in
					let isCurrentChapter = currentChapter == chapter
					ChapterView(
						chapter: chapter,
						hasCheckmark: chapter.isListened || book.isFinished,
						isCurrentChapter: isCurrentChapter,
						isCurrentlyPlaying: isCurrentChapter && isPlaying,
						onTap: { select(chapter: chapter) }
					)
					.contextMenu {
						Button {
							isEditChapterAlertShown = true
							chapterToEdit = chapter
							chapterName = chapter.name
						} label: {
							Label("Переименовать главу", systemImage: "pencil")
						}
					}
					.swipeActions(edge: .leading) {
						Button(chapter.isListened ? "Отметить непрослушанным" : "Отметить прослушанным") {
							chapter.isListened.toggle()
							book.trackProgress()
						}
						.tint(.green)
						.sensoryFeedback(.success, trigger: chapter.isListened)
					}
				}
			}
			.id(refreshId)
			.navigationTitle("Список глав")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						isFilePickerPresented = true
					} label: {
						Image(systemName: "plus")
					}
					.popoverTip(HowToAddChaptersTip(), arrowEdge: .top)
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
			.alert("Название главы", isPresented: $isEditChapterAlertShown, presenting: chapterToEdit) { chapter in
				TextField("Название", text: $chapterName)
				
				Button("Готово") {
					isEditChapterAlertShown = false
					chapter.name = chapterName
					modelContext.insert(chapter)
				}
				.disabled(chapter.name.isEmpty)
				
				Button(role: .cancel) {
					isEditChapterAlertShown = false
				} label: {
					Text("Отмена")
				}
			}
		}
	}
	
	private func select(chapter: Chapter) {
		do {
			try playerService.setupAndPlayAudio(book: book, chapter: chapter, resetProgress: chapter != currentChapter)
		} catch {
			Log.error(error.localizedDescription)
		}
	}
	
	private func handle(files: [URL]) {
		guard !files.isEmpty else {
			Log.error("Массив файлов пуст")
			return
		}
		
		Task {
			do {
				let id = book.id
				let files = try fileService.saveBookFiles(files, id: id)
				guard !files.isEmpty else {
					Log.error("Массив файлов пуст")
					return
				}
				
				var chapters = [Chapter]()
				let initialChaptersCount = book.orderedChapters.count
				for (index, file) in files.enumerated() {
					guard let chapterMeta = try await metaInfoService.extractChapterMetadata(from: file) else {
						Log.error("Проблема с обработкой файла \(file.absoluteString)")
						continue
					}
					
					let chapter = Chapter(name: chapterMeta.title, duration: chapterMeta.duration, urlLastPathComponent: file.lastPathComponent, artworkData: chapterMeta.artworkData, order: initialChaptersCount + index)
					chapters.append(chapter)
				}
				
				book.append(chapters: chapters)
				modelContext.insert(book)
				spotlightService.index(book: book)
				book.prepareCache()
				await MainActor.run {
					refreshId = UUID()
				}
			} catch {
				Log.error(error.localizedDescription)
			}
		}
	}
}
