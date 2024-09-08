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
	
	func playAudio(book: Book, rate: PlaybackRate?) throws {
		guard currentBook != book else {
			pauseOrResume()
			return
		}
		
		currentBook = book
		guard let chapter = book.currentChapter ?? book.orderedChapters.first else {
			Log.error("No current chapter")
			return
		}
		book.currentChapter = chapter
		
		guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			Log.error("Can't find documents directory")
			return
		}
		
		let fileURL = documentsDirectory
			.appendingPathComponent(book.id.uuidString, conformingTo: .directory)
			.appendingPathComponent(chapter.urlLastPathComponent, conformingTo: .audio)
		
		do {
			audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
			audioPlayer?.delegate = self
			audioPlayer?.enableRate = true
			audioPlayer?.currentTime = chapter.currentTime
			updatePlayerWithNewAudio()
			if let rate {
				audioPlayer?.rate = rate.rawValue
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
	
	func prepareToPlayRestoredAudio() {
		updatePlayerWithNewAudio()
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
			isPlaying = false
		}
	}
}

// MARK: - In-App Controls

extension PlayerService {
	func pauseOrResume() {
		if isPlaying {
			pauseCurrentAudio()
		} else {
			resumeCurrentAudio()
		}
	}
	
	private func pauseCurrentAudio() {
		audioPlayer?.pause()
		updatePlayback()
	}
	
	private func resumeCurrentAudio() {
		audioPlayer?.play()
		updatePlayback()
	}
	
	func setPlayback(time: TimeInterval) {
		guard let audioPlayer else { return }
		
		if time >= audioPlayer.duration {
			finishCurrentAudioStream()
		} else {
			audioPlayer.currentTime = time
			updatePlayback()
		}
	}
	
	func skipForward(time: TimeInterval) {
		skip(time: time, forward: true)
	}
	
	func skipBackward(time: TimeInterval) {
		skip(time: time, forward: false)
	}
	
	func changePlayback(rate: PlaybackRate) {
		audioPlayer?.rate = rate.rawValue
	}
	
	private func skip(time interval: TimeInterval, forward: Bool) {
		audioPlayer?.currentTime += interval * (forward ? 1 : -1)
		updatePlayback()
	}
		
	private func finishCurrentAudioStream() {
		//
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

			self.audioPlayer?.currentTime = event.positionTime
			return .success
		}
	}
	
	func setupSkipForwardCommand() {
		commandCenter.skipForwardCommand.isEnabled = true
		commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 30)]
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
		commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
		commandCenter.skipBackwardCommand.addTarget { event in
			guard let event = event as? MPSkipIntervalCommandEvent else {
				return .commandFailed
			}
			
			self.skip(time: event.interval, forward: false)
			return .success
		}
	}
}

// MARK: - Audio Interraptions

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

private extension PlayerService {
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
	
	func updatePlayerWithNewAudio() {
		var nowPlayingInfo = [String: Any]()
		nowPlayingInfo[MPMediaItemPropertyArtwork] = currentBook?.currentChapter?.artwork
		nowPlayingInfo[MPMediaItemPropertyTitle] = currentBook?.currentChapter?.name
		nowPlayingInfo[MPMediaItemPropertyArtist] = currentBook?.title
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer?.duration ?? .zero)
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer?.currentTime ?? .zero)
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		MPNowPlayingInfoCenter.default().playbackState = .playing
	}
	
	func updatePlayback() {
		updatePlaybackStatus()
		updatePlaybackTime()
	}
	
	func updatePlaybackStatus() {
		currentChapter?.currentTime = audioPlayer?.currentTime ?? .zero
		isPlaying = audioPlayer?.isPlaying ?? false
	}
	
	func updatePlaybackTime() {
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
		nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer?.duration ?? .zero)
		nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer?.currentTime ?? .zero)
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		MPNowPlayingInfoCenter.default().playbackState = audioPlayer?.isPlaying == true ? .playing : .paused
	}
}
