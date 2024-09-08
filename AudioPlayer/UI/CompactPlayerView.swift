//
//  CompactPlayerView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct CompactPlayerView: View {
	@State private var progress: Double = 0
	@State private var durationRange: ClosedRange<TimeInterval> = 0...0
	@State private var isSliderBusy = false
	
	@Environment(\.playerService) private var playerService
	
	var body: some View {
		VStack(alignment: .center, spacing: 12) {
			Text(playerService.currentBook?.currentChapter?.name ?? "")
				.font(.title3)
			
			seeker()
			
			controls()
			
			playbackRate()
		}
		.padding()
		.padding(.bottom, 16)
		.background(.regularMaterial)
	}
	
	@ViewBuilder
	private func seeker() -> some View {
		HStack {
			Text(playerService.currentBook?.currentChapter?.currentTime.timeString ?? "")
				.monospaced()
			
			Slider(
				value: $progress,
				in: 0...(playerService.currentBook?.currentChapter?.duration ?? .zero)
			) { isSliderBusy in
				self.isSliderBusy = isSliderBusy
				if !isSliderBusy {
					// viewStore.send(.playbackSliderPositionChanged(progress))
				}
			}
			.onChange(of: progress) { _, newValue in
				if isSliderBusy {
					// viewStore.send(.playbackSliderPositionChangeInProgress(newValue))
				}
			}
			.onChange(of: playerService.currentBook?.currentChapter?.currentTime, initial: false) { _, newValue in
				if !isSliderBusy {
					progress = newValue ?? .zero
				}
			}
			
			Text(playerService.currentBook?.currentChapter?.duration.timeString ?? "")
				.monospaced()
		}
	}
	
	@ViewBuilder
	private func playbackRate() -> some View {
		HStack {
			Button {
				// viewStore.send(.changePlaybackRateButtonTapped)
			} label: {
				Text("Скорость")
			}

			Spacer()
		}
	}
	
	@ViewBuilder
	private func controls() -> some View {
		HStack {
			Spacer()
			moveBackwardButton()
			Spacer()
			skipBackwardButton()
			Spacer()
			playButton()
			Spacer()
			skipForwardButton()
			Spacer()
			moveForwardButton()
			Spacer()
		}
	}
	
	@ViewBuilder
	private func moveBackwardButton() -> some View {
		Button {
			// viewStore.send(.playPreviousTrackButtonTapped)
		} label: {
			Image(systemName: "backward.end.fill")
				.font(.title)
		}
	}
		
	@ViewBuilder
	private func skipBackwardButton() -> some View {
		Button {
			// viewStore.send(.skipBackwardButtonTapped)
		} label: {
			Image(systemName: "gobackward.\(Constants.skipBackwardInterval)")
				.font(.title)
		}
	}
	
	@ViewBuilder
	private func playButton() -> some View {
		Button {
			playerService.pauseOrResume()
		} label: {
			Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
				.font(.title)
				.animation(.spring, value: playerService.isPlaying)
		}
		.sensoryFeedback(playerService.isPlaying ? .stop : .start, trigger: playerService.isPlaying)
	}
	
	@ViewBuilder
	private func skipForwardButton() -> some View {
		Button {
			// viewStore.send(.skipForwardButtonTapped)
		} label: {
			Image(systemName: "goforward.\(Constants.skipForwardInterval)")
				.font(.title)
		}
	}
	
	@ViewBuilder
	private func moveForwardButton() -> some View {
		Button {
			// viewStore.send(.playNextTrackButtonTapped)
		} label: {
			Image(systemName: "forward.end.fill")
				.font(.title)
		}
	}
}
