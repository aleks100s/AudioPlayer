//
//  AdBannerViewController.swift
//  CashbackManager
//
//  Created by Alexander on 25.01.2025.
//

import UIKit
import YandexMobileAds

final class AdBannerViewController: UIViewController {
	private let bannerId: String

	private lazy var adView: AdView = {
		let width = view.safeAreaLayoutGuide.layoutFrame.width
		let adSize = BannerAdSize.stickySize(withContainerWidth: width)
		let adView = AdView(adUnitID: bannerId, adSize: adSize)
		adView.translatesAutoresizingMaskIntoConstraints = false
		adView.delegate = self
		return adView
	}()
	
	init(bannerId: String) {
		self.bannerId = bannerId
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		adView.loadAd()
	}
	
	func showAd() {
		view.addSubview(adView)
		NSLayoutConstraint.activate([
			adView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])
	}
}

extension AdBannerViewController: AdViewDelegate {
	func adViewDidLoad(_ adView: AdView) {
		showAd()
	}
	
	func adViewDidFailLoading(_ adView: AdView, error: any Error) {}
}
