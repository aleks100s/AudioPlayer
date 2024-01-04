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
		enum PlayerState: Equatable {
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
		
		var allFiles: [AudioFile]
		var filteredFiles: [AudioFile]
		var errorMessage: String?
		var playerState: PlayerState = .hidden
		var currentAudio: AudioFile?
		var currentTime: String = "00:00"
		var duration: String = "00:00"
		var playbackStatus: PlaybackStatus?
		var playbackRate: PlaybackRate = .x100
		
		public init(files: [AudioFile] = []) {
			allFiles = files
			filteredFiles = files
		}
	}
	
	public enum Action: Equatable {
		case viewDidLoad
		case saveFiles([URL])
		case errorOccurred(String)
		case filesLoaded([AudioFile])
		case errorAlertDismissed
		case audioTapped(AudioFile)
		case playerStarted(AudioFile)
		case pauseButtonTapped
		case resumeButtonTapped
		case deleteFiles(IndexSet)
		case searchTextChanged(String)
		case playbackStatusChanged(PlaybackStatus)
		case playbackSliderPositionChanged(TimeInterval)
		case skipForwardButtonTapped
		case skipBackwardButtonTapped
		case changePlaybackRateButtonTapped
		case playNextTrackButtonTapped
		case playPreviousTrackButtonTapped
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
				state.allFiles = files
				state.filteredFiles = files
				return .none
				
			case .errorAlertDismissed:
				state.errorMessage = nil
				return .none
				
			case let .audioTapped(file):
				return .run { [rate = state.playbackRate] send in
					let setupResult = audioService.setupAudio(file: file, rate: rate)
					switch setupResult {
					case .success:
						let playResult = audioService.playCurrentAudio()
						switch playResult {
						case let .failure(error):
							await send(.errorOccurred(error.localizedDescription))
							
						case .success:
							await send(.playerStarted(file))
						}
						
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
					}
				}
				
			case let .playerStarted(file):
				state.playerState = .playing
				state.currentAudio = file
				return .run { send in
					for await currentStatus in audioService.playbackStatusStream {
						await send(.playbackStatusChanged(currentStatus))
					}
					await send(.playNextTrackButtonTapped)
				}
				
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
					filesToDelete.append(state.allFiles.remove(at: index))
					state.filteredFiles.remove(at: index)
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
				
			case let .searchTextChanged(text):
				if text.isEmpty {
					state.filteredFiles = state.allFiles
				} else {
					state.filteredFiles = state.allFiles.filter { $0.name.contains(text) }
				}
				return .none
				
			case let .playbackStatusChanged(status):
				state.playbackStatus = status
				state.currentTime = makeTimeString(from: status.currentTime)
				state.duration = makeTimeString(from: status.duration)
				state.playerState = status.isPlaying ? .playing : .paused
				return .none
				
			case let .playbackSliderPositionChanged(desiredTime):
				audioService.setPlayback(time: desiredTime)
				return .none
				
			case .skipForwardButtonTapped:
				audioService.skipForward(time: TimeInterval(Constants.skipForwardInterval))
				return .none
				
			case .skipBackwardButtonTapped:
				audioService.skipBackward(time: TimeInterval(Constants.skipBackwardInterval))
				return .none
				
			case .changePlaybackRateButtonTapped:
				let currentRate = state.playbackRate
				let newRate = PlaybackRate.nextRate(after: currentRate)
				state.playbackRate = newRate
				audioService.changePlayback(rate: newRate)
				return .none
				
			case .playNextTrackButtonTapped:
				guard let currentAudio = state.currentAudio,
					  let index = state.filteredFiles.firstIndex(of: currentAudio),
					  index != (state.filteredFiles.count - 1) else {
					return .none
				}
				
				let nextAudio = state.filteredFiles[index + 1]
				return .run { send in
					await send(.audioTapped(nextAudio))
				}
				
			case .playPreviousTrackButtonTapped:
				guard let currentAudio = state.currentAudio,
					  let index = state.filteredFiles.firstIndex(of: currentAudio),
					  index != 0 else {
					return .none
				}
				
				return .run { [state] send in
					let playbackStatus = state.playbackStatus
					if playbackStatus?.currentTime ?? 0 > 5 {
						await send(.playbackSliderPositionChanged(0))
					} else {
						let previousAudio = state.filteredFiles[index - 1]
						await send(.audioTapped(previousAudio))
					}
				}

			case .test:
				return .none
			}
		}
	}
	
	private func makeTimeString(from time: TimeInterval) -> String {
		let time = Int(time)
		let minutes = String(format: "%02d", time / 60)
		let seconds = String(format: "%02d", time % 60)
		return "\(minutes):\(seconds)"
	}
}
