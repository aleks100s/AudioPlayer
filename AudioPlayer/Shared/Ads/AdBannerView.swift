//
//  AdBannerView.swift
//  CashbackManager
//
//  Created by Alexander on 25.01.2025.
//

import SwiftUI

struct AdBannerView: UIViewControllerRepresentable {
	private let viewController: AdBannerViewController
	
	init(bannerId: String) {
		viewController = AdBannerViewController(bannerId: bannerId)
	}

	func makeUIViewController(context: Context) -> UIViewController {
		let size = viewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		viewController.preferredContentSize = size
		return viewController
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

