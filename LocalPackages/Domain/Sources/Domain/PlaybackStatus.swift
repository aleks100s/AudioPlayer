//
//  PlaybackStatus.swift
//
//
//  Created by Alexander on 30.12.2023.
//

import Foundation

public struct PlaybackStatus: Equatable {
	public let currentTime: TimeInterval
	public let duration: TimeInterval
	public let isPlaying: Bool
	
	public init(
		currentTime: TimeInterval,
		duration: TimeInterval,
		isPlaying: Bool
	) {
		self.currentTime = currentTime
		self.duration = duration
		self.isPlaying = isPlaying
	}
}
