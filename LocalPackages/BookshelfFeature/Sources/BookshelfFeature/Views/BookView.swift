//
//  BookView.swift
//  
//
//  Created by Alexander on 17.02.2024.
//

import Domain
import SwiftUI

struct BookView<MenuContent: View>: View {
	private let book: Book
	private let isPlaying: Bool
	private let menuContent: () -> MenuContent
	
	init(book: Book, isPlaying: Bool, menuContent: @escaping () -> MenuContent) {
		self.book = book
		self.isPlaying = isPlaying
		self.menuContent = menuContent
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading, spacing: .zero) {
				ZStack {
					Image(uiImage: book.artwork ?? UIImage(resource: .placeholder))
						.resizable()
						.aspectRatio(1, contentMode: .fill)
						.clipShape(RoundedRectangle(cornerRadius: 16))
					
					VStack {
						Spacer()
						
						HStack {
							VStack(alignment: .leading) {
								Text(book.title)
									.font(.headline)
									.lineLimit(2)
								
								Text(book.author)
									.font(.subheadline)
									.lineLimit(1)
									.foregroundStyle(.gray)
							}
							
							Spacer()
						}
						.padding()
						.background(.ultraThinMaterial)
					}
				}
				
				HStack {
					if let chapter = book.currentChapterName {
						Text("\(isPlaying ? "сейчас играет:" : "продолжить прослушивание:") \(chapter)")
							.font(.footnote)
					}
					
					Spacer()
					
					Image(systemName: isPlaying ? "pause.circle" : "play.circle")
				}
				.padding()
			}
			.background(.regularMaterial.opacity(0.6))
			.clipShape(RoundedRectangle(cornerRadius: 16))
			
			HStack {
				Spacer()
				
				VStack {
					Menu {
						menuContent()
					} label: {
						Image(systemName: "ellipsis.circle.fill")
					}
					.padding()
					
					Spacer()
				}
			}
		}
	}
}

import DomainMock

#Preview {
	BookView(book: .mock(), isPlaying: false, menuContent: { EmptyView() })
		.frame(width: 200, height: 200)
}
