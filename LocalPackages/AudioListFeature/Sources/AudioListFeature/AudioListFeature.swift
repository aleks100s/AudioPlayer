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

@Reducer
public struct AudioListFeature {
	public struct State: Equatable {
		enum PlayerState {
			case playing
			case paused
			case hidden
			
			var imageName: String {
				switch self {
				case .playing:
					"pause.fill"
					
				case .paused:
					"play.fill"
					
				case .hidden:
					""
				}
			}
		}
		
		var files: [AudioFile]
		var errorMessage: String?
		var playerState: PlayerState = .hidden
		
		public init(files: [AudioFile] = []) {
			self.files = files
		}
	}
	
	public enum Action: Equatable {
		case viewDidLoad
		case saveFiles([URL])
		case errorOccurred(String)
		case filesLoaded([AudioFile])
		case errorAlertDismissed
		case audioTapped(AudioFile)
		case playerStarted
		case pauseButtonTapped
		case resumeButtonTapped
		case deleteFiles(IndexSet)
		case test
	}
	
	@Dependency(\.fileService) var fileService
	@Dependency(\.audioService) var audioService
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .viewDidLoad:
				return .run { send in
					let result = fileService.getAudioFiles()
					switch result {
					case let .success(files):
						await send(.filesLoaded(files))
						
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
					}
				}
				
			case let .saveFiles(files):
				guard !files.isEmpty else { return .none }
				
				return .run { send in
					let result = fileService.saveAudioFiles(files)
					switch result {
					case .success:
						await send(.viewDidLoad)
						
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
					}
				}
				
			case let .errorOccurred(error):
				state.errorMessage = error
				return .none
				
			case let .filesLoaded(files):
				state.files = files
				return .none
				
			case .errorAlertDismissed:
				state.errorMessage = nil
				return .none
				
			case let .audioTapped(file):
				return .run { send in
					let setupResult = audioService.setupAudio(file: file)
					switch setupResult {
					case .success:
						let playResult = audioService.playCurrentAudio()
						switch playResult {
						case let .failure(error):
							await send(.errorOccurred(error.localizedDescription))
							
						case .success:
							await send(.playerStarted)
						}
						
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
					}
				}
				
			case .playerStarted:
				state.playerState = .playing
				return .none
				
			case .pauseButtonTapped:
				audioService.pauseCurrentAudio()
				state.playerState = .paused
				return .none
				
			case .resumeButtonTapped:
				audioService.resumeCurrentAudio()
				state.playerState = .playing
				return .none
				
			case let .deleteFiles(indexSet):
				var filesToDelete = [AudioFile]()
				for index in indexSet {
					filesToDelete.append(state.files.remove(at: index))
				}
				
				return .run { [filesToDelete] send in
					let result = fileService.deleteAudioFiles(filesToDelete)
					switch result {
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
						
					default:
						break
					}
				}

			case .test:
				return .none
			}
		}
	}
}
