import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            Tab("HOME", systemImage: "house") {
                HomeView()
            }
            
            Tab("DICT", systemImage: "book") {
                DictionaryView()
            }
        }
        .tint(.black)
    }
}

#Preview {
    TabBarView()
}
