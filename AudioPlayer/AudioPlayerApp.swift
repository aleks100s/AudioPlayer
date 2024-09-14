//
//  AudioPlayerApp.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftData
import SwiftUI
import TipKit

@main
struct AudioPlayerApp: App {
	private static let modelContainer = try! ModelContainer(for: Book.self, Chapter.self)
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	init() {
		ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageTransformer"))
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.task {
					try? Tips.configure([
						.displayFrequency(.immediate),
						.datastoreLocation(.applicationDefault)
					])
				}
        }
		.modelContainer(Self.modelContainer)
    }
}
