//
//  AudioListFeature.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import ComposableArchitecture
import Domain
import FileService
import Foundation

@Reducer
public struct AudioListFeature {
	public struct State: Equatable {
		var files: [AudioFile] = []
		var errorMessage: String?
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case viewDidLoad
		case saveFiles([URL])
		case errorOccurred(String)
		case filesLoaded([AudioFile])
		case errorAlertDismissed
		case test
	}
	
	@Dependency(\.fileService) var fileService
	
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
				
			case .test:
				return .none
			}
		}
	}
}
