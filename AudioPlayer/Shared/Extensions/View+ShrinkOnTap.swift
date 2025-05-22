//
//  View+ShrinkOnTap.swift
//  AudioPlayer
//
//  Created by Alexander on 15.05.2025.
//

import SwiftUI

extension View {
	func shrinkOnTap() -> some View {
		modifier(ShrinkOnTapModifier())
	}
}

private struct ShrinkOnTapModifier: ViewModifier {
	@State private var isPressed = false

	func body(content: Content) -> some View {
		content
			.scaleEffect(isPressed ? 0.9 : 1.0)
			.animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
			.simultaneousGesture(
				DragGesture(minimumDistance: 0)
					.onChanged { _ in
						isPressed = true
					}
					.onEnded { _ in
						isPressed = false
						// здесь можно вызвать действие кнопки
					}
			)
	}
}
