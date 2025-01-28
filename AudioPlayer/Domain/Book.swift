//
//  Book.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import SwiftData
import UIKit

@Model
final class Book {
	private static let imageCache = NSCache<NSUUID, UIImage>()
	private static var chapterCache = [UUID: [Chapter]]()
	
	var id: UUID
	@Attribute(.spotlight)
	var title: String
	@Attribute(.spotlight)
	var author: String
	var currentChapter: Chapter?
	var progress = Double.zero
	var isFinished = false
	var totalDuration: String = ""
	@Attribute(.externalStorage)
	private var artworkImage: Data
	@Relationship(deleteRule: .cascade)
	private var chapters: [Chapter]
	
	var image: UIImage {
		Self.imageCache.object(forKey: id as NSUUID) ?? .placeholder
	}
	
	var orderedChapters: [Chapter] {
		Self.chapterCache[id] ?? []
	}
	
	init(id: UUID = UUID(), title: String, author: String, artworkData: Data?, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.artworkImage = artworkData ?? UIImage.placeholder.pngData() ?? Data()
		self.chapters = chapters
	}
	
	func prepareCache() {
		Self.imageCache.setObject(UIImage(data: artworkImage) ?? .placeholder, forKey: id as NSUUID)
		Self.chapterCache[id] = chapters.sorted(by: { $0.order < $1.order })
		calculateDuration()
	}
	
	func finishBook() {
		for chapter in orderedChapters {
			chapter.currentTime = .zero
		}
		currentChapter = nil
		isFinished = true
		progress = 1
	}
	
	func trackProgress() {
		progress = Double(chapters.filter(\.isListened).count) / Double(chapters.count)
	}
	
	func resetProgress() {
		for chapter in orderedChapters {
			chapter.isListened = false
		}
		isFinished = false
	}
	
	func append(chapters: [Chapter]) {
		self.chapters.append(contentsOf: chapters)
	}
	
	private func calculateDuration() {
		let secondsTotal = Int(chapters.map(\.duration).reduce(0, +))
		totalDuration = makeDurationString(using: secondsTotal)
	}
	
	private func makeDurationString(using seconds: Int) -> String {
		let isRULocale = Locale.current.identifier == "ru_RU"
		let secondsPart = seconds % 60
		guard seconds > 60 else {
			return isRULocale ? "\(secondsPart) сек" : "\(seconds) sec"
		}
	
		let minutes = seconds / 60
		let minutesPart = minutes % 60
		guard minutes > 60 else {
			return  isRULocale ? "\(minutesPart) мин \(secondsPart) сек" : "\(minutes) min \(secondsPart) sec"
		}
		
		let hours = minutes / 60
		let hoursPart = hours % 24
		guard hours > 24 else {
			return isRULocale ? "\(hoursPart) час \(minutesPart) мин \(secondsPart) сек" : "\(hoursPart) hrs \(minutesPart) min \(secondsPart) sec"
		}
		
		let daysTotal = hours / 24
		return  isRULocale ? "\(daysTotal)д \(hoursPart)ч \(minutesPart)м \(secondsPart)с" :"\(daysTotal)d \(hoursPart)h \(minutesPart)m \(secondsPart)s"
	}
}
