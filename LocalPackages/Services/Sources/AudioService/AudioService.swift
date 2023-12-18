//
//  AudioService.swift
//
//
//  Created by Alexander on 19.12.2023.
//

import Domain

public protocol AudioService {
	func setupAudio(file: AudioFile) -> Result<Void, Error>
	func playCurrentAudio() -> Result<Void, Error>
}
