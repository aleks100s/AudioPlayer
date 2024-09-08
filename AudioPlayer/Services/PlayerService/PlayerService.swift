//
//  PlayerService.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import AVFoundation
import Combine
import MediaPlayer

final class PlayerService: NSObject, IPlayerService {
	var playerStatus: AnyPublisher<PlayerStatus?, Never> {
		playerStatusSubject.eraseToAnyPublisher()
	}

	private let playerStatusSubject = CurrentValueSubject<PlayerStatus?, Never>(nil)

	private var audioPlayer: AVAudioPlayer?
	private var currentFile: Chapter?
	private var timer: Timer?
	
	override init() {
		super.init()
		setupTimer()
		setupAudioInterruptionNotifications()
		setupRemoteCommandCenter()
	}
	
	func setupAudio(file: Chapter, rate: PlaybackRate?) -> Result<Void, Error> {
		do {
			currentFile = file
			audioPlayer = try AVAudioPlayer(contentsOf: file.url)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()
			audioPlayer?.enableRate = true
			if let rate {
				audioPlayer?.rate = rate.rawValue
			}
			return .success(())
		} catch {
			Log.error("Error initializing the audio player: \(error)\nfor file \(file.url.absoluteString)")
			return .failure(error)
		}
	}
	
	func playCurrentAudio() -> Result<Void, Error> {
		do {
			try AVAudioSession.sharedInstance().setActive(true)
			audioPlayer?.play()
			updatePlayerWithNewAudio()
			return .success(())
		} catch {
			Log.error("Error playing the audio player: \(error)")
			return .failure(error)
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
		if player == audioPlayer, flag {
			playerStatusSubject.send(nil)
		}
	}
}

// MARK: - In-App Controls

extension PlayerService {
	func pauseCurrentAudio() {
		audioPlayer?.pause()
		updatePlaybackTime()
	}
	
	func resumeCurrentAudio() {
		audioPlayer?.play()
		updatePlaybackTime()
	}
	
	func setPlayback(time: TimeInterval) {
		guard let audioPlayer else { return }
		
		if time >= audioPlayer.duration {
			finishCurrentAudioStream()
		} else {
			audioPlayer.currentTime = time
			updatePlaybackTime()
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
		updatePlaybackTime()
	}
	
	private func updatePlaybackTime() {
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
		nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer?.duration ?? 0)
		nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer?.currentTime ?? 0)
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	private func finishCurrentAudioStream() {
		playerStatusSubject.send(nil)
		timer?.invalidate()
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
				self?.updatePlaybackTime()
				guard let status = self?.getPlaybackStatus() else {
					self?.finishCurrentAudioStream()
					return
				}
				
				self?.playerStatusSubject.send(status)
			}
			self?.timer = timer
			RunLoop.current.add(timer, forMode: .common)
			RunLoop.current.run()
		}
	}
	
	func updatePlayerWithNewAudio() {
		guard let url = currentFile?.url else {
			Log.debug("Failed to update player for file \(currentFile?.name ?? "???")")
			return
		}
		
		Task {
			do {
				let asset = AVAsset(url: url)
				let artwork = try await extractArtwork(from: asset)
				let title = try await extractStringResource(by: .commonKeyTitle, from: asset) ?? currentFile?.name
				let artist = try await extractStringResource(by: .commonKeyArtist, from: asset) ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
				let album = try await extractStringResource(by: .commonKeyAlbumName, from: asset)
				var nowPlayingInfo = [String: Any]()
				nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
				nowPlayingInfo[MPMediaItemPropertyTitle] = title
				nowPlayingInfo[MPMediaItemPropertyArtist] = artist
				nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
				nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer?.duration ?? 0)
				nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer?.currentTime ?? 0)
				MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
				MPNowPlayingInfoCenter.default().playbackState = .playing
			} catch {
				Log.debug("Failed to update MPNowPlayingInfoCenter: \(error.localizedDescription)")
			}
		}
	}
	
	func extractArtwork(from asset: AVAsset) async throws -> MPMediaItemArtwork? {
		let metadata = try await asset.load(.commonMetadata)
		for item in metadata {
			if item.commonKey == .commonKeyArtwork {
				if let data = try await item.load(.value) as? Data {
					guard let artworkImage = UIImage(data: data) else {
						Log.debug("Failed to extract artwork from metadata of \(currentFile?.name ?? "???")")
						break
					}
					
					let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { size in
						return artworkImage
					}
					return artwork
				}
			}
		}
		return nil
	}
	
	func extractStringResource(
		by key: AVMetadataKey,
		from asset: AVAsset
	) async throws -> String? {
		let metadata = try await asset.load(.commonMetadata)
		for item in metadata {
			if item.commonKey == key {
				if let title = try await item.load(.value) as? String {
					return title
				}
			}
		}
		return nil
	}
	
	func getPlaybackStatus() -> PlayerStatus {
		PlayerStatus(
			currentTime: audioPlayer?.currentTime ?? 0,
			duration: audioPlayer?.duration ?? 0,
			isPlaying: audioPlayer?.isPlaying ?? false
		)
	}
}
