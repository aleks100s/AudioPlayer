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
	@State private var searchText = ""
	@State private var progress: Double = 0
	@State private var durationRange: ClosedRange<TimeInterval> = 0...0
	
	public init(store: StoreOf<AudioListFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			contentView(viewStore)
				.searchable(text: $searchText)
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
				.onChange(of: searchText, initial: false) { _, newValue in
					viewStore.send(.searchTextChanged(newValue))
				}
				.onChange(of: viewStore.playbackStatus, initial: false) { _, newValue in
					progress = newValue?.currentTime ?? 0
					durationRange = 0...(newValue?.duration ?? 0)
				}
		}
	}
	
	@ViewBuilder 
	private func contentView(_ viewStore: AudioListViewStore) -> some View {
		VStack {
			List {
				ForEach(viewStore.filteredFiles, id: \.url.absoluteString) { file in
					audioFileItem(viewStore, file: file) {
						viewStore.send(.audioTapped(file))
					}
				}
				.onDelete { indexSet in
					viewStore.send(.deleteFiles(indexSet))
				}
			}
			
			if viewStore.playerState != .hidden {
				playerView(viewStore)
			}
		}
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
				Text(file.name)
				
				Spacer()
				
				if viewStore.currentAudio == file {
					let isPlaying = viewStore.playbackStatus?.isPlaying ?? false
					HStack(spacing: 4) {
						PlaybackIndicatorView(animationDuration: 1.0, isPlaying: isPlaying)
						PlaybackIndicatorView(animationDuration: 0.6, isPlaying: isPlaying)
						PlaybackIndicatorView(animationDuration: 1.4, isPlaying: isPlaying)
					}
				}
			}
		}
		.tint(.primary)
	}
	
	@ViewBuilder
	private func playerView(_ viewStore: AudioListViewStore) -> some View {
		VStack(alignment: .center, spacing: 12) {
			Text(viewStore.currentAudio?.name ?? "-")
				.font(.title3)
			
			seeker(viewStore)
			
			controls(viewStore)
			
			playbackRate(viewStore)
		}
		.padding()
		.padding(.bottom, 16)
	}
	
	@ViewBuilder 
	private func seeker(_ viewStore: AudioListViewStore) -> some View {
		HStack {
			Text(viewStore.currentTime)
				.monospaced()
			Slider(value: $progress, in: durationRange) { _ in
				viewStore.send(.playbackSliderPositionChanged(progress))
			}
			Text(viewStore.duration)
				.monospaced()
		}
	}
	
	@ViewBuilder
	private func playbackRate(_ viewStore: AudioListViewStore) -> some View {
		HStack {
			Button {
				viewStore.send(.changePlaybackRateButtonTapped)
			} label: {
				Text("Speed \(viewStore.playbackRate.title)")
			}

			Spacer()
		}
	}
	
	@ViewBuilder
	private func controls(_ viewStore: AudioListViewStore) -> some View {
		HStack {
			Spacer()
			skipBackwardButton(viewStore)
			Spacer()
			playButton(viewStore)
			Spacer()
			skipForwardButton(viewStore)
			Spacer()
		}
	}
	
	@ViewBuilder
	private func skipBackwardButton(_ viewStore: AudioListViewStore) -> some View {
		Button {
			viewStore.send(.skipBackwardButtonTapped)
		} label: {
			Image(systemName: "gobackward.\(Constants.skipBackwardInterval)")
				.font(.title)
		}
	}
	
	@ViewBuilder
	private func playButton(_ viewStore: AudioListViewStore) -> some View {
		Button {
			if viewStore.playerState == .playing {
				viewStore.send(.pauseButtonTapped)
			} else if viewStore.playerState == .paused {
				viewStore.send(.resumeButtonTapped)
			}
		} label: {
			Image(systemName: viewStore.playerState.imageName)
				.font(.title)
		}
	}
	
	@ViewBuilder
	private func skipForwardButton(_ viewStore: AudioListViewStore) -> some View {
		Button {
			viewStore.send(.skipForwardButtonTapped)
		} label: {
			Image(systemName: "goforward.\(Constants.skipForwardInterval)")
				.font(.title)
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
