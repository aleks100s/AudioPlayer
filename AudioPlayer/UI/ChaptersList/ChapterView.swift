//
//  ChapterView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI

struct ChapterView: View {
	let chapter: Chapter
	let hasCheckmark: Bool
	let isCurrentChapter: Bool
	let isCurrentlyPlaying: Bool
	let onTap: () -> Void
		
	var body: some View {
		Button {
			onTap()
		} label: {
			HStack {
				VStack(alignment: .leading) {
					Text(chapter.name)
					Text(chapter.duration.timeString)
						.monospaced()
						.font(.caption)
						.foregroundStyle(.gray)
				}
				
				Spacer()
				
				if isCurrentChapter {
					HStack(spacing: 4) {
						PlaybackIndicatorView(animationDuration: 1.0, isPlaying: isCurrentlyPlaying)
						PlaybackIndicatorView(animationDuration: 0.6, isPlaying: isCurrentlyPlaying)
						PlaybackIndicatorView(animationDuration: 1.4, isPlaying: isCurrentlyPlaying)
					}
				} else if hasCheckmark {
					Image(systemName: "checkmark")
						.foregroundStyle(.green)
				}
			}
		}
		.tint(.primary)
	}
}
