//
//  AudioFile+Mock.swift
//
//
//  Created by Alexander on 17.12.2023.
//

import Domain
import Foundation

public extension AudioFile {
	static func mock(name: String = UUID().uuidString) -> AudioFile {
		AudioFile(name: name, url: URL(string: "url://\(UUID().uuidString)")!)
	}
}
