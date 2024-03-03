//
//  BookshelfView.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import AudioListFeature
import ComposableArchitecture
import Domain
import Shared
import SwiftUI

public struct BookshelfView: View {
	private typealias BookshelfViewStore = ViewStore<BookshelfFeature.State, BookshelfFeature.Action>
	
	private let store: StoreOf<BookshelfFeature>
	
	@State private var isFilePickerPresented = false
	@State private var progress: Double = 0
	@State private var durationRange: ClosedRange<TimeInterval> = 0...0
	@State private var isSliderBusy = false
	
	public init(store: StoreOf<BookshelfFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ZStack {
				ScrollView {
					LazyVStack(spacing: 16) {
						ForEach(viewStore.books, id: \.title) { book in
							let isPlaying = viewStore.currentBook == book && viewStore.playerState == .playing
							BookView(book: book, isPlaying: isPlaying) {
								menuContent(for: book)
							}
							.highPriorityGesture(
								TapGesture()
									.onEnded { _ in
										viewStore.send(.bookTapped(book))
									}
							)
							.contextMenu {
								menuContent(for: book)
							}
						}
						Spacer()
							.frame(height: 176)
					}
					.padding()
				}
				.scrollIndicators(.hidden)
				
				if viewStore.playerState != .hidden {
					VStack {
						Spacer()
						playerView(viewStore)
					}
				}
			}
			.navigationTitle("Мои книги")
			.onFirstAppear {
				viewStore.send(.viewDidLoad)
			}
			.alert(
				item: viewStore.binding(
					get: { $0.errorMessage.map(ErrorAlert.init(title:)) },
					send: .errorAlertDismissed
				),
				content: { Alert(title: Text($0.title)) }
			)
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
					viewStore.send(.saveBookFiles(files))
					
				case .failure(let error):
					viewStore.send(.errorOccurred(error.localizedDescription))
				}
			})
			.onChange(of: viewStore.playbackStatus, initial: false) { _, newValue in
				if !isSliderBusy {
					progress = newValue?.currentTime ?? 0
					durationRange = 0...(newValue?.duration ?? 0)
				}
			}
			.sheet(
				store: self.store.scope(
					state: \.$audioList,
					action: { .audioListAction($0) }
				)
			) { (store: StoreOf<AudioListFeature>) in
				NavigationStack {
					AudioListView(store: store)
				}
			}
		}
	}
	
	@ViewBuilder
	private func menuContent(for book: Book) -> some View {
		Button() {
			store.send(.bookOpened(book))
		} label: {
			Label("Открыть книгу", systemImage: "list")
		}
		
		Button(role: .destructive) {
			store.send(.deleteBook(book))
		} label: {
			Label("Удалить книгу", systemImage: "trash")
		}
	}
	
	@ViewBuilder
	private func playerView(_ viewStore: BookshelfViewStore) -> some View {
		VStack(alignment: .center, spacing: 12) {
			Text(viewStore.currentAudio?.name ?? "-")
				.font(.title3)
			
			seeker(viewStore)
			
			controls(viewStore)
			
			playbackRate(viewStore)
		}
		.padding()
		.padding(.bottom, 16)
		.background(.regularMaterial)
	}
	
	@ViewBuilder
	private func seeker(_ viewStore: BookshelfViewStore) -> some View {
		HStack {
			Text(viewStore.currentTime)
				.monospaced()
			Slider(value: $progress, in: durationRange) { isSliderBusy in
				self.isSliderBusy = isSliderBusy
			}
			.onChange(of: progress) { _, newValue in
				if isSliderBusy {
					viewStore.send(.playbackSliderPositionChanged(newValue))
				}
			}
			Text(viewStore.duration)
				.monospaced()
		}
	}
	
	@ViewBuilder
	private func playbackRate(_ viewStore: BookshelfViewStore) -> some View {
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
	private func controls(_ viewStore: BookshelfViewStore) -> some View {
		HStack {
			Spacer()
			moveBackwardButton(viewStore)
			Spacer()
			skipBackwardButton(viewStore)
			Spacer()
			playButton(viewStore)
			Spacer()
			skipForwardButton(viewStore)
			Spacer()
			moveForwardButton(viewStore)
			Spacer()
		}
	}
	
	@ViewBuilder
	private func moveBackwardButton(_ viewStore: BookshelfViewStore) -> some View {
		Button {
			viewStore.send(.playPreviousTrackButtonTapped)
		} label: {
			Image(systemName: "backward.end.fill")
				.font(.title)
		}
	}
		
	@ViewBuilder
	private func skipBackwardButton(_ viewStore: BookshelfViewStore) -> some View {
		Button {
			viewStore.send(.skipBackwardButtonTapped)
		} label: {
			Image(systemName: "gobackward.\(Constants.skipBackwardInterval)")
				.font(.title)
		}
	}
	
	@ViewBuilder
	private func playButton(_ viewStore: BookshelfViewStore) -> some View {
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
	private func skipForwardButton(_ viewStore: BookshelfViewStore) -> some View {
		Button {
			viewStore.send(.skipForwardButtonTapped)
		} label: {
			Image(systemName: "goforward.\(Constants.skipForwardInterval)")
				.font(.title)
		}
	}
	
	@ViewBuilder
	private func moveForwardButton(_ viewStore: BookshelfViewStore) -> some View {
		Button {
			viewStore.send(.playNextTrackButtonTapped)
		} label: {
			Image(systemName: "forward.end.fill")
				.font(.title)
		}
	}
}

#Preview {
	BookshelfView(store: Store(initialState: BookshelfFeature.State(books: [.mock(title: "Книга 1"), .mock(title: "Книга 2"), .mock(title: "Книга 3"), .mock(title: "Книга 4")])) {
		BookshelfFeature()
	})
}
