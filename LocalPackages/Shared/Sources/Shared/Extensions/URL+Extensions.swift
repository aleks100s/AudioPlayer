//
//  URL+Extensions.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import Foundation

public extension URL {
	var isAudioFile: Bool {
		isFileURL && audioExtensions.contains(where: { $0 == pathExtension })
	}
	
	private var audioExtensions: [String] {
		["mp3", "wav", "m4a"]
	}
}
