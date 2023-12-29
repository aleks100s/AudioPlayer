//
//  AudioService.swift
//
//
//  Created by Alexander on 19.12.2023.
//

import Domain
import Foundation

public protocol AudioService {
	var playbackStatusStream: AsyncStream<PlaybackStatus> { get }
	
	func setupAudio(file: AudioFile) -> Result<Void, Error>
	func playCurrentAudio() -> Result<Void, Error>
	func pauseCurrentAudio()
	func resumeCurrentAudio()
}
