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
	@State private var searchText = ""
	@State private var progress: Double = 0
	@State private var durationRange: ClosedRange<TimeInterval> = 0...0
	
	public init(store: StoreOf<AudioListFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			VStack {
				List {
					ForEach(viewStore.filteredFiles, id: \.url.absoluteString) { file in
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
					VStack(alignment: .center, spacing: 12) {
						Text(viewStore.currentAudio?.name ?? "-")
							.font(.title3)
						
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
									.font(.title)
							}
							Spacer()
						}
						
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
					.padding()
				}
			}
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
}


#Preview {
	NavigationStack {
		AudioListView(store: Store(initialState: AudioListFeature.State()) {
			AudioListFeature()
		})
	}
}
