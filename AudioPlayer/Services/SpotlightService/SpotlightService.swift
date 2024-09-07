//
//  SpotlightService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import CoreSpotlight
import UIKit

struct SpotlightService: ISpotlightService {
	func index(book: Book) {
		let bookAttributes = createAttributes(title: book.title, description: book.author)
		index(id: book.id, attributes: bookAttributes)
	}
	
	func deindex(book: Book) {
		deindex(id: book.id)
	}
}

private extension SpotlightService {
	func createAttributes(
		title: String,
		description: String,
		image: UIImage? = nil
	) -> CSSearchableItemAttributeSet {
		let attributeSet = CSSearchableItemAttributeSet(itemContentType: UTType.text.identifier)
		attributeSet.title = title
		attributeSet.contentDescription = description
		attributeSet.thumbnailData = image?.pngData()
		return attributeSet
	}
	
	func index(id: UUID, attributes: CSSearchableItemAttributeSet) {
		let item = CSSearchableItem(uniqueIdentifier: id.uuidString, domainIdentifier: Constants.appIdentifier, attributeSet: attributes)
		CSSearchableIndex.default().indexSearchableItems([item]) { error in
			if let error = error {
				print("Indexing error: \(error.localizedDescription)")
			} else {
				print("Search item successfully indexed!")
			}
		}
	}
	
	func deindex(id: UUID) {
		CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id.uuidString]) { error in
			if let error = error {
				print("Deindexing error: \(error.localizedDescription)")
			} else {
				print("Search item successfully removed!")
			}
		}
	}
}
