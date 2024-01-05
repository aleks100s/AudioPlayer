//
//  StorageService.swift
//
//
//  Created by Alexander on 05.01.2024.
//

import Domain

public struct StorageService {
	enum Key: String {
		case playbackRate
		case currentAudio
	}
	
	public let savePlaybackRate: (PlaybackRate) -> Void
	public let getPlaybackRate: () -> PlaybackRate
	public let saveCurrentAudio: (AudioFile) -> Void
	public let getCurrentAudio: () -> AudioFile?
	
	public init(
		savePlaybackRate: @escaping (PlaybackRate) -> Void,
		getPlaybackRate: @escaping () -> PlaybackRate,
		saveCurrentAudio: @escaping (AudioFile) -> Void,
		getCurrentAudio: @escaping () -> AudioFile?
	) {
		self.savePlaybackRate = savePlaybackRate
		self.getPlaybackRate = getPlaybackRate
		self.saveCurrentAudio = saveCurrentAudio
		self.getCurrentAudio = getCurrentAudio
	}
}
