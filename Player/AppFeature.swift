//
//  AppFeature.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import AudioListFeature
import BookshelfFeature
import ComposableArchitecture
import Domain
import FileService
import Foundation

@Reducer
struct AppFeature {
	struct State: Equatable {
		var path = StackState<Path.State>()
		var bookshelfState = BookshelfFeature.State()
	}
	
	enum Action: Equatable {
		case path(StackAction<Path.State, Path.Action>)
		case audioList(AudioListFeature.Action)
		case bookshelf(BookshelfFeature.Action)
	}
	
	struct Path: Reducer {
		enum State: Equatable {
			case audioList(AudioListFeature.State)
		}
		
		enum Action: Equatable {
			case audioList(AudioListFeature.Action)
		}
		
		var body: some ReducerOf<Self> {
			Scope(state: /State.audioList, action: /Action.audioList) {
				AudioListFeature()
			}
		}
	}
		
	var body: some ReducerOf<Self> {
		Scope(state: \.bookshelfState, action: /Action.bookshelf) {
			BookshelfFeature()
		}
		
		Reduce { state, action in
			switch action {
			case let .bookshelf(bookshelfAction):
				switch bookshelfAction {
				case let .bookOpened(book):
					print(book)
					// state.path.append(.audioList(AudioListFeature.State(book: book)))
					
				default:
					break
				}
				return .none
				
			default:
				return .none
			}
		}
	}
}
