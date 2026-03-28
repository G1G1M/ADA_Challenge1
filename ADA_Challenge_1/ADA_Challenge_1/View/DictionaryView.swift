import SwiftUI

struct DictionaryView: View {
    
    @State var isSelectedCard: Bool = false
    @State var selectedRunner: Runner? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 5)
    let runners = mockRunners
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    Text("Dict")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .fontWeight(.bold)
                        .padding(.top, 13)
                        .padding(.bottom, 32)
                        .padding(.leading, 30)
                        .padding(.trailing, 14)
                    
                    Text("8/180")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 13)
                        .padding(.bottom, 32)
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(runners) { runner in
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(3/4, contentMode: .fit)
                                
                                if let imageName = runner.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(3/4, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                } else {
                                    Image(systemName: "apple.logo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.bottom, 7)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedRunner = runner
                                    isSelectedCard = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // 카드 선택됐을 때
            if isSelectedCard {
                // 배경 blur
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                // 카드뷰
                if let runner = selectedRunner {
                    Color.black.opacity(isSelectedCard ? 0.5 : 0)
                        .ignoresSafeArea()
                    
                    CardView(runner: runner, onClose: {
                        selectedRunner = nil
                        isSelectedCard = false
                    })
                }
            }
        }
        .toolbar(isSelectedCard ? .hidden : .visible, for: .tabBar) // 모달 화면에서 tabBar 안보이게
    }
}

#Preview {
    DictionaryView()
}
