//
//  PlayerService.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import AVFoundation
import Combine
import Foundation
import MediaPlayer

@Observable
final class PlayerService: NSObject, IPlayerService {
	var currentBook: Book?
	var isPlaying = false

	private var audioPlayer: AVAudioPlayer?
	private var timer: Timer?

	private var currentChapter: Chapter? {
		currentBook?.currentChapter
	}
	
	override init() {
		super.init()
		setupTimer()
		setupAudioInterruptionNotifications()
		setupRemoteCommandCenter()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - AVAudioPlayerDelegate

extension PlayerService: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		Log.debug("audioPlayerDidFinishPlaying \(currentChapter?.name ?? "???") successfully=\(flag)")
		if player == audioPlayer, flag {
			do {
				try nextChapter()
			} catch {
				Log.error(error.localizedDescription)
			}
		}
	}
}

// MARK: - Public In-App Controls

extension PlayerService {
	func setupAndPlayAudio(book: Book, chapter: Chapter? = nil, rate: PlaybackRate? = nil) throws {
		if book.isFinished {
			book.resetProgress()
		}
		
		guard book != currentBook else {
			if let chapter, chapter != currentChapter {
				try play(chapter: chapter, rate: rate, resetProgress: false)
			} else {
				pauseOrResume()
			}
			return
		}
		
		currentBook = book
		guard let chapter = book.currentChapter ?? book.orderedChapters.first else {
			Log.error("No current chapter")
			return
		}
		
		try play(chapter: chapter, rate: rate, resetProgress: false)
	}

	func pauseOrResume() {
		if isPlaying {
			pauseCurrentAudio()
		} else {
			resumeCurrentAudio()
		}
	}
	
	func previousChapter() throws {
		guard let currentChapter = currentBook?.currentChapter else {
			Log.error("Can't switch to previous chapter")
			return
		}
		
		guard let index = currentBook?.orderedChapters.firstIndex(of: currentChapter) else {
			Log.error("Can't find current chapter in the current book")
			return
		}
		
		guard currentChapter.currentTime < 5 else {
			setPlayback(time: .zero)
			return
		}
		
		if index > .zero, let previousChapter = currentBook?.orderedChapters[index - 1] {
			try play(chapter: previousChapter, rate: nil)
		} else {
			setPlayback(time: .zero)
		}
	}
	
	func nextChapter() throws {
		guard let currentChapter = currentBook?.currentChapter else {
			Log.error("Can't switch to next chapter")
			return
		}
		
		guard let index = currentBook?.orderedChapters.firstIndex(of: currentChapter) else {
			Log.error("Can't find current chapter in the current book")
			return
		}
				
		currentChapter.isListened = true
		if index + 1 < (currentBook?.orderedChapters.endIndex ?? 0), let nextChapter = currentBook?.orderedChapters[index + 1] {
			try play(chapter: nextChapter, rate: nil)
		} else {
			finishBook()
		}
	}
	
	func skipForward(time: TimeInterval) {
		skip(time: time, forward: true)
	}
	
	func skipBackward(time: TimeInterval) {
		skip(time: time, forward: false)
	}
	
	func changePlayback(rate: PlaybackRate) {
		audioPlayer?.rate = rate.float
	}
	
	func setPlayback(time: TimeInterval) {
		guard let audioPlayer else { return }
		
		if time >= audioPlayer.duration {
			do {
				try nextChapter()
			} catch {
				Log.error(error.localizedDescription)
			}
		} else {
			audioPlayer.currentTime = time
			updatePlayback()
		}
	}
	
	func removeIfNeeded(book: Book) {
		guard book == currentBook else {
			return
		}
		
		stopCurrentBook()
	}
	
	func stopCurrentBook() {
		stopPlayer()
		currentBook = nil
	}
}

private extension PlayerService {
	// MARK: - Setup PLayer
	
