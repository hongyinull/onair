//
//  ContentView.swift
//  onair
//
//  Created by HONGYINULL on 2025/3/12.
//

import SwiftUI
import AVFoundation

struct OnAirView: View {
    @State private var isGlowing = true // 控制主要霓虹燈開關
    @State private var softGlow = true // 控制忽亮忽暗的光暈變化
    @State private var isOn = true // 新增控制開關狀態
    @State private var startTime: Date? = Date() //開始onAir時間
    @State private var elapsed : Int = 0
    
    var body: some View {
        ZStack() {
            Color.black.edgesIgnoringSafeArea(.all) // 設定全螢幕黑色背景，提升沉浸感
            
            VStack(spacing: UIScreen.main.bounds.width > UIScreen.main.bounds.height ? -20 : -12){
                Text(isOn ? "ON AIR" : "ON AIR")
                //                 .font(.system(size: UIScreen.main.bounds.width * 3 / 15, weight: .bold, design: .rounded)) // 文字大小根據螢幕寬度自適應
                //                .font(.custom("LEDLIGHT", size: UIScreen.main.bounds.width * 3 / 15)) // 使用自定義像素字體
                //                .font(.custom("10Pixel-Bold", size: UIScreen.main.bounds.width * 3 / 15)) // 使用自定義像素字體
                    .environment(\._lineHeightMultiple, 0.8)
                    .font(.custom("10Pixel-Bold", size: (UIScreen.main.bounds.width > UIScreen.main.bounds.height ?
                                                         UIScreen.main.bounds.width * 3.3 / 15 : UIScreen.main.bounds.height * 3 / 15) ))
                    .multilineTextAlignment(.center) // 確保文字水平置中
                    
                    
                Text({
                    let h = elapsed / 3600, m = (elapsed % 3600) / 60, s = elapsed % 60
                    return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                    : String(format: "%02d:%02d", m, s)
                }())
                .font(.custom("10Pixel-Bold", size: (UIScreen.main.bounds.width > UIScreen.main.bounds.height ?
                                                     UIScreen.main.bounds.width * 1 / 20 : UIScreen.main.bounds.height * 1 / 20) ))
                .transaction { $0.animation = .spring(response: 0.2, dampingFraction: 0.8) } // 🎯 為數字變化加上彈性動畫
//                .contentTransition(.numericText()) // 🎯 內建數字動畫
            }
            .foregroundColor(isGlowing ? .red : Color.red.opacity(0.4)) // 霓虹燈主要顏色與透明度變化
            .shadow(color: isGlowing ? Color.red.opacity(1.0) : Color.red.opacity(0.4), radius: isGlowing ? 50 : 20) // 主要霓虹燈光暈效果
            .shadow(color: softGlow ? Color.red.opacity(0.8) : Color.red.opacity(0.5), radius: softGlow ? 20 : 10) // 額外忽亮忽暗的柔光
            .onAppear {softGlowEffect()}
            .scaleEffect(isOn ? 1.0 : 0.98)
            .animation(.spring(response: 0.8, dampingFraction: 0.65, blendDuration: 0.8), value: isOn) //切換onOff狀態時的彈性過度動畫
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onTapGesture {
                //                    SoundPlayer.playSound("SwitchSound1")
                HapticManager.trigger(.heavy)
                switchOnOff()
            }
            //                .simultaneousGesture(
            //                        DragGesture(minimumDistance: 0)
            //                            .onChanged { _ in SoundManager.playSound("neonSwitchOn")
            //                                HapticManager.trigger(.heavy)} // 按下時觸發
            //                            .onEnded { _ in SoundManager.playSound("neonSwitchOff")
            //                                HapticManager.trigger(.light)} // 鬆開時觸發
            //                    )

                
                
            Image("CRT1")
                    .resizable()
//                    .aspectRatio(contentMode: .fit)
                    .blendMode(.multiply)
                    .opacity(softGlow ? 0.2 : 0.4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false) // 禁用此 Image 的點擊事件
//                    .rotationEffect(Angle(degrees: -[0, 0, -90, 0][UIDevice.current.orientation.rawValue % 4]))
////                    .portrait → 0
////                    .portraitUpsideDown → 1
////                    .landscapeLeft → 2
////                    .landscapeRight → 3

                
            
            GIFImage(name: "CRT3")
                .opacity(softGlow ? 0.2 : 0.1)
                .transition(.opacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                .blur(radius: 5)
                .mask(
                        RadialGradient(gradient: Gradient(colors: [Color.white, Color.clear]),
                                       center: .center,
                                       startRadius: 250,
                                       endRadius: 350)
                    )
                .blendMode(.overlay)
                .allowsHitTesting(false) // 禁用此 GIFImage 的點擊事件
            
            
                
        }
        .onAppear {
            flickerEffect() // 啟動隨機閃爍效
        }
        .statusBar(hidden: true) // 隱藏上方狀態欄（時間、電量）
        .preferredColorScheme(.dark) // 強制使用深色模式，確保黑色背景一致
        .edgesIgnoringSafeArea(.all) // 隱藏底部橫條，提高沈浸感
        .persistentSystemOverlays(.hidden) //擋住底部橫條！！成功！
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//        .prefersHomeIndicatorAutoHidden(true) // 讓 Home Indicator 變暗
    }
    
    func flickerEffect() {
        if isOn{
            print("flickerEffect")
            // 設定每 7 到 20 秒隨機發生一次閃爍
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 7...20), repeats: true) { _ in
                let flickerCount = Int.random(in: 2...5) // 每次閃爍 2 到 5 下
                flicker(times: flickerCount)
            }
            //順便設定每秒更新一次已過去秒數
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if isOn{
                    elapsed = Int((startTime?.timeIntervalSinceNow ?? 0) * -1)//重新字算已過去秒數
                }
            }
        }
    }
    
    func flicker(times: Int) {
        guard times > 0 else { 
            // 當閃爍次數歸零時，確保恢復到亮起的狀態
            withAnimation(.easeOut(duration: 0.3)) {
                if isOn {
                    isGlowing = true
                }
            }
            return 
        }
        if isOn{
            withAnimation(.easeOut(duration: Double.random(in: 0.1...0.1))) {//每次閃爍的動畫播放速度
                isGlowing.toggle()
                print("isGlowing: \(isGlowing)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.01...0.08)) {//每次閃爍的間隔
                flicker(times: times - 1)
            }
        }
    }
    
    func softGlowEffect() {
            // 讓霓虹燈持續忽亮忽暗，每 2 秒變化一次
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 2.0...5.8), repeats: true) { _ in
            withAnimation(.easeInOut(duration: Double.random(in: 0.9...2.0))) {
                    if isOn{
                        softGlow.toggle()
                        print("isOn:\(isOn) softGlow: \(softGlow)")
                    }
                }
            }
    }
    
    // 新增 switchOnOff 函式
    func switchOnOff() {
        isOn.toggle()
        flicker(times: 5)
        
        if isOn {
            // 開啟狀態
            SoundManager.playSound("neonSwitchOff")
            startTimer()//將開始時間記錄為現在
            isGlowing = true
            softGlow = true
            softGlowEffect() // 重新啟動忽明忽暗效果
            flickerEffect() // 重新啟動閃爍效果
            print("ON AIR")
        } else {
            // 關閉狀態
            SoundManager.playSound("neonSwitchOn")
                isGlowing = false
                softGlow = false
                print("OFF AIR")
        }
    }
    
    //將開始時間記錄為現在
    func startTimer() {
        startTime = Date()
    }
    
}


//播放音效函式
struct SoundManager {
    static var players: [String: AVAudioPlayer] = [:] // 🔥 存放多個音效播放器

    static func playSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[name] = player // 🎵 為該音效存入獨立播放器
            player.play()
        } catch {
            print("❌ 無法播放音效：\(name)")
        }
    }
}

//震動反饋函式
struct HapticManager {
    static func trigger(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: type).impactOccurred()
    }
    
    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
//HapticManager.trigger(.light)   // 輕微震動
//HapticManager.trigger(.medium)  // 中等震動
//HapticManager.trigger(.heavy)   // 強烈震動
//HapticManager.notify(.success)  // 成功回饋震動
//HapticManager.notify(.error)    // 失敗回饋震動



//計時器相關

struct ContentView: View {
    var body: some View {
        OnAirView()
    }
}

#Preview {
//    ContentView()
    OnAirView()
}
