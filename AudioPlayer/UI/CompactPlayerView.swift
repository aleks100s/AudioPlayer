//
//  CompactPlayerView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct CompactPlayerView: View {
	@Binding var isSliderBusy: Bool
	@Binding var progress: Double
	@State private var durationRange: ClosedRange<TimeInterval> = 0...0
	
	@Environment(\.playerService) private var playerService
	
	var body: some View {
		VStack(alignment: .center, spacing: 12) {
			title
			
			seeker
			
			controls
			
			PlaybackRateView {
				//
			}
		}
		.padding()
		.padding(.bottom, 16)
		.background(.regularMaterial)
	}
	
	private var title: some View {
		Text(playerService.currentBook?.currentChapter?.name ?? "")
			.font(.title3)
	}
	
	private var seeker: some View {
		HStack {
			Text(playerService.currentBook?.currentChapter?.currentTime.timeString ?? "")
				.monospaced()
				.contentTransition(.numericText())
			
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
				Log.debug("\(newValue)")
				if isSliderBusy {
					playerService.setPlayback(time: newValue)
				}
			}
			.onChange(of: playerService.currentBook?.currentChapter?.currentTime, initial: false) { _, newValue in
				if !isSliderBusy {
					progress = newValue ?? .zero
				}
			}
			
			Text(playerService.currentBook?.currentChapter?.duration.timeString ?? "")
				.monospaced()
				.contentTransition(.numericText())
		}
	}
	
	private var controls: some View {
		HStack {
			Spacer()
			
			ImageButton(systemName: "backward.end.fill") {
				//
			}
			
			Spacer()
			
			ImageButton(systemName: "gobackward.\(Constants.skipBackwardInterval)") {
				playerService.skipBackward(time: TimeInterval(Constants.skipBackwardInterval))
			}
			
			Spacer()
			
			ImageButton(systemName: playerService.isPlaying ? "pause.fill" : "play.fill") {
				playerService.pauseOrResume()
			}
			.animation(.spring, value: playerService.isPlaying)
			.sensoryFeedback(playerService.isPlaying ? .stop : .start, trigger: playerService.isPlaying)
			
			Spacer()
			
			ImageButton(systemName: "goforward.\(Constants.skipForwardInterval)") {
				playerService.skipForward(time: TimeInterval(Constants.skipForwardInterval))
			}
			
			Spacer()
			
			ImageButton(systemName: "forward.end.fill") {
				//
			}

			Spacer()
		}
	}
}

private struct PlaybackRateView: View {
	let onTap: () -> Void
	
	var body: some View {
		HStack {
			Button {
				onTap()
			} label: {
				Text("Скорость")
			}

			Spacer()
		}
	}
}

private struct ImageButton: View {
	let systemName: String
	let onTap: () -> Void
	
	var body: some View {
		Button {
			onTap()
		} label: {
			Image(systemName: systemName)
				.font(.title)
		}
	}
}
