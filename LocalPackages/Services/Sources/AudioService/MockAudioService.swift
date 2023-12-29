//
//  MockAudioService.swift
//  
//
//  Created by Alexander on 19.12.2023.
//

import Domain
import Foundation

struct MockAudioService: AudioService {
	var playbackStatusStream: AsyncStream<PlaybackStatus> {
		.finished
	}
	
	private let setupAudioResult: () -> Result<Void, Error>
	private let playCurrentAudioResult: () -> Result<Void, Error>
	
	init(
		setupAudioResult: @escaping () -> Result<Void, Error>,
		playCurrentAudioResult: @escaping () -> Result<Void, Error>
	) {
		self.setupAudioResult = setupAudioResult
		self.playCurrentAudioResult = playCurrentAudioResult
	}
	
	func setupAudio(file: AudioFile) -> Result<Void, Error> {
		setupAudioResult()
	}
	
	func playCurrentAudio() -> Result<Void, Error> {
		playCurrentAudioResult()
	}
	
	func pauseCurrentAudio() {}
	
	func resumeCurrentAudio() {}
	
	func setPlayback(time: TimeInterval) {}
}
