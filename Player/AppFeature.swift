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
		var audioListState = AudioListFeature.State()
		var bookshelfState = BookshelfFeature.State()
	}
	
	enum Action: Equatable {
		case path(StackAction<Path.State, Path.Action>)
		case audioList(AudioListFeature.Action)
		case bookshelf(BookshelfFeature.Action)
	}
	
	struct Path: Reducer {
		enum State: Equatable {
			case empty(EmptyFeature.State)
		}
		
		enum Action: Equatable {
			case empty(EmptyFeature.Action)
		}
		
		var body: some ReducerOf<Self> {
			Scope(state: /State.empty, action: /Action.empty) {
				EmptyFeature()
			}
		}
	}
		
	var body: some ReducerOf<Self> {
		Scope(state: \.bookshelfState, action: /Action.bookshelf) {
			BookshelfFeature()
		}
		
		Scope(state: \.audioListState, action: /Action.audioList) {
			AudioListFeature()
		}
		
		Reduce { state, action in
			switch action {
			case let .audioList(audioListAction):
				switch audioListAction {
				case .test:
					state.path.append(.empty(EmptyFeature.State(title: "Hello, world!")))
					
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
