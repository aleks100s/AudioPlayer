//
//  AudioListView.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import ComposableArchitecture
import Domain
import Shared
import SwiftUI

public struct AudioListView: View {
	private typealias AudioListViewStore = ViewStore<AudioListFeature.State, AudioListFeature.Action>
	
	private let store: StoreOf<AudioListFeature>
		
	@State private var isFilePickerPresented = false
	@State private var progress: Double = 0
	
	public init(store: StoreOf<AudioListFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			contentView(viewStore)
				.navigationTitle(viewStore.book.title)
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						Button(action: {
							isFilePickerPresented = true
						}, label: {
							Image(systemName: "plus.circle")
						})
					}
				}
				.fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.audio], allowsMultipleSelection: true, onCompletion: { results in
					switch results {
					case .success(let files):
						break
						// viewStore.send(.saveFiles(files))
						
					case .failure(let error):
						viewStore.send(.errorOccurred(error.localizedDescription))
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
	
	@ViewBuilder 
	private func contentView(_ viewStore: AudioListViewStore) -> some View {
		VStack {
			List {
				ForEach(viewStore.book.chapters, id: \.url.absoluteString) { file in
					audioFileItem(viewStore, file: file) {
						viewStore.send(.delegate(.audioSelected(file)))
					}
					.swipeActions(edge: .leading) {
						Button(file.isListened ? "Отметить непрослушанным" : "Отметить прослушанным") {
							viewStore.send(file.isListened ? .delegate(.markAsUnread(file)) : .delegate(.markAsRead(file)))
						}
						.tint(.green)
					}
				}
			}
		}
		.background(.thinMaterial)
	}
	
	@ViewBuilder 
	private func audioFileItem(
		_ viewStore: AudioListViewStore,
		file: AudioFile,
		onTap: @escaping () -> Void
	) -> some View {
		Button {
			onTap()
		} label: {
			HStack {
				VStack(alignment: .leading) {
					Text(file.name)
					if let duration = file.duration {
						Text(duration)
							.font(.caption)
							.foregroundStyle(.gray)
					}
				}
				
				Spacer()
				
				if viewStore.currentAudio == file {
					HStack(spacing: 4) {
						PlaybackIndicatorView(animationDuration: 1.0, isPlaying: viewStore.isPlaying)
						PlaybackIndicatorView(animationDuration: 0.6, isPlaying: viewStore.isPlaying)
						PlaybackIndicatorView(animationDuration: 1.4, isPlaying: viewStore.isPlaying)
					}
				} else if file.isListened {
					Image(systemName: "checkmark")
						.foregroundStyle(.green)
				}
			}
		}
		.tint(.primary)
	}
}

import DomainMock

#Preview {
	NavigationStack {
		AudioListView(store: Store(initialState: AudioListFeature.State(book: .mock(), currentAudio: nil, isPlaying: true)) {
			AudioListFeature()
		})
	}
}
