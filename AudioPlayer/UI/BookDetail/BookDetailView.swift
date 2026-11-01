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
	@ScaledMetric(relativeTo: .body) private var expandedPlayerMargin: CGFloat = 90
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
		.contentMargins(.bottom, playerOverlayMargin, for: .scrollContent)
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

	private var playerOverlayMargin: CGFloat {
		if #available(iOS 26.0, *), playerService.currentBook != nil { return expandedPlayerMargin }
		return 0
	}

	private var bookOverview: some View {
		VStack(alignment: .leading, spacing: 20) {
			ViewThatFits(in: .horizontal) {
				HStack(alignment: .top, spacing: 20) {
					cover.frame(width: 160)
					bookInformation.frame(width: 280, alignment: .leading)
				}
				HStack(alignment: .top, spacing: 20) {
					cover.frame(width: 140)
					bookInformation.frame(width: 200, alignment: .leading)
				}
				VStack(alignment: .leading, spacing: 20) {
					cover
						.frame(maxWidth: 220)
						.frame(maxWidth: .infinity)
					bookInformation
				}
			}
			playbackButton
		}
		.frame(maxWidth: 850, alignment: .leading)
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var cover: some View {
		Image(uiImage: book.image)
			.resizable()
			.aspectRatio(1, contentMode: .fit)
			.clipShape(RoundedRectangle(cornerRadius: 20))
			.shadow(color: .black.opacity(0.15), radius: 12, y: 8)
			.accessibilityHidden(true)
	}

	private var bookInformation: some View {
		VStack(alignment: .leading, spacing: 18) {
			VStack(alignment: .leading, spacing: 4) {
				Text(book.title)
					.font(.largeTitle.bold())
					.fixedSize(horizontal: false, vertical: true)
				Text(book.author)
					.font(.title3)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}

			ViewThatFits(in: .horizontal) {
				HStack(spacing: 8) { metadataChips }
				VStack(alignment: .leading, spacing: 8) { metadataChips }
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var playbackButton: some View {
		Button {
			do {
				try playerService.setupAndPlayAudio(book: book, rate: .init(rawValue: rate))
			} catch {
				Log.error(error.localizedDescription)
			}
		} label: {
			Label(playbackTitle, systemImage: playbackSymbol)
				.labelStyle(.titleAndIcon)
				.padding(.horizontal, 16)
		}
		.buttonStyle(.borderedProminent)
		.controlSize(.large)
		.buttonBorderShape(.capsule)
	}

	private var metadataChips: some View {
		Group {
			metadataChip(String(localized: "\(book.orderedChapters.count) глав"), systemImage: "bookmark")
			metadataChip(book.totalDuration, systemImage: "clock")
		}
	}

	private func metadataChip(_ title: String, systemImage: String) -> some View {
		Label(title, systemImage: systemImage)
			.labelStyle(.titleAndIcon)
			.font(.subheadline)
			.padding(.horizontal, 12)
			.padding(.vertical, 9)
			.background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
			.fixedSize(horizontal: true, vertical: false)
	}
}
