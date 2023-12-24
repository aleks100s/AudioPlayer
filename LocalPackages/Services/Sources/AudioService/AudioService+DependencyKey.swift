//
//  AudioService+DependencyKey.swift
//
//
//  Created by Alexander on 19.12.2023.
//

import AVFoundation
import ComposableArchitecture
import Domain

extension AudioServiceImpl: DependencyKey {
	public static var liveValue: AudioService {
		AudioServiceImpl()
	}
	
	public static var previewValue: AudioService {
		mock()
	}
	
	public static func mock(
		setupAudioResult: @escaping () -> Result<Void, Error> = { .success(()) },
		playCurrentAudioResult: @escaping () -> Result<Void, Error> = { .success(()) }
	) -> AudioService {
		MockAudioService(
			setupAudioResult: setupAudioResult,
			playCurrentAudioResult: playCurrentAudioResult
		)
	}
}
