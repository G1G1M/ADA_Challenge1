import SwiftUI

struct HologramModifier: ViewModifier {
    @StateObject private var gyro = GyroscopeManager()
    
    private var gradientStart: UnitPoint {
        UnitPoint(x: min(max(0.5 + gyro.normalizedY * 1.2, 0), 1),
                  y: min(max(0.5 + gyro.normalizedX * 1.2, 0), 1))
    }
    private var gradientEnd: UnitPoint {
        UnitPoint(x: min(max(0.5 - gyro.normalizedY * 1.2, 0), 1),
                  y: min(max(0.5 - gyro.normalizedX * 1.2, 0), 1))
    }
    private var lightStart: UnitPoint {
        UnitPoint(x: min(max(0.5 + gyro.normalizedY * 0.9, 0), 1),
                  y: min(max(0.5 + gyro.normalizedX * 0.9, 0), 1))
    }
    private var lightEnd: UnitPoint {
        UnitPoint(x: min(max(0.5 - gyro.normalizedY * 0.9, 0), 1),
                  y: min(max(0.5 - gyro.normalizedX * 0.9, 0), 1))
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 20))  // ← 1. 먼저 클립
            .overlay(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.23, blue: 0.19).opacity(0.5),
                            Color(red: 1.00, green: 0.58, blue: 0.00).opacity(0.5),
                            Color(red: 1.00, green: 0.80, blue: 0.00).opacity(0.5),
                            Color(red: 0.30, green: 0.85, blue: 0.39).opacity(0.5),
                            Color(red: 0.20, green: 0.67, blue: 0.86).opacity(0.5),
                            Color(red: 0.35, green: 0.34, blue: 0.84).opacity(0.5),
                            Color(red: 1.00, green: 0.23, blue: 0.19).opacity(0.5),
                        ],
                        startPoint: gradientStart,
                        endPoint: gradientEnd
                    )
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.1), location: 0.0),
                                .init(color: .white.opacity(0.6), location: 0.4),
                                .init(color: .white.opacity(0.6), location: 0.6),
                                .init(color: .white.opacity(0.1), location: 1.0),
                            ],
                            startPoint: lightStart,
                            endPoint: lightEnd
                        )
                    )
                    .blendMode(.softLight)
                    
                    RadialGradient(
                        colors: [
                            .white.opacity(0.12),
                            .white.opacity(0.04),
                            .clear,
                        ],
                        center: UnitPoint(
                            x: min(max(0.5 + gyro.normalizedY * 0.5, 0), 1),
                            y: min(max(0.5 + gyro.normalizedX * 0.5, 0), 1)
                        ),
                        startRadius: 10,
                        endRadius: 300
                    )
                    .blendMode(.softLight)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))  // 2. 오버레이도 클립
            )
            .rotation3DEffect(.degrees(gyro.rotateX),  // 3. 그 다음 3D 효과
                              axis: (x: 1, y: 0, z: 0),
                              perspective: 0.5)
            .rotation3DEffect(.degrees(gyro.rotateY),
                              axis: (x: 0, y: 1, z: 0),
                              perspective: 0.5)
            .shadow(color: .black.opacity(0.45),
                    radius: 28,
                    x: gyro.rotateY * 1.8,
                    y: -gyro.rotateX * 1.8)
            .onAppear  { gyro.start() }
            .onDisappear { gyro.stop() }
    }
}

extension View {
    func hologramEffect() -> some View {
        modifier(HologramModifier())
    }
}
