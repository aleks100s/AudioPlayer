//
//  BookDetailView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI
import TipKit

struct BookDetailView: View {
	let book: Book
	let editBook: () -> Void
	let deleteBook: () -> Void

	@AppStorage(Constants.playbackRate) private var rate: Double = 1
	@State private var isFilePickerPresented = false
	@Environment(\.playerService) private var playerService

	private var isPlaying: Bool {
		playerService.currentBook == book && playerService.isPlaying
	}

	private var playbackTitle: String {
		book.isFinished ? "Слушать заново" : isPlaying ? "Пауза" : "Воспроизвести"
	}

	private var playbackSymbol: String {
		book.isFinished ? "arrow.counterclockwise" : isPlaying ? "pause.fill" : "play.fill"
	}

	var body: some View {
		List {
			bookOverview
				.listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 24, trailing: 20))
				.listRowSeparator(.hidden)
				.listRowBackground(Color.clear)

			ChaptersListView(book: book, isFilePickerPresented: $isFilePickerPresented)
		}
		.listStyle(.plain)
		.navigationTitle("О книге")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					isFilePickerPresented = true
				} label: {
					Label("Добавить главы", systemImage: "plus")
				}
				.popoverTip(HowToAddChaptersTip(), arrowEdge: .top)
			}
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: editBook) {
						Label("Переименовать книгу", systemImage: "pencil")
					}
					Button(role: .destructive, action: deleteBook) {
						Label("Удалить книгу", systemImage: "trash")
					}
				} label: {
					Label("Действия с книгой", systemImage: "ellipsis")
				}
			}
		}
	}

	private var bookOverview: some View {
		VStack(spacing: 20) {
			Image(uiImage: book.image)
				.resizable()
				.aspectRatio(1, contentMode: .fit)
				.frame(maxWidth: 220)
				.clipShape(RoundedRectangle(cornerRadius: 20))
				.accessibilityHidden(true)

			VStack(spacing: 6) {
				Text(book.title)
					.font(.title2.bold())
				Text(book.author)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.multilineTextAlignment(.center)
			.frame(maxWidth: .infinity)

			VStack(alignment: .leading, spacing: 16) {
				Button {
					do {
						try playerService.setupAndPlayAudio(book: book, rate: .init(rawValue: rate))
					} catch {
						Log.error(error.localizedDescription)
					}
				} label: {
					Label(playbackTitle, systemImage: playbackSymbol)
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)

				ProgressView(value: book.progress, total: 1.0)
					.accessibilityLabel("Прогресс книги")
			}
			.padding(16)
			.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))

			VStack(spacing: 10) {
				metadataRow("Количество глав", value: "\(book.orderedChapters.count)")
				metadataRow("Длительность книги", value: book.totalDuration)
			}
			.font(.subheadline)
			.padding(.horizontal, 4)
		}
		.frame(maxWidth: 560)
		.frame(maxWidth: .infinity)
	}

	private func metadataRow(_ title: LocalizedStringKey, value: String) -> some View {
		HStack(alignment: .firstTextBaseline, spacing: 12) {
			Text(title)
				.foregroundStyle(.secondary)
			Spacer(minLength: 8)
			Text(value)
				.multilineTextAlignment(.trailing)
		}
	}
}
