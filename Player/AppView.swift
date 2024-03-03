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
		
	var body: some View {
		NavigationStack {
			BookshelfView(store: store.scope(state: \.bookshelfState, action: { .bookshelf($0) }))
		}
	}
}

#Preview {
	AppView(store: Store(initialState: AppFeature.State()) {
		AppFeature()
	})
}
