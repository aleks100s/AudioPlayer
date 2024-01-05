//
//  StorageService.swift
//
//
//  Created by Alexander on 05.01.2024.
//

import Domain
import Foundation

public struct StorageService {
	enum Key: String {
		case playbackRate
		case currentAudio
		case currentTime
	}
	
	public let savePlaybackRate: (PlaybackRate) -> Void
	public let getPlaybackRate: () -> PlaybackRate
	public let saveCurrentAudio: (AudioFile) -> Void
	public let getCurrentAudio: () -> AudioFile?
	public let saveCurrentTime: (TimeInterval) -> Void
	public let getCurrentTime: () -> TimeInterval
	
	public init(
		savePlaybackRate: @escaping (PlaybackRate) -> Void,
		getPlaybackRate: @escaping () -> PlaybackRate,
		saveCurrentAudio: @escaping (AudioFile) -> Void,
		getCurrentAudio: @escaping () -> AudioFile?,
		saveCurrentTime: @escaping (TimeInterval) -> Void,
		getCurrentTime: @escaping () -> TimeInterval
	) {
		self.savePlaybackRate = savePlaybackRate
		self.getPlaybackRate = getPlaybackRate
		self.saveCurrentAudio = saveCurrentAudio
		self.getCurrentAudio = getCurrentAudio
		self.saveCurrentTime = saveCurrentTime
		self.getCurrentTime = getCurrentTime
	}
}
