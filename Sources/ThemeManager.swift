import SwiftUI

struct Theme: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let woodenFishColor: String
    let particleColors: [String]
    let soundID: String
    let requirementCount: Int
    var unlocked: Bool
    
    var requirement: String {
        if requirementCount == 0 {
            return "默认解锁"
        }
        return "敲击\(requirementCount)次解锁"
    }
}

extension Color {
    init(themeName: String) {
        switch themeName.lowercased() {
        case "brown":
            self = .brown
        case "orange":
            self = .orange
        case "yellow":
            self = .yellow
        case "green":
            self = .green
        case "mint":
            self = .mint
        case "cyan":
            self = .cyan
        case "blue":
            self = .blue
        default:
            self = .primary
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var themes: [Theme]
    @Published var currentThemeId: String
    private let defaults = UserDefaults.standard
    
    init() {
        // 加载默认主题
        let defaultThemes = [
            Theme(
                id: "traditional",
                name: "传统木鱼",
                description: "最基础的木鱼，朴实无华",
                woodenFishColor: "brown",
                particleColors: ["yellow", "orange"],
                soundID: "woodenfish",
                requirementCount: 0,
                unlocked: true
            ),
            Theme(
                id: "golden",
                name: "黄金木鱼",
                description: "金光闪闪的木鱼，富贵非凡",
                woodenFishColor: "orange",
                particleColors: ["yellow", "orange"],
                soundID: "woodenfish-gold",
                requirementCount: 10,
                unlocked: true
            ),
            Theme(
                id: "jade",
                name: "翡翠木鱼",
                description: "碧玉般的木鱼，晶莹剔透",
                woodenFishColor: "green",
                particleColors: ["mint", "green"],
                soundID: "woodenfish-jade",
                requirementCount: 20,
                unlocked: true
            ),
            Theme(
                id: "crystal",
                name: "水晶木鱼",
                description: "透明的水晶木鱼，清澈见底",
                woodenFishColor: "cyan",
                particleColors: ["cyan", "blue"],
                soundID: "woodenfish-crystal",
                requirementCount: 30,
                unlocked: true
            )
        ]
        
        // 从 UserDefaults 加载已保存的主题状态
        if let data = defaults.data(forKey: "themes"),
           let savedThemes = try? JSONDecoder().decode([Theme].self, from: data) {
            themes = savedThemes
        } else {
            themes = defaultThemes
        }
        
        // 加载当前主题
        currentThemeId = defaults.string(forKey: "currentThemeId") ?? "traditional"
    }
    
    func getCurrentTheme() -> Theme {
        if let theme = themes.first(where: { $0.id == currentThemeId }) {
            return theme
        }
        return themes[0]  // 返回默认主题
    }
    
    func setCurrentTheme(id: String) {
        currentThemeId = id
        defaults.set(id, forKey: "currentThemeId")
    }
    
    func checkAndUnlockThemes(merit: Int) {
        var themeChanged = false
        for i in 0..<themes.count {
            if !themes[i].unlocked && merit >= themes[i].requirementCount {
                themes[i].unlocked = true
                themeChanged = true
                
                // 发送成就解锁通知
                let achievement = Achievement(
                    id: "theme_\(themes[i].id)",
                    title: "解锁\(themes[i].name)",
                    description: "解锁了\(themes[i].name)主题",
                    requirement: themes[i].requirementCount,
                    type: .totalMerit,
                    isUnlocked: true,
                    icon: "paintbrush.fill"
                )
                NotificationCenter.default.post(
                    name: NSNotification.Name("AchievementUnlocked"),
                    object: achievement
                )
            }
        }
        
        if themeChanged {
            saveThemes()
        }
    }
    
    private func saveThemes() {
        if let data = try? JSONEncoder().encode(themes) {
            defaults.set(data, forKey: "themes")
        }
    }
    
    func resetThemes() {
        defaults.removeObject(forKey: "themes")
        themes = [
            Theme(
                id: "traditional",
                name: "传统木鱼",
                description: "最基础的木鱼，朴实无华",
                woodenFishColor: "brown",
                particleColors: ["yellow", "orange"],
                soundID: "woodenfish",
                requirementCount: 0,
                unlocked: true
            ),
            Theme(
                id: "golden",
                name: "黄金木鱼",
                description: "金光闪闪的木鱼，富贵非凡",
                woodenFishColor: "orange",
                particleColors: ["yellow", "orange"],
                soundID: "woodenfish-gold",
                requirementCount: 10,
                unlocked: true
            ),
            Theme(
                id: "jade",
                name: "翡翠木鱼",
                description: "碧玉般的木鱼，晶莹剔透",
                woodenFishColor: "green",
                particleColors: ["mint", "green"],
                soundID: "woodenfish-jade",
                requirementCount: 20,
                unlocked: true
            ),
            Theme(
                id: "crystal",
                name: "水晶木鱼",
                description: "透明的水晶木鱼，清澈见底",
                woodenFishColor: "cyan",
                particleColors: ["cyan", "blue"],
                soundID: "woodenfish-crystal",
                requirementCount: 30,
                unlocked: true
            )
        ]
        saveThemes()
    }
}
