//
//  ErrorAlert.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

struct ErrorAlert: Identifiable {
	var title: String
	var id: String { self.title }
	
	init(title: String) {
		self.title = title
	}
}
