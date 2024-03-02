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
		var bookshelfState = BookshelfFeature.State()
	}
	
	enum Action: Equatable {
		case bookshelf(BookshelfFeature.Action)
	}
		
	var body: some ReducerOf<Self> {
		Scope(state: \.bookshelfState, action: /Action.bookshelf) {
			BookshelfFeature()
		}
	}
}
