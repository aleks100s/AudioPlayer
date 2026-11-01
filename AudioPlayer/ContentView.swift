//
//  ContentView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.fileService) private var fileService
    @Environment(\.spotlightService) private var spotlightService
    @Environment(\.playerService) private var playerService
    @Query private var books: [Book]
    @AppStorage(Constants.lastPlayedBookID) private var lastPlayedBookID = ""
    @State private var selectedBook: Book?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var compactColumn: NavigationSplitViewColumn = .sidebar
    @State private var bookToEdit: Book?
    @State private var bookName = ""
    @State private var isEditFieldShown = false
    @State private var bookToDelete: Book?
    @State private var isDeleteWarningShown = false

    var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility, preferredCompactColumn: $compactColumn) {
			BookshelfView(selectedBook: $selectedBook, compactColumn: $compactColumn,
                          showChapters: showChapters, editBook: editBook, deleteBook: deleteBook)
				.navigationSplitViewColumnWidth(min: 280, ideal: 340)
				.background(.linearGradient(
					colors: [
						.cyan.opacity(0.2),
						.purple.opacity(0.2)
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				))
		} detail: {
			NavigationStack {
                Group {
                    if let selectedBook {
                        BookDetailView(book: selectedBook,
                                       editBook: { editBook(selectedBook) },
                                       deleteBook: { deleteBook(selectedBook) })
                        .id(selectedBook.id)
                    } else {
                        ContentUnavailableView(
                            "Выберите книгу",
                            systemImage: "book",
                            description: Text("Выберите книгу в библиотеке, чтобы увидеть сведения о ней")
                        )
                    }
                }
                .background(.linearGradient(
                    colors: [
                        .cyan.opacity(0.2),
                        .purple.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
			}
		}
		.navigationSplitViewStyle(.balanced)
		.modifier(PersistentPlayer())
		.onChange(of: lastPlayedBookID, initial: true) { _, _ in
			selectLastPlayedBook()
		}
		.onChange(of: books.map(\.id), initial: true) { _, _ in
			if selectedBook == nil {
				selectLastPlayedBook()
			}
		}
		.alert("Название книги", isPresented: $isEditFieldShown, presenting: bookToEdit) { book in
			TextField("Название", text: $bookName)
			Button("Готово") {
				book.title = bookName
				spotlightService.deindex(book: book)
				spotlightService.index(book: book)
				modelContext.insert(book)
			}
			.disabled(bookName.isEmpty)
			Button("Отмена", role: .cancel) { }
		}
		.alert("Вы действительно хотите удалить книгу?", isPresented: $isDeleteWarningShown, presenting: bookToDelete) { book in
			Button("Удалить", role: .destructive) {
				do {
					try fileService.deleteBookFiles(book)
					spotlightService.deindex(book: book)
					playerService.removeIfNeeded(book: book)
					if selectedBook?.id == book.id {
						selectedBook = nil
						compactColumn = .sidebar
					}
					modelContext.delete(book)
				} catch {
					Log.error(error.localizedDescription)
				}
			}
			Button("Отмена", role: .cancel) { }
		}
    }

    private func selectLastPlayedBook() {
        guard let id = UUID(uuidString: lastPlayedBookID),
              let book = books.first(where: { $0.id == id }) else { return }
        book.prepareCache()
        selectedBook = book
    }

    private func showChapters(_ book: Book) {
        book.prepareCache()
        selectedBook = book
        compactColumn = .detail
    }

    private func editBook(_ book: Book) {
        bookName = book.title
        bookToEdit = book
        isEditFieldShown = true
    }

    private func deleteBook(_ book: Book) {
        bookToDelete = book
        isDeleteWarningShown = true
    }
}

/// Keeps the playback controls available when the split view changes columns.
private struct PersistentPlayer: ViewModifier {
    @Environment(\.playerService) private var playerService
    @State private var isSliderBusy = false
    @State private var progress: Double = 0
    @State private var isTimerShown = false
    @State private var isPlayerExpanded = false
    @State private var playerDetent: PresentationDetent = .medium
    @State private var timerDetent: PresentationDetent = .large
    @State private var isStopWarningShown = false
    @State private var isFinishedBookShown = false

    func body(content: Content) -> some View {
        playerPlacement(content: content)
            .overlay {
                if isSliderBusy && !isPlayerExpanded {
                    seekIndicator
                }
            }
            .sheet(isPresented: $isPlayerExpanded, onDismiss: {
                isSliderBusy = false
                progress = playerService.currentBook?.currentChapter?.currentTime ?? .zero
            }) {
                expandedPlayer
            }
            .alert("Закрыть плеер?", isPresented: $isStopWarningShown) {
                Button("Закрыть", role: .destructive) {
                    playerService.stopCurrentBook()
                }
                Button("Отмена", role: .cancel) { }
            }
            .alert("Книга прослушана", isPresented: $isFinishedBookShown) {
                Button("Понятно", role: .cancel) { }
            }
            .onChange(of: playerService.currentBook?.isFinished) { oldValue, newValue in
                if oldValue == false && newValue == true {
                    isFinishedBookShown = true
                }
            }
            .sensoryFeedback(.success, trigger: isFinishedBookShown)
            .onChange(of: playerService.currentBook?.currentChapter?.currentTime, initial: true) { _, newValue in
                if !isSliderBusy {
                    progress = newValue ?? .zero
                }
            }
            .onChange(of: playerService.currentBook?.id) { _, newValue in
                if newValue == nil {
                    isTimerShown = false
                    isPlayerExpanded = false
                    isSliderBusy = false
                }
            }
            .onShake {
                if playerService.currentBook != nil {
                    isStopWarningShown = true
                }
            }
    }

    @ViewBuilder
    private func playerPlacement(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.overlay(alignment: .bottom) {
                if playerService.currentBook != nil {
                    GlassMiniPlayerView {
                        playerDetent = .medium
                        isPlayerExpanded = true
                    }
                    .frame(maxWidth: 620)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        } else {
            content.safeAreaInset(edge: .bottom, spacing: 0) {
                if playerService.currentBook != nil {
                    CompactPlayerView(isSliderBusy: $isSliderBusy, progress: $progress) {
                        isTimerShown = true
                    }
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                }
            }
            .sheet(isPresented: $isTimerShown) { timerSheet }
        }
    }

    private var seekIndicator: some View {
        Text(progress.timeString)
            .font(.title2)
            .monospaced()
            .contentTransition(.numericText())
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .allowsHitTesting(false)
    }

    private var expandedPlayer: some View {
        Group {
            if #available(iOS 26.0, *) {
                ExpandedPlayerView(isSliderBusy: $isSliderBusy, progress: $progress) {
                    timerDetent = .large
                    isTimerShown = true
                }
            }
        }
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
        .overlay { if isSliderBusy { seekIndicator } }
        .presentationDetents([.medium], selection: $playerDetent)
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $isTimerShown) { timerSheet }
    }

    private var timerSheet: some View {
        TimerSheetView(
            currentTimer: playerService.sleepTimer,
            onSetTimer: { mode in
                playerService.setSleepTimer(mode: mode)
                isTimerShown = false
            },
            onResetTimer: {
                playerService.resetSleepTimer()
                isTimerShown = false
            }
        )
        .presentationDetents([.medium], selection: $timerDetent)
    }

}
