//
//  FileError.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import Foundation

enum FileError: LocalizedError {
	case noDocumentsDirectory
	case copyingFailed(path: String)
	case readingFailed
	
	var errorDescription: String? {
		switch self {
		case .noDocumentsDirectory:
			return "Не удалось скопировать аудиофайлы"
			
		case let .copyingFailed(path):
			return "Ошибка при копировании аудиофайла \(path)"
			
		case .readingFailed:
			return "Ошибка при получении аудиофайлов"
		}
	}
}
