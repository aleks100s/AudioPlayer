//
//  BookshelfView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct BookshelfView: View {
	let books: [Book]
	
	@State private var isFilePickerPresented = false
	
	var body: some View {
		ZStack {
			ScrollView {
				LazyVStack(spacing: 16) {
					ForEach(books) { book in
						// let isPlaying = viewStore.currentBook == book && viewStore.playerState == .playing
						BookView(book: book, isPlaying: false) {
							menuContent(for: book)
						}
						.highPriorityGesture(
							TapGesture()
								.onEnded { _ in
									// viewStore.send(.bookTapped(book))
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
			
//			if viewStore.playerState != .hidden {
//				VStack {
//					Spacer()
//					playerView(viewStore)
//				}
//			}
			
//			if let time = viewStore.sliderProgress {
//				VStack {
//					Text(time)
//						.font(.title2)
//						.monospaced()
//						.padding(.horizontal, 16)
//						.padding(.vertical, 32)
//						.background(.regularMaterial)
//						.clipShape(RoundedRectangle(cornerRadius: 16))
//					
//					Spacer()
//						.frame(height: 50)
//				}
//			}
		}
		.navigationTitle("Мои книги")
		.onFirstAppear {
			// viewStore.send(.viewDidLoad)
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					isFilePickerPresented = true
				} label: {
					Image(systemName: "plus.circle")
				}
			}
		}
		.fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.audio], allowsMultipleSelection: true, onCompletion: { results in
			switch results {
			case .success(let files):
				break
				// viewStore.send(.saveBookFiles(files))
				
			case .failure(let error):
				break
				// viewStore.send(.errorOccurred(error.localizedDescription))
			}
		})
	}
	
	@ViewBuilder
	private func menuContent(for book: Book) -> some View {
		Button {
			// store.send(.bookOpened(book))
		} label: {
			Label("Показать главы", systemImage: "list")
		}
		
		Button(role: .destructive) {
			// store.send(.deleteBook(book))
		} label: {
			Label("Удалить книгу", systemImage: "trash")
		}
	}
}
