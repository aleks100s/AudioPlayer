//
//  StorageService+DependencyKey.swift
//  
//
//  Created by Alexander on 05.01.2024.
//

import ComposableArchitecture
import Domain
import Foundation

extension StorageService: DependencyKey {
	public static var liveValue: StorageService {
		StorageService(
			savePlaybackRate: { rate in
				UserDefaults.standard.setValue(rate.rawValue, forKey: StorageService.Key.playbackRate.rawValue)
			},
			getPlaybackRate: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.playbackRate.rawValue) as? Float
				guard let value, let rate = PlaybackRate(rawValue: value) else { return .x100 }
				
				return rate
			},
			saveCurrentAudio: { file in
				UserDefaults.standard.setValue(file.url.absoluteString, forKey: StorageService.Key.currentAudio.rawValue)
			},
			getCurrentAudio: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.currentAudio.rawValue) as? String
				guard let value, let url = URL(string: value) else { return nil }
				
				return AudioFile(url: url)
			},
			saveCurrentTime: { time in
				UserDefaults.standard.setValue(time, forKey: StorageService.Key.currentTime.rawValue)
			},
			getCurrentTime: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.currentTime.rawValue) as? TimeInterval
				guard let value else { return 0 }
				
				return value
			}
		)
	}
	
	public static var previewValue: StorageService {
		StorageService(
			savePlaybackRate: { _ in },
			getPlaybackRate: { .x100 },
			saveCurrentAudio: { _ in },
			getCurrentAudio: { nil },
			saveCurrentTime: { _ in },
			getCurrentTime: { 0 }
		)
	}
}
