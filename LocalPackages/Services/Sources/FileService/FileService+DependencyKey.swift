//
//  FileService+DependencyKey.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import ComposableArchitecture
import Foundation
import Domain
import Shared

extension FileService: DependencyKey {
	public static var liveValue: FileService {
		FileService(
			saveAudioFiles: { files in
				Log.debug("Trying to save files \(files)")
				let manager = FileManager.default
				guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
					Log.error("Can't access documents directory")
					return .failure(FileError.noDocumentsDirectory)
				}
				
				for file in files {
					guard file.startAccessingSecurityScopedResource() else {
						Log.error("No permission to open file \(file)")
						return .failure(FileError.readingFailed)
					}
					
					let newUrl = documentsDirectory.appendingPathComponent(file.lastPathComponent, conformingTo: .audio)
					Log.debug("Saving file \(file) in \(newUrl)")
					do {
						try manager.copyItem(at: file, to: newUrl)
					} catch {
						Log.error(error.localizedDescription)
						continue
					}
				}
				Log.debug("Files were saved")
				return .success(())
			},
			getAudioFiles: {
				Log.debug("Trying to get audio files")
				let manager = FileManager.default
				guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
					Log.error("Can't access documents directory")
					return .failure(FileError.noDocumentsDirectory)
				}
				
				do {
					let files = try manager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
					Log.debug("Contents of Documents directory: \(files)")
					let audioFiles = files.filter { $0.isAudioFile }
						.map { AudioFile(url: $0) }
						.sorted(by: { $0.name < $1.name} )
					Log.debug("Audio files were successfully read: \(audioFiles)")
					return .success(audioFiles)
				} catch {
					Log.error("Can't read audio files")
					return .failure(FileError.readingFailed)
				}
			},
			deleteAudioFiles: { files in
				do {
					Log.debug("Trying to delete files \(files)")
					let manager = FileManager.default
					Log.debug("Contents of Documents directory: \(files)")
					for file in files {
						try manager.removeItem(at: file.url)
					}
					Log.debug("Successfully deleted \(files.count) files")
					return .success(())
				} catch {
					Log.error("Can't delete audio files")
					return .failure(FileError.readingFailed)
				}
			},
			saveBookAudioFiles: { id, files in
				Log.debug("Trying to save book files \(files)")
				let manager = FileManager.default
				guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
					Log.error("Can't access documents directory")
					return .failure(FileError.noDocumentsDirectory)
				}
				
				let bookDirectory = documentsDirectory.appendingPathComponent(id.uuidString, conformingTo: .directory)
				var isDir : ObjCBool = true
				if !manager.fileExists(atPath: bookDirectory.absoluteString, isDirectory: &isDir) {
					do {
						Log.debug("Creating book directory at \(bookDirectory)")
						try manager.createDirectory(at: bookDirectory, withIntermediateDirectories: true)
					} catch {
						Log.error(error.localizedDescription)
						return .failure(FileError.directoryCreationFailed)
					}
				}
				
				var resultUrls = [URL]()
				for file in files {
					guard file.startAccessingSecurityScopedResource() else {
						Log.error("No permission to open file \(file)")
						return .failure(FileError.readingFailed)
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
				return .success(resultUrls)
			},
			getBookAudioFiles: { dto in
				Log.debug("Trying to get audio files for \(dto.title) book")
				let manager = FileManager.default
				guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
					Log.error("Can't access documents directory")
					return .failure(FileError.noDocumentsDirectory)
				}
				
				do {
					let bookDirectory = documentsDirectory.appendingPathComponent(dto.id.uuidString, conformingTo: .directory)
					let files = try manager.contentsOfDirectory(at: bookDirectory, includingPropertiesForKeys: nil)
					Log.debug("Contents of the book directory: \(files)")
					let audioFiles = files
						.filter { $0.isAudioFile }
						.map { AudioFile(url: $0) }
						.sorted(by: { $0.name < $1.name} )
					Log.debug("Audio files were successfully read: \(audioFiles)")
					return .success(audioFiles)
				} catch {
					Log.error("Can't read audio files")
					return .failure(FileError.readingFailed)
				}
			}
		)
	}
	
	public static var previewValue: FileService {
		FileService(
			saveAudioFiles: { files in
				Log.debug("Debug version of `saveAudioFiles`")
				print(files)
				return .success(())
			},
			getAudioFiles: {
				Log.debug("Debug version of `getAudioFiles`")
				return .success([
					.init(name: "Chem_zhil_tyl_full.mp3", url: URL(string: "some//url.1")!),
					.init(name: "my_favourite_audio_book.mp3", url: URL(string: "some//url.2")!)
				])
			},
			deleteAudioFiles: { files in
				Log.debug("Debug version of `deleteFiles`")
				print(files)
				return .success(())
			},
			saveBookAudioFiles: { _, files in
				Log.debug("Debug version of `saveBookAudioFiles`")
				print(files)
				return .success(([]))
			},
			getBookAudioFiles: { dto in
				Log.debug("Debug version of `getBookAudioFiles`")
				print(dto)
				return .success([
					.init(name: "Chem_zhil_tyl_full.mp3", url: URL(string: "some//url.1")!),
					.init(name: "my_favourite_audio_book.mp3", url: URL(string: "some//url.2")!)
				])
			}
		)
	}
	
	public static func mock(
		saveAudioFilesResult: @escaping ([URL]) -> Result<Void, Error> = { _ in .success(()) },
		getAudioFilesResult: @escaping () -> Result<[AudioFile], Error> = { .success([]) },
		deleteAudioFilesResult: @escaping ([AudioFile]) -> Result<Void, Error> = { _ in .success(()) },
		saveBookAudioFilesResult: @escaping (UUID, [URL]) -> Result<[URL], Error> = { _, _ in .success([]) },
		getBookAudioFilesResult: @escaping (BookDto) -> Result<[AudioFile], Error> = { _ in .success([]) }
	) -> FileService {
		FileService(
			saveAudioFiles: saveAudioFilesResult,
			getAudioFiles: getAudioFilesResult,
			deleteAudioFiles: deleteAudioFilesResult,
			saveBookAudioFiles: saveBookAudioFilesResult,
			getBookAudioFiles: getBookAudioFilesResult
		)
	}
}
