//
//  IPlayerService.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import Combine
import Foundation

protocol IPlayerService {	
	var currentChapter: Chapter? { get }
	var currentBook: Book? { get }
	var playerStatus: PlayerStatus { get }

	func playAudio(chapter: Chapter, book: Book, rate: PlaybackRate?) throws
	func pauseCurrentAudio()
	func resumeCurrentAudio()
	func setPlayback(time: TimeInterval)
	func skipForward(time: TimeInterval)
	func skipBackward(time: TimeInterval)
	func changePlayback(rate: PlaybackRate)
	func prepareToPlayRestoredAudio()
}
