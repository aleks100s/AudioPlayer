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
	@AppStorage(Constants.playbackRate) private var rate: Double = 1
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.metaInfoService) private var metaInfoService
	@Environment(\.fileService) private var fileService
	@Environment(\.spotlightService) private var spotlightService
	@Environment(\.playerService) private var playerService
	
	@Query(animation: .default) private var books: [Book]
	
	@State private var isFilePickerPresented = false
	@State private var isSliderBusy: Bool = false
	@State private var progress: Double = 0
	@State private var isFinishedBookShown = false
	@State private var bookToShowDetail: Book?
	@State private var bookToShowChapters: Book?
	@State private var isStopWarningShown = false
	@State private var isEditFieldShown = false
	@State private var bookToEdit: Book?
	@State private var bookName = ""
	@State private var isDeleteWarningShown: Bool = false
	@State private var bookToDelete: Book?
    @State private var isTimerShown = false
	
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
		.sheet(item: $bookToShowDetail) { book in
			BookDetailView(book: book)
		}
		.sheet(item: $bookToShowChapters) { book in
			ChaptersListView(book: book)
		}
        .sheet(isPresented: $isTimerShown) {
            TimerSheetView(
                currentTimer: playerService.sleepTimer,
                onSetTimer: { mode in
                    playerService.setSleepTimer(mode: mode)
                    isTimerShown = false
                }, onResetTimer: {
                    playerService.resetSleepTimer()
                    isTimerShown = false
                }
            )
            .presentationDetents([.medium])
        }
		.alert("Книга прослушана", isPresented: $isFinishedBookShown) {
			Button(role: .cancel) {
				isFinishedBookShown = false
			} label: {
				Text("Понятно")
			}
		}
		.alert("Закрыть плеер?", isPresented: $isStopWarningShown) {
			Button(role: .destructive) {
				playerService.stopCurrentBook()
			} label: {
				Text("Закрыть")
			}

			Button(role: .cancel) {
				isStopWarningShown = false
			} label: {
				Text("Отмена")
			}
		}
		.alert("Название книги", isPresented: $isEditFieldShown, presenting: bookToEdit) { book in
			TextField("Название", text: $bookName)
			
			Button("Готово") {
				isEditFieldShown = false
				book.title = bookName
				spotlightService.deindex(book: book)
				spotlightService.index(book: book)
				modelContext.insert(book)
			}
			.disabled(bookName.isEmpty)
			
			Button(role: .cancel) {
				isEditFieldShown = false
			} label: {
				Text("Отмена")
			}
		}
		.alert("Вы действительно хотите удалить книгу?", isPresented: $isDeleteWarningShown) {
			Button(role: .destructive) {
				do {
					if let book = bookToDelete {
						try fileService.deleteBookFiles(book)
						spotlightService.deindex(book: book)
						playerService.removeIfNeeded(book: book)
						modelContext.delete(book)
					}
				} catch {
					Log.error(error.localizedDescription)
				}
			} label: {
				Text("Удалить")
			}

			Button(role: .cancel) {
				isDeleteWarningShown = false
			} label: {
				Text("Отмена")
			}
		}
		.onChange(of: playerService.currentBook?.currentChapter?.currentTime, initial: true) { oldValue, newValue in
			if !isSliderBusy {
				progress = newValue ?? .zero
			}
		}
		.onShake {
			if playerService.currentBook != nil {
				isStopWarningShown = true
			}
		}
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
		ZStack {
			VStack(spacing: .zero) {
				ScrollView {
					LazyVStack(spacing: 16) {
						TipView(HowToDeleteBookTip())
						
						ForEach(books) { book in
							BookView(book: book) {
								bookToShowChapters = book
							} onTapInfoButton: {
								bookToShowDetail = book
							}
							.onAppear {
								book.prepareCache()
							}
							.contextMenu {
								menuContent(for: book)
							}
							.sensoryFeedback(.success, trigger: book.isFinished)
							.onChange(of: book.isFinished) { oldValue, newValue in
								if newValue, !oldValue {
									isFinishedBookShown = true
								}
							}
						}
					}
					.padding()
				}
				.scrollIndicators(.hidden)
				
				if playerService.currentBook != nil {
					CompactPlayerView(isSliderBusy: $isSliderBusy, progress: $progress) {
						isTimerShown = true
					}
				}
				
				AdBannerView(bannerId: bannerId)
			}
			
			if isSliderBusy {
				VStack {
					Text(progress.timeString)
						.font(.title2)
						.monospaced()
						.contentTransition(.numericText())
						.padding(.horizontal, 16)
						.padding(.vertical, 32)
						.background(.regularMaterial)
						.clipShape(RoundedRectangle(cornerRadius: 16))
				}
			}
		}
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
	
	@ViewBuilder
	private func menuContent(for book: Book) -> some View {
		Button {
			bookName = book.title
			bookToEdit = book
			isEditFieldShown = true
		} label: {
			Label("Переименовать книгу", systemImage: "pencil")
		}

		Button {
			bookToShowChapters = book
		} label: {
			Label("Показать главы", systemImage: "list.bullet")
		}
		
		Button(role: .destructive) {
			bookToDelete = book
			isDeleteWarningShown = true
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
