//
//  IPlayerService.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import Combine
import Foundation

protocol IPlayerService {	
	var currentBook: Book? { get }
	var isPlaying: Bool { get }

	func playAudio(book: Book, rate: PlaybackRate?) throws
	func pauseCurrentAudio()
	func resumeCurrentAudio()
	func setPlayback(time: TimeInterval)
	func skipForward(time: TimeInterval)
	func skipBackward(time: TimeInterval)
	func changePlayback(rate: PlaybackRate)
	func prepareToPlayRestoredAudio()
}
