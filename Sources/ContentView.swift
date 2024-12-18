import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var manager: WoodenFishManager
    @State private var scale: CGFloat = 1.0
    @State private var showMeritIncrease: Bool = false
    @State private var lastTapPosition: CGPoint = .zero
    @State private var showSettings = false
    @State private var showParticles = false
    @State private var particlePosition: CGPoint = .zero
    @State private var showStats = false
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)), Color(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    // 顶部状态栏
                    HStack {
                        Button(action: { showStats = true }) {
                            VStack(alignment: .leading) {
                                Text("总功德: \(manager.merit)")
                                    .font(.headline)
                                Text("今日: \(manager.getTodayMerit())")
                                    .font(.subheadline)
                                if manager.currentStreak > 1 {
                                    Text("\(manager.currentStreak)连击！")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding()
                                .background(Color.black.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // 木鱼
                    WoodenFishView()
                        .scaleEffect(scale)
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    // 点击动画
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                        scale = 0.9
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                            scale = 1.0
                                        }
                                    }
                                    
                                    // 更新功德
                                    manager.incrementMerit()
                                    
                                    // 计算点击位置（木鱼中心）
                                    let centerX = geometry.size.width / 2
                                    let centerY = geometry.size.height / 2
                                    lastTapPosition = CGPoint(x: centerX, y: centerY)
                                    showMeritIncrease = true
                                    
                                    // 显示粒子效果
                                    if manager.showParticles {
                                        particlePosition = lastTapPosition
                                        showParticles = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showParticles = false
                                        }
                                    }
                                }
                        )
                    
                    Spacer()
                }
                
                // 粒子效果
                if showParticles {
                    let currentTheme = manager.themeManager.getCurrentTheme()
                    let colors = currentTheme.particleColors.map { Color(themeName: $0) }
                    ParticleEffect(position: particlePosition, colors: colors)
                }
                
                // 功德增加动画
                if showMeritIncrease {
                    Text("+1")
                        .font(.title)
                        .foregroundColor(.white)
                        .position(lastTapPosition)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showMeritIncrease = false
                            }
                        }
                }
                
                // 成就解锁提示
                if manager.showAchievementUnlock, let achievement = manager.lastUnlockedAchievement {
                    AchievementUnlockView(achievement: achievement, isPresented: $manager.showAchievementUnlock)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
    }
}

struct WoodenFishView: View {
    @EnvironmentObject var manager: WoodenFishManager
    
    var body: some View {
        let currentTheme = manager.themeManager.getCurrentTheme()
        
        ZStack {
            // 木鱼主体
            Circle()
                .fill(Color(themeName: currentTheme.woodenFishColor))
                .frame(width: 120, height: 120)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // 木鱼纹理
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 100, height: 100)
            
            // 木鱼图案
            Image(systemName: "circle.circle.fill")
                .resizable()
                .foregroundColor(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WoodenFishManager())
    }
}
