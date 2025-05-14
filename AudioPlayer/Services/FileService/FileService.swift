//
//  FileService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation

struct FileService: IFileService {
	func saveBookFiles(_ files: [URL], id: UUID) throws -> [URL] {
		Log.debug("Trying to save book files \(files)")
		let manager = FileManager.default
		guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			Log.error("Can't access documents directory")
			throw FileError.noDocumentsDirectory
		}
		
		let bookDirectory = documentsDirectory.appendingPathComponent(id.uuidString, conformingTo: .directory)
		var isDir : ObjCBool = true
		if !manager.fileExists(atPath: bookDirectory.absoluteString, isDirectory: &isDir) {
			do {
				Log.debug("Creating book directory at \(bookDirectory)")
				try manager.createDirectory(at: bookDirectory, withIntermediateDirectories: true)
			} catch {
				Log.error(error.localizedDescription)
				throw FileError.directoryCreationFailed
			}
		}
		
		var resultUrls = [URL]()
		let files = files.sorted(by: { $0.absoluteString.localizedStandardContains($1.absoluteString) })
		for file in files {
			guard file.startAccessingSecurityScopedResource() else {
				Log.error("No permission to open file \(file)")
				throw FileError.readingFailed
			}
			
			defer {
				file.stopAccessingSecurityScopedResource()
			}
			
			let newUrl = bookDirectory.appendingPathComponent(file.lastPathComponent, conformingTo: .audio)
			Log.debug("Saving file \(file) in \(newUrl)")
			do {
				try manager.copyItem(at: file, to: newUrl)
				resultUrls.append(newUrl)
			} catch {
				Log.error(error.localizedDescription)
				continue
			}
		}
		Log.debug("Book files were saved")
		return resultUrls
	}
	
	func deleteBookFiles(_ book: Book) throws {
		Log.debug("Trying to delete book \(book.title)")
		let manager = FileManager.default
		guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			Log.error("Can't access documents directory")
			throw FileError.noDocumentsDirectory
		}
		
		let bookDirectory = documentsDirectory.appendingPathComponent(book.id.uuidString, conformingTo: .directory)
		try manager.removeItem(at: bookDirectory)
		Log.debug("Book \(book.title) was successfully deleted")
	}
}
