//
//  ErrorAlert.swift
//
//
//  Created by Alexander on 17.12.2023.
//

public struct ErrorAlert: Identifiable {
	public var title: String
	public var id: String { self.title }
	
	public init(title: String) {
		self.title = title
	}
}
