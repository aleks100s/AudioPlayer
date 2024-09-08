//
//  IPlayerService.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import Combine
import Foundation

protocol IPlayerService {	
	var playerStatus: AnyPublisher<PlayerStatus?, Never> { get }

	func setupAudio(file: Chapter, rate: PlaybackRate?) -> Result<Void, Error>
	func playCurrentAudio() -> Result<Void, Error>
	func pauseCurrentAudio()
	func resumeCurrentAudio()
	func setPlayback(time: TimeInterval)
	func skipForward(time: TimeInterval)
	func skipBackward(time: TimeInterval)
	func changePlayback(rate: PlaybackRate)
	func prepareToPlayRestoredAudio()
}
