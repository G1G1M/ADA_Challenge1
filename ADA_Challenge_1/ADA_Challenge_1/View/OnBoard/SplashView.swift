import SwiftUI

struct SplashView: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 1000, height: 1000)
                .foregroundStyle(.white)
            
            Image("Icon")
                .resizable()
                .frame(width: 300, height: 300)
        }
    }
}

#Preview {
    SplashView()
}
