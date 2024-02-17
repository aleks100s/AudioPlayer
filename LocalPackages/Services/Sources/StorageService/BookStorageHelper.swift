//
//  BookStorageHelper.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import Domain
import Foundation
import Shared

enum BookStorageHelper {
	static func fetchBooks() -> [BookDto] {
		guard let stringValue = UserDefaults.standard.value(forKey: StorageService.Key.books.rawValue) as? String else {
			Log.error("Couldn't fetch books list from UserDefaults")
			return []
		}
		
		guard let data = stringValue.data(using: .utf8) else {
			Log.error("Couldn't convert books list string to data")
			return []
		}
		
		guard let books = try? JSONDecoder().decode([BookDto].self, from: data) else {
			Log.error("Couldn't decode data to books list")
			return []
		}
		
		return books
	}
}
