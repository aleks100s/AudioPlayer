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
			}
		)
	}
	
	public static var previewValue: StorageService {
		StorageService(
			savePlaybackRate: { _ in },
			getPlaybackRate: { .x100 }
		)
	}
}
