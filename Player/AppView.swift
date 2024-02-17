//
//  AppView.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import AudioListFeature
import BookshelfFeature
import ComposableArchitecture
import SwiftUI

struct AppView: View {
	let store: StoreOf<AppFeature>
	
	@State private var isPresented = false
	
	var body: some View {
		NavigationStackStore(
			self.store.scope(
				state: \.path,
				action: { .path($0) }
			),
			root: {
				BookshelfView(store: store.scope(state: \.bookshelfState, action: { .bookshelf($0) }))
			},
			destination: { state in
				switch state {
				case .empty:
					CaseLet(
						/AppFeature.Path.State.empty,
						 action: AppFeature.Path.Action.empty,
						 then: EmptyFeatureView.init(store:)
					)
				}
			}
		)
	}
}

#Preview {
	AppView(store: Store(initialState: AppFeature.State()) {
		AppFeature()
	})
}
