//
//  AudioPlayerApp.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftData
import SwiftUI

@main
struct AudioPlayerApp: App {
	private static let modelContainer = try! ModelContainer(for: Book.self, Chapter.self)
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.modelContainer(Self.modelContainer)
    }
}