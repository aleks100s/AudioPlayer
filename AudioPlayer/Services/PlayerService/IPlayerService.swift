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
    var currentTimer: TimerMode? { get }

	func setupAndPlayAudio(book: Book, chapter: Chapter?, rate: PlaybackRate?, resetProgress: Bool) throws
	func removeIfNeeded(book: Book)
	func stopCurrentBook()
	func pauseOrResume()
	func previousChapter() throws
	func nextChapter() throws
	func setPlayback(time: TimeInterval)
	func skipForward(time: TimeInterval)
	func skipBackward(time: TimeInterval)
	func changePlayback(rate: PlaybackRate)
    func setSleepTimer(mode: TimerMode)
    func resetTimer()
}
