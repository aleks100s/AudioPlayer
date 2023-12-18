//
//  FileService.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import Domain
import Foundation

public struct FileService {
	public let saveAudioFiles: ([URL]) -> Result<Void, Error>
	public let getAudioFiles: () -> Result<[AudioFile], Error>
	
	public init(
		saveAudioFiles: @escaping ([URL]) -> Result<Void, Error>,
		getAudioFiles: @escaping () -> Result<[AudioFile], Error>
	) {
		self.saveAudioFiles = saveAudioFiles
		self.getAudioFiles = getAudioFiles
	}
}
