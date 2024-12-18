import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: WoodenFishManager
    @State private var showThemes = false
    @State private var showAchievements = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("音效设置")) {
                    HStack {
                        Text("音量")
                        Spacer()
                        Slider(value: Binding(
                            get: { manager.volume },
                            set: { manager.updateVolume($0) }
                        ), in: 0...1)
                        .frame(width: 150)
                    }
                }
                
                Section(header: Text("视觉效果")) {
                    Toggle("粒子效果", isOn: Binding(
                        get: { manager.showParticles },
                        set: { manager.updateShowParticles($0) }
                    ))
                }
                
                Section {
                    Button(action: { showThemes = true }) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                            Text("主题")
                            Spacer()
                            Text(manager.themeManager.getCurrentTheme().name)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { showAchievements = true }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("成就")
                            Spacer()
                            let unlockedCount = manager.achievementManager.getUnlockedAchievements().count
                            let totalCount = manager.achievementManager.achievements.count
                            Text("\(unlockedCount)/\(totalCount)")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showThemes) {
            ThemeView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementView()
        }
    }
}
