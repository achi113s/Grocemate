//
//  PolishedButtonStyle.swift
//  Grocemate
//
//  Created by Giorgio Latour on 4/2/24.
//

import SwiftUI

extension ButtonStyle where Self == PolishedButtonStyle {
    static var polished: PolishedButtonStyle {
        PolishedButtonStyle()
    }
}

struct PolishedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    private var cornerRadius: CGFloat
    private var highlightWidth: CGFloat

    private var highlightGradient: LinearGradient = LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.005)],
                                                                   startPoint: .top, endPoint: .bottom)

    private var innerGradient: LinearGradient
    private var innerGradientDisabled = LinearGradient(colors: [.white.opacity(0.7), .white.opacity(0.5)],
                                                       startPoint: .top, endPoint: .bottom)

    private var foregroundColor: Color
    private var color: Color

    init(cornerRadius: CGFloat = 15,
         highlightWidth: CGFloat = 1.2,
         color: Color = .blue,
         foregroundColor: Color = .white
    ) {
        self.cornerRadius = cornerRadius
        self.highlightWidth = highlightWidth
        self.innerGradient = LinearGradient(colors: [color.opacity(0.7), color.opacity(0.5)],
                                            startPoint: .top, endPoint: .bottom)
        self.color = color
        self.foregroundColor = foregroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? foregroundColor : Color(white: 0.6))
            .overlay {
                configuration.label
                    .foregroundStyle(foregroundColor)
                    .opacity(isEnabled ? 0.0 : 1.0)
                    .blendMode(.color)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isEnabled ? color : Color(white: 0.85))
                    RoundedRectangle(cornerRadius: cornerRadius - highlightWidth)
                        .fill(highlightGradient)
                        .padding(highlightWidth)
                    RoundedRectangle(cornerRadius: cornerRadius - (highlightWidth * 2.5))
                        .fill(isEnabled ? innerGradient : highlightGradient)
                        .padding(highlightWidth * 2.5)
                }
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(configuration.isPressed ? 0.2 : 0.0))
            }
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
