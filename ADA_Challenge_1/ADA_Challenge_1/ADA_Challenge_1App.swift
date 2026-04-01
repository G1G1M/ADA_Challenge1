//
//  ADA_Challenge_1App.swift
//  ADA_Challenge_1
//
//  Created by 김지원 on 3/27/26.
//

import SwiftUI

@main
struct ADA_Challenge_1App: App {
    @State var isOnboarded: Bool = UserDefaults.standard.bool(forKey: "isOnboarded") // UserDefaults에서 isOnboarded 꺼내기
    
    var body: some Scene {
        WindowGroup {
            if isOnboarded {
                TabBarView()
                    .preferredColorScheme(.light)
            } else {
                OnboardingView(onComplete: {
                    isOnboarded = true
                })
            }
        }
    }
}
