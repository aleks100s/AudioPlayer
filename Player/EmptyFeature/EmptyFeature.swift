//
//  EmptyFeature.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import ComposableArchitecture

@Reducer
struct EmptyFeature {
	struct State: Equatable {
		var title: String
	}
	
	enum Action: Equatable {
		case viewDidLoad
	}
	
	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .viewDidLoad:
				state.title = "Hello, world!"
				return .none
			}
		}
	}
}
