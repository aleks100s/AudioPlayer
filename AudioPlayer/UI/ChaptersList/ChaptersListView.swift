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
	
	@Environment(\.playerService) private var playerService
	
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
					.swipeActions(edge: .leading) {
						Button(chapter.isListened ? "Отметить непрослушанным" : "Отметить прослушанным") {
							chapter.isListened.toggle()
						}
						.tint(.green)
						.sensoryFeedback(.success, trigger: chapter.isListened)
					}
				}
			}
			.navigationTitle("Список глав")
		}
	}
	
	private func select(chapter: Chapter) {
		do {
			try playerService.setupAndPlayAudio(book: book, chapter: chapter, resetProgress: chapter != currentChapter)
		} catch {
			Log.error(error.localizedDescription)
		}
	}
}
