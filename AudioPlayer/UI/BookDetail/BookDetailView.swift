//
//  BookDetailView.swift
//  AudioPlayer
//
//  Created by Alexander on 11.09.2024.
//

import SwiftUI

struct BookDetailView: View {
	let book: Book
    
    @Environment(\.dismiss)
    private var dismiss
	
	var body: some View {
		NavigationView {
            List {
                Image(uiImage: book.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.title)
                        
                        Text(book.author)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }

                HStack {
                    Text("Количество глав")
                    
                    Spacer()
                    
                    Text("\(book.orderedChapters.count)")
                }
                
                HStack {
                    Text("Длительность книги")
                    
                    Spacer()
                    
                    Text(book.totalDuration)
                }
            }
			.navigationTitle("О книге")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
		}
	}
}
