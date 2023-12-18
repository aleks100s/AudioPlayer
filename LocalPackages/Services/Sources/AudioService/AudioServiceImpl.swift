//
//  AudioServiceImpl.swift
//
//
//  Created by Alexander on 19.12.2023.
//

import AVFoundation
import Domain
import Shared

public final class AudioServiceImpl: AudioService {
	var audioPlayer: AVAudioPlayer?
	
	public init() {
		setupAudioInterruptionNotifications()
	}
	
	public func setupAudio(file: AudioFile) -> Result<Void, Error> {
		do {
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
			return .success(())
		} catch {
			Log.error("Error playing the audio player: \(error)")
			return .failure(error)
		}
	}
	
	private func setupAudioInterruptionNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleAudioSessionInterruption),
			name: AVAudioSession.interruptionNotification,
			object: AVAudioSession.sharedInstance()
		)
	}
	
	@objc private func handleAudioSessionInterruption(notification: Notification) {
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
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
