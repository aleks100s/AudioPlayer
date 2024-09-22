//
//  BookDetailView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI

struct BookDetailView: View {
	let book: Book
	
	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack {
					Image(uiImage: book.image)
						.resizable()
						.aspectRatio(1, contentMode: .fill)
						.overlay(alignment: .bottomLeading) {
							HStack {
								VStack(alignment: .leading) {
									Text(book.title)
										.font(.title)
									
									Text(book.author)
										.foregroundStyle(.secondary)
								}
								.padding()
								
								Spacer()
							}
							.background(.thinMaterial)
						}
				}
			}
			.navigationTitle("О книге")
		}
	}
}
