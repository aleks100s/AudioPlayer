//
//  BookshelfFeature.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import AudioService
import BookMetaInfoService
import ComposableArchitecture
import Domain
import FileService
import StorageService
import UIKit

@Reducer
public struct BookshelfFeature {
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
		
		var books: [Book]
		var errorMessage: String?
		var playerState: PlayerState = .hidden
		var currentBook: Book?
		var currentAudio: AudioFile?
		var currentTime: String = "00:00"
		var duration: String = "00:00"
		var playbackStatus: PlaybackStatus?
		var playbackRate: PlaybackRate = .x100
		
		public init(books: [Book] = [], errorMessage: String? = nil) {
			self.books = books
			self.errorMessage = errorMessage
		}
	}
	
	public enum Action: Equatable {
		case viewDidLoad
		case booksLoaded([Book])
		case errorOccurred(String)
		case errorAlertDismissed
		case saveBookFiles([URL])
		case bookTapped(Book)
		case audioSelected(AudioFile)
		case playerStarted(AudioFile)
		case pauseButtonTapped
		case resumeButtonTapped
		case playbackStatusChanged(PlaybackStatus)
		case playbackSliderPositionChanged(TimeInterval)
		case skipForwardButtonTapped
		case skipBackwardButtonTapped
		case changePlaybackRateButtonTapped
		case playNextTrackButtonTapped
		case playPreviousTrackButtonTapped
		case restoreAudioSession
		case deleteBook(Book)
		case bookDeleted(Book)
	}
	
	@Dependency(\.audioService) var audioService
	@Dependency(\.fileService) var fileService
	@Dependency(\.storageService) var storageService
	@Dependency(\.bookMetaInfoService) var metaService
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .viewDidLoad:
				return .run { send in
					var books = [Book]()
					let dtos = storageService.getBooks()
					for dto in dtos {
						let result = fileService.getBookAudioFiles(dto)
						
						switch result {
						case let .success(files):
							let artwork = try? await metaService.extractArtworkFromURL(files.first?.url)
							let image = artwork?.image(at: artwork?.bounds.size ?? .zero)
							let book = Book(id: dto.id, title: dto.title, author: dto.author, artwork: image, chapters: files)
							books.append(book)
							
						case let .failure(error):
							await send(.errorOccurred(error.localizedDescription))
							return
						}
					}
					
					await send(.booksLoaded(books))
					await send(.restoreAudioSession)
				}
				
			case let .booksLoaded(books):
				state.books = books
				return .none
				
			case let .errorOccurred(error):
				state.errorMessage = error
				return .none
				
			case .errorAlertDismissed:
				state.errorMessage = nil
				return .none
				
			case let .saveBookFiles(files):
				guard !files.isEmpty else { return .none }
				
				return .run { send in
					let id = UUID()
					let result = fileService.saveBookAudioFiles(id, files)
					switch result {
					case let .success(urls):
						let title = try? await metaService.extractTitleFromURL(urls.first)
						let author = try? await metaService.extractAuthorFromURL(urls.first)
						let dto = BookDto(id: id, title: title ?? "-", author: author ?? "-", files: urls.map(\.relativeString))
						storageService.saveBooks([dto])
						await send(.viewDidLoad)
						
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
					}
				}
				
			case let .bookTapped(book):
				state.currentBook = book
				storageService.saveCurrentBook(book)
				
				guard let file = book.chapters.first else { return .none }
				
				return .run { send in
					await send(.audioSelected(file))
				}
				
			case let .audioSelected(file):
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
				storageService.saveCurrentAudio(file)
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
				
			case let .playbackStatusChanged(status):
				state.playbackStatus = status
				state.currentTime = makeTimeString(from: status.currentTime)
				state.duration = makeTimeString(from: status.duration)
				state.playerState = status.isPlaying ? .playing : .paused
				storageService.saveCurrentTime(status.currentTime)
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
				storageService.savePlaybackRate(newRate)
				return .none
				
			case .playNextTrackButtonTapped:
				guard let currentBook = state.currentBook,
					  let currentAudio = state.currentAudio,
					  let index = currentBook.chapters.firstIndex(of: currentAudio),
					  index < currentBook.chapters.count - 1
				else { return .none }
				
				let nextAudio = currentBook.chapters[index + 1]
				return .run { send in
					await send(.audioSelected(nextAudio))
				}
				
			case .playPreviousTrackButtonTapped:
				guard let currentBook = state.currentBook,
					  let currentAudio = state.currentAudio,
					  let index = currentBook.chapters.firstIndex(of: currentAudio)
				else { return .none }
				
				return .run { [state] send in
					let playbackStatus = state.playbackStatus
					if index > 0 {
						if playbackStatus?.currentTime ?? 0 > 5 {
							await send(.playbackSliderPositionChanged(0))
						} else {
							let previousAudio = currentBook.chapters[index - 1]
							await send(.audioSelected(previousAudio))
						}
					} else {
						await send(.playbackSliderPositionChanged(0))
					}
				}
				
			case .restoreAudioSession:
				guard let currentBookName = storageService.getCurrentBook() else { return .none }
				
				state.currentBook = state.books.first(where: { $0.title == currentBookName })
				
				guard let currentAudioName = storageService.getCurrentAudio(),
					  let file = state.currentBook?.chapters.first(where: { $0.name == currentAudioName }) else {
					return .none
				}
				
				state.currentAudio = file

				let currentTime = storageService.getCurrentTime()

				if case .success(()) = audioService.setupAudio(file: file, rate: state.playbackRate) {
					audioService.prepareToPlayRestoredAudio()
					return .run { send in
						await send(.playbackSliderPositionChanged(currentTime))
						for await currentStatus in audioService.playbackStatusStream {
							await send(.playbackStatusChanged(currentStatus))
						}
						await send(.playNextTrackButtonTapped)
					}
				}
				return .none
				
			case let .deleteBook(book):
				return .run { [filesToDelete = book.chapters] send in
					let result = fileService.deleteAudioFiles(filesToDelete)
					switch result {
					case let .failure(error):
						await send(.errorOccurred(error.localizedDescription))
						
					case .success(_):
						storageService.deleteBook(book)
						await send(.bookDeleted(book))
					}
				}
				
			case let .bookDeleted(book):
				state.books.removeAll(where: { $0 == book })
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
