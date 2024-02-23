//
//  StorageService+DependencyKey.swift
//  
//
//  Created by Alexander on 05.01.2024.
//

import ComposableArchitecture
import Domain
import Foundation
import Shared

extension StorageService: DependencyKey {
	public static var liveValue: StorageService {
		StorageService(
			savePlaybackRate: { rate in
				UserDefaults.standard.setValue(rate.rawValue, forKey: StorageService.Key.playbackRate.rawValue)
			},
			getPlaybackRate: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.playbackRate.rawValue) as? Float
				guard let value, let rate = PlaybackRate(rawValue: value) else {
					Log.error("Couldn't fetch playback rate from UserDefaults")
					return .x100
				}
				
				return rate
			},
			saveCurrentAudio: { file in
				UserDefaults.standard.setValue(file.name, forKey: StorageService.Key.currentAudio.rawValue)
			},
			getCurrentAudio: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.currentAudio.rawValue) as? String
				guard let value else {
					Log.error("Couldn't fetch current audio from UserDefaults")
					return nil
				}
				
				return value
			},
			saveCurrentTime: { time in
				UserDefaults.standard.setValue(time, forKey: StorageService.Key.currentTime.rawValue)
			},
			getCurrentTime: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.currentTime.rawValue) as? TimeInterval
				guard let value else {
					Log.error("Couldn't fetch current time from UserDefaults")
					return 0
				}
				
				return value
			},
			saveBooks: { books in
				var allBooks = BookStorageHelper.fetchBooks()
				for book in books {
					if !allBooks.contains(book) {
						allBooks.append(book)
					}
				}
				
				BookStorageHelper.saveBooks(books: allBooks)
			},
			getBooks: {
				BookStorageHelper.fetchBooks()
			},
			saveCurrentBook: { book in
				UserDefaults.standard.setValue(book.title, forKey: StorageService.Key.currentBook.rawValue)
			},
			getCurrentBook: {
				let value = UserDefaults.standard.value(forKey: StorageService.Key.currentBook.rawValue) as? String
				guard let value else {
					Log.error("Couldn't fetch current book from UserDefaults")
					return nil
				}
				
				return value
			},
			deleteBook: { book in
				var allBooks = BookStorageHelper.fetchBooks()
				allBooks.removeAll(where: { dto in dto.id == book.id})
				BookStorageHelper.saveBooks(books: allBooks)
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
			getCurrentTime: { 0 },
			saveBooks: { _ in },
			getBooks: { [] },
			saveCurrentBook: { _ in },
			getCurrentBook: { nil },
			deleteBook: { _ in }
		)
	}
	
	public static func mock(
		savePlaybackRate: @escaping (PlaybackRate) -> Void = { _ in },
		getPlaybackRate: @escaping () -> PlaybackRate = { .x100 },
		saveCurrentAudio: @escaping (AudioFile) -> Void = { _ in },
		getCurrentAudio: @escaping () -> String? = { nil },
		saveCurrentTime: @escaping (TimeInterval) -> Void = { _ in },
		getCurrentTime: @escaping () -> TimeInterval = { .zero },
		saveBooks: @escaping ([BookDto]) -> Void = { _ in },
		getBooks: @escaping () -> [BookDto] = { [] },
		saveCurrentBook: @escaping (Book) -> Void = { _ in },
		getCurrentBook: @escaping () -> String? = { nil },
		deleteBook: @escaping (Book) -> Void = { _ in }
	) -> StorageService {
		StorageService(
			savePlaybackRate: savePlaybackRate,
			getPlaybackRate: getPlaybackRate,
			saveCurrentAudio: saveCurrentAudio,
			getCurrentAudio: getCurrentAudio,
			saveCurrentTime: saveCurrentTime,
			getCurrentTime: getCurrentTime,
			saveBooks: saveBooks,
			getBooks: getBooks,
			saveCurrentBook: saveCurrentBook,
			getCurrentBook: getCurrentBook,
			deleteBook: deleteBook
		)
	}
}
