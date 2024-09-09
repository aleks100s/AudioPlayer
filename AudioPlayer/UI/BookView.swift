//
//  BookView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct BookView: View {
	let book: Book
	
	@Environment(\.playerService) private var playerService
	
	private var image: UIImage {
		guard let data = book.orderedChapters.first?.artworkData else {
			return UIImage(resource: .placeholder)
		}
		
		return UIImage(data: data) ?? UIImage(resource: .placeholder)
	}
	
	private var isPlaying: Bool {
		playerService.currentBook == book && playerService.isPlaying
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: .zero) {
			ZStack {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(1, contentMode: .fill)
					.clipShape(RoundedRectangle(cornerRadius: 16))
				
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
						
						Button("", systemImage: book.isFinished ? "arrow.counterclockwise.circle" : isPlaying ? "pause.circle" : "play.circle") {
							handlePlayButtonTap()
						}
						.font(.title)
					}
					.padding()
					.background(.ultraThinMaterial)
				}
			}
			
			ProgressView(value: book.progress, total: 1.0)
				.animation(.bouncy, value: book.progress)
			
			HStack {
				if book.isFinished {
					Text("Книга прослушана")
						.font(.footnote)
				} else if let chapter = book.currentChapter?.name {
					Text("\(isPlaying ? "Сейчас играет:" : "Продолжить прослушивание:") \(chapter)")
						.font(.footnote)
				}
				
				Spacer()
														
				Text(String(format: "%.1f%%", book.progress * 100))
			}
			.padding()
		}
		.background(.regularMaterial.opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
	
	private func handlePlayButtonTap() {
		do {
			try playerService.setupAndPlayAudio(book: book, rate: nil)
		} catch {
			Log.error(error.localizedDescription)
		}
	}
}
