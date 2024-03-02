//
//  BookView.swift
//  
//
//  Created by Alexander on 17.02.2024.
//

import Domain
import SwiftUI

struct BookView: View {
	private let book: Book
	private let isPlaying: Bool
	
	init(book: Book, isPlaying: Bool = false) {
		self.book = book
		self.isPlaying = isPlaying
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: .zero) {
			Image(uiImage: book.artwork ?? UIImage(resource: .placeholder))
				.resizable()
				.aspectRatio(1, contentMode: .fill)
				.clipShape(RoundedRectangle(cornerRadius: 16))
			
			HStack {
				VStack(alignment: .leading) {
					Text(book.title)
						.font(.footnote)
						.lineLimit(2)
					
					Text(book.author)
						.font(.caption)
						.lineLimit(1)
						.foregroundStyle(.gray)
				}
				.padding()
				
				Spacer()
				
				Image(systemName: isPlaying ? "pause.circle" : "play.circle")
					.padding()
			}
		}
		.background(.regularMaterial.opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
}

import DomainMock

#Preview {
	BookView(book: .mock(), isPlaying: false)
		.frame(width: 200, height: 200)
}
