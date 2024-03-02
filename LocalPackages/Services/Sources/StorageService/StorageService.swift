//
//  StorageService.swift
//
//
//  Created by Alexander on 05.01.2024.
//

import Domain
import Foundation

public struct StorageService {
	enum Key: String {
		case playbackRate
		case currentAudio
		case currentTime
		case books
		case currentBook
		case listened
	}
	
	public let savePlaybackRate: (PlaybackRate) -> Void
	public let getPlaybackRate: () -> PlaybackRate
	public let saveCurrentAudio: (Book, AudioFile) -> Void
	public let getCurrentAudio: (Book) -> String?
	public let saveCurrentTime: (AudioFile, TimeInterval) -> Void
	public let getCurrentTime: (AudioFile) -> TimeInterval
	public let saveBooks: ([BookDto]) -> Void
	public let getBooks: () -> [BookDto]
	public let saveCurrentBook: (Book) -> Void
	public let getCurrentBook: () -> String?
	public let deleteBook: (Book) -> Void
	public let markAudioFileAsListened: (Book, AudioFile) -> Void
	public let isAudioFileListened: (BookDto, AudioFile) -> Bool
	
	public init(
		savePlaybackRate: @escaping (PlaybackRate) -> Void,
		getPlaybackRate: @escaping () -> PlaybackRate,
		saveCurrentAudio: @escaping (Book, AudioFile) -> Void,
		getCurrentAudio: @escaping (Book) -> String?,
		saveCurrentTime: @escaping (AudioFile, TimeInterval) -> Void,
		getCurrentTime: @escaping (AudioFile) -> TimeInterval,
		saveBooks: @escaping ([BookDto]) -> Void,
		getBooks: @escaping () -> [BookDto],
		saveCurrentBook: @escaping (Book) -> Void,
		getCurrentBook: @escaping () -> String?,
		deleteBook: @escaping (Book) -> Void,
		markAudioFileAsListened: @escaping (Book, AudioFile) -> Void,
		isAudioFileListened: @escaping (BookDto, AudioFile) -> Bool
	) {
		self.savePlaybackRate = savePlaybackRate
		self.getPlaybackRate = getPlaybackRate
		self.saveCurrentAudio = saveCurrentAudio
		self.getCurrentAudio = getCurrentAudio
		self.saveCurrentTime = saveCurrentTime
		self.getCurrentTime = getCurrentTime
		self.saveBooks = saveBooks
		self.getBooks = getBooks
		self.saveCurrentBook = saveCurrentBook
		self.getCurrentBook = getCurrentBook
		self.deleteBook = deleteBook
		self.markAudioFileAsListened = markAudioFileAsListened
		self.isAudioFileListened = isAudioFileListened
	}
}
