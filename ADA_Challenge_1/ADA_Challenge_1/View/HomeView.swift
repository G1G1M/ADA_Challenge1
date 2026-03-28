import SwiftUI

struct HomeView: View {
    
    // 진행 현황 게이지
    @State private var current = 8.0
    @State private var minValue = 0.0
    @State private var maxValue = 180.0
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text("Ian") // 닉네임
                .font(.system(size: 28, weight: .bold, design: .default))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 13)
                .padding(.bottom, 32)
            
            Image("Stella")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 218, height: 290)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .hologramEffect()
                .padding(.bottom, 13)
            
            Text("카드를 눌러서\n러너들과 친해져봐!") // 카드 사용 설명 문구
                .font(.system(size: 14, weight: .light, design: .default))
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
            
            ZStack {
                
                Rectangle() // 진행도 카드
                    .frame(width: 330, height: 198)
                    .cornerRadius(20)
                
                VStack(spacing: 0) {
                    HStack {
                        Gauge(value: current, in: minValue...maxValue) {} // 러너 수집 현황 게이지
                        // 인원에 따라 게이지 색상 달라지게 하기
                        currentValueLabel: {
                            VStack {
                                Text("전체")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 7, weight: .light, design: .default))
                                    .foregroundStyle(.black)
                                
                                Text("\(Int(current))/\(Int(maxValue))")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .foregroundStyle(.black)
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .scaleEffect(1.8)
                        .frame(width: 113, height: 113)
                        .foregroundStyle(Color.white)
                        .tint(.red)
                        .padding(.trailing, 10)
                        
                        VStack {
                            
                            HStack {
                                ZStack { // 오전 러너 수
                                    Capsule()
                                        .fill(Color(hex: "00D4FF"))
                                        .frame(width: 46, height: 32)
                                    
                                    Text("오전")
                                        .font(Font.system(size: 14, weight: .bold, design: .default))
                                        .foregroundStyle(.black)
                                        .background(Capsule().fill(Color(hex: "00D4FF")))
                                }
                                
                                Text("4/90")
                                    .foregroundStyle(Color.black)
                            }
                            
                            HStack {
                                ZStack { // 오후 러너 수
                                    Capsule()
                                        .fill(Color(hex: "F6FF00"))
                                        .frame(width: 46, height: 32)
                                    
                                    Text("오후")
                                        .font(Font.system(size: 14, weight: .bold, design: .default))
                                        .foregroundStyle(.black)
                                        .background(Capsule().fill(Color(hex: "F6FF00")))
                                }
                                
                                Text("4/90")
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    
                    Text("조금만 더하면 모든 러너들과 친구가 될 수 있어!")
                        .foregroundStyle(.black)
                        .font(Font.system(size: 14, weight: .light, design: .default))
                }
            }
            .foregroundStyle(Color(hex: "F3F3F3"))
        }
        .padding(.horizontal, 30)
        
        Spacer()
    }
}

#Preview {
    TabBarView()
}
