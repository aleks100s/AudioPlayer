//
//  Chapter+Mock.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation

extension Chapter {
	static func arbitrary(name: String) -> Chapter {
		Chapter(name: name, url: URL(string: "url://\(UUID().uuidString)")!)
	}
}

extension [Chapter] {
	static func arbitrary() -> [Chapter] {
		[
			.arbitrary(name: "Глава 1"),
			.arbitrary(name: "Глава 2"),
			.arbitrary(name: "Глава 3")
		]
	}
}
