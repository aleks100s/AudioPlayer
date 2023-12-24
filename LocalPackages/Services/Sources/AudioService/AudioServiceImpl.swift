//
//  AudioServiceImpl.swift
//
//
//  Created by Alexander on 19.12.2023.
//

import AVFoundation
import Domain
import MediaPlayer
import Shared

public final class AudioServiceImpl: AudioService {
	private var audioPlayer: AVAudioPlayer?
	private var currentFile: AudioFile?
	
	public init() {
		setupAudioInterruptionNotifications()
	}
	
	public func setupAudio(file: AudioFile) -> Result<Void, Error> {
		do {
			currentFile = file
			audioPlayer = try AVAudioPlayer(contentsOf: file.url)
			audioPlayer?.prepareToPlay()
			return .success(())
		} catch {
			Log.error("Error initializing the audio player: \(error)")
			return .failure(error)
		}
	}
	
	public func playCurrentAudio() -> Result<Void, Error> {
		do {
			try AVAudioSession.sharedInstance().setActive(true)
			audioPlayer?.play()
			updatePlayer()
			setupRemoteCommandCenter()
			return .success(())
		} catch {
			Log.error("Error playing the audio player: \(error)")
			return .failure(error)
		}
	}
	
	private func updatePlayer() {
		MPNowPlayingInfoCenter.default().nowPlayingInfo = [
			MPMediaItemPropertyTitle: currentFile?.name ?? "-",
			MPMediaItemPropertyArtist: Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "-",
			MPMediaItemPropertyPlaybackDuration: NSNumber(value: audioPlayer?.duration ?? 0),
			MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: audioPlayer?.currentTime ?? 0)
		]
		MPNowPlayingInfoCenter.default().playbackState = .playing
	}
	
	private func setupRemoteCommandCenter() {
		let commandCenter = MPRemoteCommandCenter.shared();
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget { _ in
			self.audioPlayer?.play()
			self.updatePlayer()
			return .success
		}
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { _ in
			self.audioPlayer?.pause()
			self.updatePlayer()
			return .success
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Audio Interraptions

private extension AudioServiceImpl {
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
