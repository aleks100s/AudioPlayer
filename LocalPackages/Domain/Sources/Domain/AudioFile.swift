//
//  AudioFile.swift
//  Player
//
//  Created by Alexander on 17.12.2023.
//

import Foundation

public struct AudioFile: Equatable {
	public let name: String
	public let url: URL
	public var duration: String?
	
	public init(name: String, url: URL) {
		self.name = name
		self.url = url
	}
	
	public init(url: URL) {
		self.url = url
		name = url.lastPathComponent
	}
}
