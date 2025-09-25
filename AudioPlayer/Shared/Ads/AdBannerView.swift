//
//  AdBannerView.swift
//  CashbackManager
//
//  Created by Alexander on 25.01.2025.
//

import SwiftUI

struct AdBannerView: View {
    let bannerId: String
    
    @State private var height = 100.0

    var body: some View {
        _AdBannerView(bannerId: bannerId) {
            height = .zero
        }
        .frame(height: height)
    }
}

private struct _AdBannerView: UIViewControllerRepresentable {
    private let viewController: AdBannerViewController
    
    init(bannerId: String, onError: @escaping () -> Void) {
        viewController = AdBannerViewController(bannerId: bannerId, onError: onError)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let size = viewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        viewController.preferredContentSize = size
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

