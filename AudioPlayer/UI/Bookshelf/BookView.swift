//
//  BookView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct BookView: View {
	let book: Book
	let onSelect: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: .zero) {
			BookCoverView(book: book, onSelect: onSelect)

			Button(action: onSelect) {
				ProgressView(value: book.progress, total: 1.0)
					.animation(.bouncy, value: book.progress)
					.padding(.vertical, 12)
					.padding(.horizontal)
					.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.accessibilityHidden(true)
		}
		.background(.regularMaterial.opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
}

private struct BookCoverView: View {
	let book: Book
	let onSelect: () -> Void
	
	@AppStorage(Constants.playbackRate) private var rate: Double = 1
	@Environment(\.playerService) private var playerService
	
	private var isPlaying: Bool {
		playerService.currentBook == book && playerService.isPlaying
	}
	
	var body: some View {
		ZStack {
			Button(action: onSelect) {
				cover
			}
			.buttonStyle(.plain)
			.accessibilityLabel("\(book.title), \(book.author)")
			.accessibilityHint("Открыть книгу")

            Button {
                handlePlayButtonTap()
            } label: {
                Image(systemName: book.isFinished ? "arrow.counterclockwise.circle" : isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120)
                    .opacity(0.8)
            }
            .buttonStyle(PlayButtonStyle())
			.accessibilityLabel(book.isFinished ? "Слушать заново" : isPlaying ? "Пауза" : "Воспроизвести")
		}
		.sensoryFeedback(isPlaying ? .stop : .start, trigger: isPlaying)
	}

	private var cover: some View {
		ZStack {
			Image(uiImage: book.image)
				.resizable()
				.aspectRatio(1, contentMode: .fill)
				.clipShape(RoundedRectangle(cornerRadius: 16))
				.overlay {
					Color.black.opacity(0.1)
				}
			
			VStack {
				Spacer()
				
				HStack {
					VStack(alignment: .leading) {
						Text(book.title)
							.font(.headline)
							.lineLimit(2)
						
						Text(book.author)
							.font(.subheadline)
							.lineLimit(1)
							.foregroundStyle(.secondary)
					}
					
					Spacer()
				}
				.padding()
				.background(.ultraThinMaterial)
			}
		}
	}
	
	private func handlePlayButtonTap() {
		do {
			try playerService.setupAndPlayAudio(book: book, rate: .init(rawValue: rate))
		} catch {
			Log.error(error.localizedDescription)
		}
	}
}
