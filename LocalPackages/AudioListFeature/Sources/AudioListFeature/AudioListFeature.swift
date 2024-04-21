//
//  AudioListFeature.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import AudioService
import ComposableArchitecture
import Domain
import FileService
import Foundation
import StorageService

@Reducer
public struct AudioListFeature {
	public struct State: Equatable {		
		@BindingState var book: Book
		var errorMessage: String?
		var currentAudio: AudioFile?
		var isPlaying: Bool
		
		public init(book: Book, currentAudio: AudioFile?, isPlaying: Bool) {
			print(book.chapters.first)
			print(currentAudio)
			self.book = book
			self.currentAudio = currentAudio
			self.isPlaying = isPlaying
		}
	}
	
	public enum Action: Equatable {
		public enum Delegate: Equatable {
			case audioSelected(AudioFile)
			case markAsRead(AudioFile)
			case markAsUnread(AudioFile)
		}
		
		case viewDidLoad
		// case saveFiles([URL])
		case errorOccurred(String)
		// case filesAdded([AudioFile])
		case errorAlertDismissed
		// case playerStarted(AudioFile)
		// case deleteFiles(IndexSet)
		// case playbackStatusChanged(PlaybackStatus)
		case delegate(Delegate)
	}
	
	@Dependency(\.fileService) var fileService
	@Dependency(\.audioService) var audioService
	@Dependency(\.storageService) var storageService
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .viewDidLoad:
				return .none
				
//			case let .saveFiles(files):
//				guard !files.isEmpty else { return .none }
//
//				return .run { [book = state.book] send in
//					let result = fileService.saveBookAudioFiles(book.id, files)
//					switch result {
//					case .success:
//						let audio = files.map { AudioFile(url: $0) }
//						await send(.filesAdded(audio))
//
//					case let .failure(error):
//						await send(.errorOccurred(error.localizedDescription))
//					}
//				}
//
			case let .errorOccurred(error):
				state.errorMessage = error
				return .none
//
//			case let .filesAdded(files):
//				state.book.chapters.append(contentsOf: files)
//				return .none
//
			case .errorAlertDismissed:
				state.errorMessage = nil
				return .none
//
//			case let .playerStarted(file):
//				state.currentAudio = file
//				storageService.saveCurrentAudio(file)
//				return .run { send in
//					for await currentStatus in audioService.playbackStatusStream {
//						await send(.playbackStatusChanged(currentStatus))
//					}
//				}
//
//			case let .deleteFiles(indexSet):
//				var filesToDelete = [AudioFile]()
//				for index in indexSet {
//					filesToDelete.append(state.book.chapters.remove(at: index))
//				}
//
//				return .run { [filesToDelete] send in
//					let result = fileService.deleteAudioFiles(filesToDelete)
//					switch result {
//					case let .failure(error):
//						await send(.errorOccurred(error.localizedDescription))
//
//					default:
//						break
//					}
//				}
//
//			case let .playbackStatusChanged(status):
//				state.playbackStatus = status
//				storageService.saveCurrentTime(status.currentTime)
//				return .none
			case .delegate:
				return .none
			}
		}
	}
}
