//
//  BookshelfFeature.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import BookMetaInfoService
import ComposableArchitecture
import Domain
import FileService
import StorageService
import UIKit

@Reducer
public struct BookshelfFeature {
	public struct State: Equatable {
		var books: [Book]
		var errorMessage: String?
		
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
	}
	
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
							let book = Book(title: dto.title, author: dto.author, artwork: image, chapters: files)
							books.append(book)
							
						case let .failure(error):
							await send(.errorOccurred(error.localizedDescription))
						}
					}
					await send(.booksLoaded(books))
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
			}
		}
	}
}
