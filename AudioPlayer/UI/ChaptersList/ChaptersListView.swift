//
//  ChaptersListView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI

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
				ForEach(book.orderedChapters) { chapter in
					let isCurrentChapter = currentChapter == chapter
					ChapterView(
						chapter: chapter,
						hasCheckmark: chapter.isListened || book.isFinished,
						isCurrentChapter: isCurrentChapter,
						isCurrentlyPlaying: isCurrentChapter && isPlaying
					)
				}
			}
			.navigationTitle("Список глав")
		}
	}
}
