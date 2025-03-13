//
//  ContentView.swift
//  onair
//
//  Created by HONGYINULL on 2025/3/12.
//

import SwiftUI

struct OnAirView: View {
    @State private var isGlowing = true // 控制主要霓虹燈開關
    @State private var softGlow = true // 控制忽亮忽暗的光暈變化
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // 設定全螢幕黑色背景，提升沉浸感
            
            Text("ON AIR")
                .font(.system(size: UIScreen.main.bounds.width * 3 / 15, weight: .bold, design: .rounded)) // 文字大小根據螢幕寬度自適應
                .multilineTextAlignment(.center) // 確保文字水平置中
                .foregroundColor(isGlowing ? .red : Color.red.opacity(0.2)) // 霓虹燈主要顏色與透明度變化
                .shadow(color: isGlowing ? Color.red.opacity(1.0) : Color.red.opacity(0.4), radius: isGlowing ? 50 : 20) // 主要霓虹燈光暈效果
                .shadow(color: softGlow ? Color.red.opacity(0.8) : Color.red.opacity(0.5), radius: softGlow ? 20 : 10) // 額外忽亮忽暗的柔光
                .onAppear {
                    softGlowEffect() // 啟動持續忽亮忽暗效果
                }
            
                Image("CRT1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blendMode(.multiply)
                        .opacity(0.3)
            
            GIFImage(name: "CRT3")
            
                
        }
        .onAppear {
            flickerEffect() // 啟動隨機閃爍效
        }
        .statusBar(hidden: true) // 隱藏上方狀態欄（時間、電量）
        .preferredColorScheme(.dark) // 強制使用深色模式，確保黑色背景一致
        .edgesIgnoringSafeArea(.all) // 隱藏底部橫條，提高沈浸感
        .persistentSystemOverlays(.hidden) //擋住底部橫條！！成功！
//        .prefersHomeIndicatorAutoHidden(true) // 讓 Home Indicator 變暗
    }
    
    func flickerEffect() {
        // 設定每 5 到 15 秒隨機發生一次閃爍
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 5...10), repeats: true) { _ in
            let flickerCount = Int.random(in: 2...3) // 每次閃爍 1 到 3 下
            flicker(times: flickerCount)
        }
    }
    
    func flicker(times: Int) {
        guard times > 0 else { 
            // 當閃爍次數歸零時，確保恢復到亮起的狀態
            withAnimation(.easeOut(duration: 0.3)) {
                isGlowing = true
            }
            return 
        }
        
        withAnimation(.easeOut(duration: Double.random(in: 0.1...0.1))) {//每次閃爍的動畫播放速度
            isGlowing.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.01...0.08)) {//每次閃爍的間隔
            flicker(times: times - 1)
        }
    }
    
    func softGlowEffect() {
        // 讓霓虹燈持續忽亮忽暗，每 2 秒變化一次
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                softGlow.toggle()
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        OnAirView()
    }
}

#Preview {
//    ContentView()
    OnAirView()
}
