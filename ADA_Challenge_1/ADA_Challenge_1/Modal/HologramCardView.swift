import SwiftUI
import CoreMotion
import Combine

// MARK: - Gyroscope Manager

class GyroscopeManager: ObservableObject {
    @Published var rotateX: Double = 0
    @Published var rotateY: Double = 0

    private let motionManager = CMMotionManager()
    private let maxAngle: Double = 15
    private let sensitivity: Double = 0.5
    private var prevTime: Date = Date()

    /// 기울기를 -1 ~ 1로 정규화
    var normalizedX: Double { rotateX / maxAngle }
    var normalizedY: Double { rotateY / maxAngle }

    func start() {
        guard motionManager.isGyroAvailable else {
            print("⚠️ 자이로스코프를 사용할 수 없습니다 (시뮬레이터는 미지원)")
            return
        }
        motionManager.gyroUpdateInterval = 1.0 / 60.0  // 60fps
        prevTime = Date()

        motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let now = Date()
            let dt = now.timeIntervalSince(self.prevTime)
            self.prevTime = now

            let rad2deg = 180.0 / Double.pi

            // rad/s × s × deg/rad = deg (원문과 동일한 변환)
            self.rotateX = self.clamp(
                self.rotateX + data.rotationRate.x * self.sensitivity * dt * rad2deg,
                lo: -self.maxAngle, hi: self.maxAngle
            )
            self.rotateY = self.clamp(
                self.rotateY - data.rotationRate.y * self.sensitivity * dt * rad2deg,
                lo: -self.maxAngle, hi: self.maxAngle
            )
        }
    }

    func stop() {
        motionManager.stopGyroUpdates()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            rotateX = 0
            rotateY = 0
        }
    }

    private func clamp(_ v: Double, lo: Double, hi: Double) -> Double {
        min(max(v, lo), hi)
    }
}

// MARK: - Hologram Card

struct HologramCardView: View {
    
    let imageName: String
    var width: CGFloat = 300
    var height: CGFloat = 420 
    
    @StateObject private var gyro = GyroscopeManager()

    private var cardWidth: CGFloat { width }   // ← 수정!
    private var cardHeight: CGFloat { height } // ← 수정!
    
    private let corner: CGFloat     = 20

    // ── 기울기에 따라 이동하는 그라디언트 기준점 ──────────────────────
    // 원문의 gradientStart/gradientEnd 계산을 UnitPoint로 대응

    // 기울기에 따라 색상이 전체적으로 스윕되는 느낌
    private var gradientStart: UnitPoint {
        UnitPoint(x: clamp01(0.5 + gyro.normalizedY * 1.2),
                  y: clamp01(0.5 + gyro.normalizedX * 1.2))
    }
    private var gradientEnd: UnitPoint {
        UnitPoint(x: clamp01(0.5 - gyro.normalizedY * 1.2),
                  y: clamp01(0.5 - gyro.normalizedX * 1.2))
    }
    private var lightStart: UnitPoint {
        UnitPoint(x: clamp01(0.5 + gyro.normalizedY * 0.9),
                  y: clamp01(0.5 + gyro.normalizedX * 0.9))
    }
    private var lightEnd: UnitPoint {
        UnitPoint(x: clamp01(0.5 - gyro.normalizedY * 0.9),
                  y: clamp01(0.5 - gyro.normalizedX * 0.9))
    }

    var body: some View {
        ZStack {
            cardBackground   // 카드 배경 + 컨텐츠
            hologramLayer    // 무지개 홀로그램 (빛 닿는 곳만 표시)
            lightLayer       // 흰색 빛 반사
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: corner))
        // ── 3D 틸트 (Reanimated rotateX / rotateY 대응) ──────────────
        .rotation3DEffect(.degrees(gyro.rotateX),
                          axis: (x: 1, y: 0, z: 0),
                          perspective: 0.5)
        .rotation3DEffect(.degrees(gyro.rotateY),
                          axis: (x: 0, y: 1, z: 0),
                          perspective: 0.5)
        // 기울기에 따라 그림자 방향도 변경
        .shadow(color: .black.opacity(0.45),
                radius: 28,
                x: gyro.rotateY * 1.8,
                y: -gyro.rotateX * 1.8)
        .onAppear  { gyro.start() }
        .onDisappear { gyro.stop() }
    }

    // MARK: Card Background ─────────────────────────────────────────────

    private var cardBackground: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
    }

    // MARK: Hologram Layer
    private var hologramLayer: some View {
        ZStack {
            // 기울기에 따라 전체가 은은하게 물드는 무지개
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
            // 전체적으로 부드럽게 페이드
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
        }
        .blendMode(.softLight)  // overlay 대신 softLight로 더 부드럽게
    }

    // MARK: Light Reflection Layer
    private var lightLayer: some View {
        // 선 없이 전체에 은은하게 퍼지는 빛
        RadialGradient(
            colors: [
                .white.opacity(0.12),
                .white.opacity(0.04),
                .clear,
            ],
            center: UnitPoint(
                x: clamp01(0.5 + gyro.normalizedY * 0.5),
                y: clamp01(0.5 + gyro.normalizedX * 0.5)
            ),
            startRadius: 10,
            endRadius: cardWidth
        )
        .blendMode(.softLight)
    }
    // MARK: Helpers ────────────────────────────────────────────────────

    private func clamp01(_ v: Double) -> Double { min(max(v, 0), 1) }
}
