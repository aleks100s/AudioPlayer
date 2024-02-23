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
	}
	
	public let savePlaybackRate: (PlaybackRate) -> Void
	public let getPlaybackRate: () -> PlaybackRate
	public let saveCurrentAudio: (AudioFile) -> Void
	public let getCurrentAudio: () -> String?
	public let saveCurrentTime: (TimeInterval) -> Void
	public let getCurrentTime: () -> TimeInterval
	public let saveBooks: ([BookDto]) -> Void
	public let getBooks: () -> [BookDto]
	public let saveCurrentBook: (Book) -> Void
	public let getCurrentBook: () -> String?
	public let deleteBook: (Book) -> Void
	
	public init(
		savePlaybackRate: @escaping (PlaybackRate) -> Void,
		getPlaybackRate: @escaping () -> PlaybackRate,
		saveCurrentAudio: @escaping (AudioFile) -> Void,
		getCurrentAudio: @escaping () -> String?,
		saveCurrentTime: @escaping (TimeInterval) -> Void,
		getCurrentTime: @escaping () -> TimeInterval,
		saveBooks: @escaping ([BookDto]) -> Void,
		getBooks: @escaping () -> [BookDto],
		saveCurrentBook: @escaping (Book) -> Void,
		getCurrentBook: @escaping () -> String?,
		deleteBook: @escaping (Book) -> Void
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
	}
}
