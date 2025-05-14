//
//  ContentView.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationView {
			BookshelfView()
				.background(.linearGradient(
					colors: [
						.cyan.opacity(0.2),
						.purple.opacity(0.2)
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				))
		}
    }
}
