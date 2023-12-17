//
//  EmptyFeatureView.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import ComposableArchitecture
import SwiftUI

struct EmptyFeatureView: View {
	let store: StoreOf<EmptyFeature>
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ZStack {
				Label(viewStore.state.title, systemImage: "globe")
			}
			.navigationTitle(viewStore.state.title)
			.onAppear {
				viewStore.send(.viewDidLoad)
			}
		}
	}
}

#Preview {
	EmptyFeatureView(store: Store(initialState: EmptyFeature.State(title: ""), reducer: { EmptyFeature() }))
}
