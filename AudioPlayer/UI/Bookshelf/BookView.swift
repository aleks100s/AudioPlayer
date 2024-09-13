//
//  BookView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct BookView: View {
	let book: Book
	let onChaptersListTap: () -> Void
	
	@AppStorage(Constants.playbackRate) private var rate: Double = 1
	@Environment(\.playerService) private var playerService
	
	var body: some View {
		VStack(alignment: .leading, spacing: .zero) {
			BookCoverView(book: book)
			
			BookProgressView(book: book, onChaptersListTap: onChaptersListTap)
		}
		.background(.regularMaterial.opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
	
	private func handlePlayButtonTap() {
		do {
			try playerService.setupAndPlayAudio(book: book, rate: .init(rawValue: rate))
		} catch {
			Log.error(error.localizedDescription)
		}
	}
}

private struct BookCoverView: View {
	let book: Book
	
	@AppStorage(Constants.playbackRate) private var rate: Double = 1
	@Environment(\.playerService) private var playerService
	
	private var isPlaying: Bool {
		playerService.currentBook == book && playerService.isPlaying
	}
	
	var body: some View {
		ZStack {
			Image(uiImage: book.artworkImage)
				.resizable()
				.aspectRatio(1, contentMode: .fill)
				.clipShape(RoundedRectangle(cornerRadius: 16))
			
			VStack {
				Spacer()
				
				HStack {
					VStack(alignment: .leading) {
						Text(book.title)
							.font(.headline)
							.lineLimit(1)
						
						Text(book.author)
							.font(.subheadline)
							.lineLimit(1)
							.foregroundStyle(.secondary)
					}
					
					Spacer()
					
					Button("", systemImage: book.isFinished ? "arrow.counterclockwise.circle" : isPlaying ? "pause.circle" : "play.circle") {
						handlePlayButtonTap()
					}
					.font(.title)
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

private struct BookProgressView: View {
	let book: Book
	let onChaptersListTap: () -> Void
	
	@Environment(\.playerService) private var playerService
	
	private var isPlaying: Bool {
		playerService.currentBook == book && playerService.isPlaying
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: .zero) {
			ProgressView(value: book.progress, total: 1.0)
				.animation(.bouncy, value: book.progress)
			
			HStack {
				if book.isFinished {
					Text("Книга прослушана")
						.font(.footnote)
				} else if let chapter = book.currentChapter?.name {
					Text("\(isPlaying ? "Сейчас играет:" : "Продолжить прослушивание:") \(chapter)")
						.font(.footnote)
				} else {
					Text("Начать прослушивание")
				}
				
				Spacer()
				
				HStack {
					Text(String(format: "%.1f%%", book.progress * 100))
						.opacity(book.progress == .zero ? .zero : 1)
					
					Button("", systemImage: "list.bullet") {
						onChaptersListTap()
					}
					.font(.title)
				}
			}
			.lineLimit(1)
			.padding()
		}
	}
}
