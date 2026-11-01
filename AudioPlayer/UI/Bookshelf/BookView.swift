//
//  BookView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct BookView: View {
	let book: Book
	let isSelected: Bool
	let onSelect: () -> Void

	@AppStorage(Constants.playbackRate) private var rate: Double = 1
	@Environment(\.playerService) private var playerService
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	private var isPlaying: Bool {
		playerService.currentBook == book && playerService.isPlaying
	}

	private var chapterPosition: Int? {
		guard let current = book.currentChapter,
			  let index = book.orderedChapters.firstIndex(of: current) else { return nil }
		return index + 1
	}

	var body: some View {
		HStack(spacing: 8) {
			Button(action: onSelect) {
				HStack(spacing: 12) {
					Image(uiImage: book.image)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: dynamicTypeSize.isAccessibilitySize ? 56 : 72,
							   height: dynamicTypeSize.isAccessibilitySize ? 56 : 72)
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.accessibilityHidden(true)

					VStack(alignment: .leading, spacing: 4) {
						Text(book.title)
							.font(.headline)
							.lineLimit(2)
						Text(book.author)
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.lineLimit(1)

						if book.isFinished {
							Text("Прослушано")
								.font(.caption)
								.foregroundStyle(.green)
						} else {
							ProgressView(value: book.progress, total: 1)
								.tint(.accentColor)
								.padding(.top, 3)
							if let chapterPosition {
								Text("Глава \(chapterPosition) из \(book.orderedChapters.count)")
									.font(.caption)
									.foregroundStyle(.secondary)
							} else {
								Text("Глав: \(book.orderedChapters.count)")
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.accessibilityElement(children: .combine)
			.accessibilityAddTraits(isSelected ? .isSelected : [])
			.accessibilityHint("Открыть книгу")

			Button {
				do {
					try playerService.setupAndPlayAudio(book: book, rate: .init(rawValue: rate))
				} catch {
					Log.error(error.localizedDescription)
				}
			} label: {
				Image(systemName: book.isFinished ? "checkmark" : isPlaying ? "pause.fill" : "play.fill")
					.font(.subheadline.bold())
					.foregroundStyle(book.isFinished || isSelected ? .white : .primary)
					.frame(width: 36, height: 36)
					.background {
						Circle().fill(book.isFinished ? Color.green : isSelected ? Color.accentColor : Color.primary.opacity(0.04))
					}
					.overlay {
						Circle().strokeBorder(Color.primary.opacity(isSelected || book.isFinished ? 0 : 0.16))
					}
					.frame(minWidth: 44, minHeight: 44)
			}
			.buttonStyle(.plain)
			.accessibilityLabel(book.isFinished ? "Слушать заново" : isPlaying ? "Пауза" : "Воспроизвести")
		}
		.padding(8)
		.background(isSelected ? Color.accentColor.opacity(0.13) : Color.clear, in: RoundedRectangle(cornerRadius: 14))
		.sensoryFeedback(isPlaying ? .stop : .start, trigger: isPlaying)
	}
}
