//
//  PlaybackIndicatorView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI

struct PlaybackIndicatorView: View {
	private struct AnimationProperties {
		var verticalStretch = 1.0
	}
	
	let animationDuration: Double
	let isPlaying: Bool
	
	var body: some View {
		RoundedRectangle(cornerRadius: 2)
			.frame(width: 4, height: isPlaying ? 16 : 4)
			.background(Color.gray)
			.keyframeAnimator(initialValue: AnimationProperties(), repeating: true) { content, value in
				if isPlaying {
					content
						.scaleEffect(CGSize(width: 1.0, height: value.verticalStretch), anchor: .center)
				} else {
					content
				}
			} keyframes: { _ in
				KeyframeTrack(\.verticalStretch) {
					CubicKeyframe(0.2, duration: 0.5 * animationDuration)
					CubicKeyframe(1.0, duration: 0.5 * animationDuration)
				}
			}
	}
}

#Preview {
	PlaybackIndicatorView(animationDuration: 1.0, isPlaying: true)
}

