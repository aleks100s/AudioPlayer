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
	
	public func pauseCurrentAudio() {
		audioPlayer?.pause()
		updatePlayer()
	}
	
	public func resumeCurrentAudio() {
		audioPlayer?.play()
		updatePlayer()
	}
	
	private func updatePlayer() {
		guard let url = currentFile?.url else {
			Log.debug("Failed to update player for file \(currentFile?.name ?? "???")")
			return
		}
		
		Task {
			let asset = AVAsset(url: url)
			let artwork = try await extractArtwork(from: asset)
			let title = try await extractStringResource(by: .commonKeyTitle, from: asset) ?? currentFile?.name
			let artist = try await extractStringResource(by: .commonKeyArtist, from: asset) ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
			var nowPlayingInfo = [String: Any]()
			nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
			nowPlayingInfo[MPMediaItemPropertyTitle] = title
			nowPlayingInfo[MPMediaItemPropertyArtist] = artist
			nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer?.duration ?? 0)
			nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: audioPlayer?.currentTime ?? 0)
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
			MPNowPlayingInfoCenter.default().playbackState = .playing
		}
	}
	
	private func extractArtwork(from asset: AVAsset) async throws -> MPMediaItemArtwork? {
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
	
	private func extractStringResource(
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
	
	private func setupRemoteCommandCenter() {
		let commandCenter = MPRemoteCommandCenter.shared();
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget { _ in
			self.resumeCurrentAudio()
			return .success
		}
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { _ in
			self.pauseCurrentAudio()
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
