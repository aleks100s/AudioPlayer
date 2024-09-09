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
	
	@Environment(\.playerService) private var playerService
	
	var body: some View {
		VStack(alignment: .center, spacing: 12) {
			title
			
			SeekerView(isSliderBusy: $isSliderBusy, progress: $progress)
			
			ControlsView()
			
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
}

private struct SeekerView: View {
	@Binding var isSliderBusy: Bool
	@Binding var progress: Double
	
	@State private var durationRange: ClosedRange<TimeInterval> = 0...0
	
	@Environment(\.playerService) private var playerService

	var body: some View {
		HStack {
			TimeView(text: playerService.currentBook?.currentChapter?.currentTime.timeString ?? "")
			
			SliderView(isSliderBusy: $isSliderBusy, progress: $progress)
			
			TimeView(text: playerService.currentBook?.currentChapter?.duration.timeString ?? "")
		}
	}
}

private struct TimeView: View {
	let text: String
	
	var body: some View {
		Text(text)
			.monospaced()
			.contentTransition(.numericText())
	}
}

private struct SliderView: View {
	@Binding var isSliderBusy: Bool
	@Binding var progress: Double
	
	@Environment(\.playerService) private var playerService
	
	var body: some View {
		Slider(
			value: $progress,
			in: 0...(playerService.currentBook?.currentChapter?.duration ?? .zero)
		) { isSliderBusy in
			self.isSliderBusy = isSliderBusy
		}
		.onChange(of: progress) { _, newValue in
			if isSliderBusy {
				playerService.setPlayback(time: newValue)
			}
		}
	}
}

private struct ControlsView: View {
	enum Control: CaseIterable {
		case previousTrack
		case skipBack
		case play
		case skipForward
		case nextTrack
	}
	
	@Environment(\.playerService) private var playerService
	
	var body: some View {
		HStack {
			Spacer()
			
			ForEach(Control.allCases, id: \.self) { control in
				switch control {
				case .previousTrack:
					ImageButton(systemName: "backward.end.fill") {
						//
					}
					
				case .skipBack:
					ImageButton(systemName: "gobackward.\(Constants.skipBackwardInterval)") {
						playerService.skipBackward(time: TimeInterval(Constants.skipBackwardInterval))
					}
					
				case .play:
					ImageButton(systemName: playerService.isPlaying ? "pause.fill" : "play.fill") {
						playerService.pauseOrResume()
					}
					.animation(.spring, value: playerService.isPlaying)
					.sensoryFeedback(playerService.isPlaying ? .stop : .start, trigger: playerService.isPlaying)
					
				case .skipForward:
					ImageButton(systemName: "goforward.\(Constants.skipForwardInterval)") {
						playerService.skipForward(time: TimeInterval(Constants.skipForwardInterval))
					}
					
				case .nextTrack:
					ImageButton(systemName: "forward.end.fill") {
						//
					}
				}
				
				Spacer()
			}
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