	func setupTimer() {
		DispatchQueue.global().async { [weak self] in
			let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] timer in
				DispatchQueue.main.async {
					self?.updatePlayback()
				}
			}
			self?.timer = timer
			RunLoop.current.add(timer, forMode: .common)
			RunLoop.current.run()
		}
	}
	
	func setupMediaPlayer() {
		var nowPlayingInfo = [String: Any]()
		nowPlayingInfo[MPMediaItemPropertyArtwork] = currentBook?.currentChapter?.artwork
		nowPlayingInfo[MPMediaItemPropertyTitle] = currentBook?.currentChapter?.name
		nowPlayingInfo[MPMediaItemPropertyArtist] = currentBook?.title
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer?.duration ?? .zero)
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer?.currentTime ?? .zero)
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		MPNowPlayingInfoCenter.default().playbackState = .playing
	}
	
	// MARK: - Player Actions
	
	func play(chapter: Chapter, rate: PlaybackRate?, resetProgress: Bool = true) throws {
		guard let book = currentBook else {
			Log.error("Unable to play chapter \(chapter.name) - current book is not set")
			return
		}
		
		chapter.isListened = false
		book.currentChapter = chapter
		
		guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			Log.error("Can't find documents directory")
			return
		}
		
		let fileURL = documentsDirectory
			.appendingPathComponent(book.id.uuidString, conformingTo: .directory)
			.appendingPathComponent(chapter.urlLastPathComponent, conformingTo: .audio)
		
		do {
			let oldRate = audioPlayer?.rate
			audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
			audioPlayer?.delegate = self
			audioPlayer?.enableRate = true
			if !resetProgress {
				audioPlayer?.currentTime = chapter.currentTime
			}
			setupMediaPlayer()
			if let rate = rate?.float ?? oldRate {
				audioPlayer?.rate = rate
			}
			audioPlayer?.prepareToPlay()
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
			try AVAudioSession.sharedInstance().setActive(true)
			audioPlayer?.play()
		} catch {
			Log.error("Error initializing the audio player: \(error)\nfor file \(chapter.urlLastPathComponent)")
			throw error
		}
	}
	
	func pauseCurrentAudio() {
		audioPlayer?.pause()
		updatePlayback()
	}
	
	func resumeCurrentAudio() {
		audioPlayer?.play()
		updatePlayback()
	}
	
	func skip(time interval: TimeInterval, forward: Bool) {
		let currentTime = (audioPlayer?.currentTime ?? .zero) + interval * (forward ? 1 : -1)
		setPlayback(time: currentTime)
	}
	
	// MARK: - Update Playback
	
	func updatePlayback() {
		updatePlaybackStatus()
		updateMediaPlayerPlaybackTime()
	}
	
	func updatePlaybackStatus() {
		currentChapter?.currentTime = audioPlayer?.currentTime ?? .zero
		isPlaying = audioPlayer?.isPlaying ?? false
	}
	
	func updateMediaPlayerPlaybackTime() {
		if let audioPlayer {
			MPNowPlayingInfoCenter.default().playbackState = audioPlayer.isPlaying ? .playing : .paused
			var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
			nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer.duration)
			nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer.currentTime)
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		} else {
			stopMediaPlayer()
		}
	}
	
	// MARK: - Stop Player
	
	func finishBook() {
		stopPlayer()
		currentBook?.finishBook()
		currentBook = nil
	}
	
	func stopPlayer() {
		isPlaying = false
		stopAudioPlayer()
		stopMediaPlayer()
	}
	
	func stopAudioPlayer() {
		audioPlayer?.stop()
		audioPlayer = nil
	}
	
	func stopMediaPlayer() {
		MPNowPlayingInfoCenter.default().playbackState = .stopped
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
	}
}

// MARK: - MPRemoteCommandCenter

private extension PlayerService {
	var commandCenter: MPRemoteCommandCenter {
		MPRemoteCommandCenter.shared()
	}
	
	func setupRemoteCommandCenter() {
		setupPlayCommand()
		setupPauseCommand()
		setupChangePlaybackPositionCommand()
		setupSkipForwardCommand()
		setupSkipBackwardCommand()
	}
	
	func setupPlayCommand() {
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget { _ in
			self.resumeCurrentAudio()
			return .success
		}
	}
	
	func setupPauseCommand() {
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { _ in
			self.pauseCurrentAudio()
			return .success
		}
	}
	
	func setupChangePlaybackPositionCommand() {
		commandCenter.changePlaybackPositionCommand.isEnabled = true
		commandCenter.changePlaybackPositionCommand.addTarget { event in
			guard let event = event as? MPChangePlaybackPositionCommandEvent else {
				return .commandFailed
			}

			self.setPlayback(time: event.positionTime)
			return .success
		}
	}
	
	func setupSkipForwardCommand() {
		commandCenter.skipForwardCommand.isEnabled = true
		commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: Constants.skipForwardInterval)]
		commandCenter.skipForwardCommand.addTarget { event in
			guard let event = event as? MPSkipIntervalCommandEvent else {
				return .commandFailed
			}
			
			self.skip(time: event.interval, forward: true)
			return .success
		}
	}
	
	func setupSkipBackwardCommand() {
		commandCenter.skipBackwardCommand.isEnabled = true
		commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: Constants.skipBackwardInterval)]
		commandCenter.skipBackwardCommand.addTarget { event in
			guard let event = event as? MPSkipIntervalCommandEvent else {
				return .commandFailed
			}
			
			self.skip(time: event.interval, forward: false)
			return .success
		}
	}
}

// MARK: - Audio Interruptions

private extension PlayerService {
	func setupAudioInterruptionNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleAudioSessionInterruption),
			name: AVAudioSession.interruptionNotification,
			object: AVAudioSession.sharedInstance()
		)
	}
	
	@objc func handleAudioSessionInterruption(notification: Notification) {
		guard let userInfo = notification.userInfo,
			  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
			  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
			return
		}
		
		if type == .began {
			// Interruption began, pause the audio
			Log.debug("Audio interraption began")
		} else if type == .ended {
			if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
				let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
				if options.contains(.shouldResume) {
					// Interruption ended, resume the audio
					Log.debug("Audio interraption ended")
				}
			}
		}
	}
}
