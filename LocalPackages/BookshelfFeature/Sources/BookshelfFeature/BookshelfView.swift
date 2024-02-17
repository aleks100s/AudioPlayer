//
//  BookshelfView.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import SwiftUI
import ComposableArchitecture
import Shared

public struct BookshelfView: View {
	private let store: StoreOf<BookshelfFeature>
	
	private let columns: [GridItem] = [
		GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 16),
		GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 16)
	]
	
	@State private var isFilePickerPresented = false
	
	public init(store: StoreOf<BookshelfFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ScrollView {
				LazyVGrid(columns: columns, alignment: .center, spacing: 32) {
					ForEach(viewStore.books, id: \.title) { book in
						BookView(book: book)
					}
				}
				.padding()
			}
			.scrollIndicators(.hidden)
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
		}
	}
}

#Preview {
	BookshelfView(store: Store(initialState: BookshelfFeature.State(books: [.mock(title: "Книга 1"), .mock(title: "Книга 2"), .mock(title: "Книга 3"), .mock(title: "Книга 4")])) {
		BookshelfFeature()
	})
}
