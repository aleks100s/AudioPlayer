//
//  FileError.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation

enum FileError: LocalizedError {
	case noDocumentsDirectory
	case copyingFailed(path: String)
	case readingFailed
	case deletionFailed
	case directoryCreationFailed
	
	var errorDescription: String? {
		switch self {
		case .noDocumentsDirectory:
			return "Не удалось скопировать аудиофайлы"
			
		case let .copyingFailed(path):
			return "Ошибка при копировании аудиофайла \(path)"
			
		case .readingFailed:
			return "Ошибка при получении аудиофайлов"
			
		case .deletionFailed:
			return "Ошибка при удалении файлов"
			
		case .directoryCreationFailed:
			return "Не удалось создать папку для книги"
		}
	}
}
