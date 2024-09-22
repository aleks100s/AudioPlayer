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
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.task {
					try? Tips.configure([
						.displayFrequency(.daily),
						.datastoreLocation(.applicationDefault)
					])
				}
        }
		.modelContainer(for: [Book.self, Chapter.self], isAutosaveEnabled: true)
    }
}
