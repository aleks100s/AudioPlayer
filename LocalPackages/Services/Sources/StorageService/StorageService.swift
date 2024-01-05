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
	}
	
	public let savePlaybackRate: (PlaybackRate) -> Void
	public let getPlaybackRate: () -> PlaybackRate
	
	public init(
		savePlaybackRate: @escaping (PlaybackRate) -> Void,
		getPlaybackRate: @escaping () -> PlaybackRate
	) {
		self.savePlaybackRate = savePlaybackRate
		self.getPlaybackRate = getPlaybackRate
	}
}
