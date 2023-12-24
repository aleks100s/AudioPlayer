//
//  AudioListView.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import ComposableArchitecture
import Shared
import SwiftUI

public struct AudioListView: View {
	private let store: StoreOf<AudioListFeature>
	
	@State private var isFilePickerPresented = false
	
	public init(store: StoreOf<AudioListFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			VStack {
				List {
					ForEach(viewStore.files, id: \.url.absoluteString) { file in
						Button {
							viewStore.send(.audioTapped(file))
						} label: {
							HStack {
								Text(file.name)
								Spacer()
							}
						}
						.tint(.primary)
					}
					.onDelete { indexSet in
						viewStore.send(.deleteFiles(indexSet))
					}
				}
				
				if viewStore.playerState != .hidden {
					HStack {
						Spacer()
						Button {
							if viewStore.playerState == .playing {
								viewStore.send(.pauseButtonTapped)
							} else if viewStore.playerState == .paused {
								viewStore.send(.resumeButtonTapped)
							}
						} label: {
							Image(systemName: viewStore.playerState.imageName)
						}
						Spacer()
					}
					.padding()
				}
			}
			.navigationTitle("All audio")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(action: {
						isFilePickerPresented = true
					}, label: {
						Image(systemName: "plus.circle")
					})
				}
				
				ToolbarItem(placement: .topBarLeading) {
					Button(action: {
						viewStore.send(.test)
					}, label: {
						Text("Test")
					})
				}
			}
			.fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.audio], allowsMultipleSelection: true, onCompletion: { results in
				switch results {
				case .success(let files):
					viewStore.send(.saveFiles(files))
					
				case .failure(let error):
					print(error)
				}
			})
			.onAppear {
				viewStore.send(.viewDidLoad)
			}
			.alert(
				item: viewStore.binding(
					get: { $0.errorMessage.map(ErrorAlert.init(title:)) },
					send: .errorAlertDismissed
				),
				content: { Alert(title: Text($0.title)) }
			)
		}
	}
}


#Preview {
	NavigationStack {
		AudioListView(store: Store(initialState: AudioListFeature.State()) {
			AudioListFeature()
		})
	}
}
