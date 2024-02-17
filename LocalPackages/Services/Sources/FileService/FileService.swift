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
	public let deleteAudioFiles: ([AudioFile]) -> Result<Void, Error>
	public let saveBookAudioFiles: (UUID, [URL]) -> Result<[URL], Error>
	public let getBookAudioFiles: (BookDto) -> Result<[AudioFile], Error>
	
	public init(
		saveAudioFiles: @escaping ([URL]) -> Result<Void, Error>,
		getAudioFiles: @escaping () -> Result<[AudioFile], Error>,
		deleteAudioFiles: @escaping ([AudioFile]) -> Result<Void, Error>,
		saveBookAudioFiles: @escaping (UUID, [URL]) -> Result<[URL], Error>,
		getBookAudioFiles: @escaping (BookDto) -> Result<[AudioFile], Error>
	) {
		self.saveAudioFiles = saveAudioFiles
		self.getAudioFiles = getAudioFiles
		self.deleteAudioFiles = deleteAudioFiles
		self.saveBookAudioFiles = saveBookAudioFiles
		self.getBookAudioFiles = getBookAudioFiles
	}
}
