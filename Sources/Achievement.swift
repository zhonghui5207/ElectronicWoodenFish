import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let requirement: Int
    let type: AchievementType
    var isUnlocked: Bool
    let icon: String
    
    enum AchievementType: String, Codable {
        case totalMerit // 总功德成就
        case dailyMerit // 单日功德成就
        case streak    // 连续敲击成就
        case consecutive // 连续打卡成就
    }
}

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var currentStreak: Int = 0
    @Published var maxStreak: Int = 0
    @Published var consecutiveDays: Int = 0
    @Published var lastTapTime: Date?
    private let defaults = UserDefaults.standard
    
    init() {
        loadAchievements()
        loadStats()
    }
    
    private func loadAchievements() {
        // 从UserDefaults加载已解锁的成就
        if let data = defaults.data(forKey: "achievements"),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = savedAchievements
        } else {
            // 初始化默认成就
            achievements = [
                // 总功德成就
                Achievement(id: "total_100", title: "初心", description: "累计功德达到100", requirement: 100, type: .totalMerit, isUnlocked: false, icon: "sparkles"),
                Achievement(id: "total_1000", title: "小有所成", description: "累计功德达到1000", requirement: 1000, type: .totalMerit, isUnlocked: false, icon: "sparkles.rectangle.stack"),
                Achievement(id: "total_10000", title: "功德圆满", description: "累计功德达到10000", requirement: 10000, type: .totalMerit, isUnlocked: false, icon: "sparkles.square.filled.on.square"),
                
                // 单日功德成就
                Achievement(id: "daily_100", title: "一日精进", description: "单日功德达到100", requirement: 100, type: .dailyMerit, isUnlocked: false, icon: "sun.max"),
                Achievement(id: "daily_500", title: "勤修苦练", description: "单日功德达到500", requirement: 500, type: .dailyMerit, isUnlocked: false, icon: "sun.max.circle"),
                
                // 连续敲击成就
                Achievement(id: "streak_10", title: "初窥门径", description: "连续敲击10次", requirement: 10, type: .streak, isUnlocked: false, icon: "flame"),
                Achievement(id: "streak_50", title: "熟能生巧", description: "连续敲击50次", requirement: 50, type: .streak, isUnlocked: false, icon: "flame.circle"),
                Achievement(id: "streak_100", title: "炉火纯青", description: "连续敲击100次", requirement: 100, type: .streak, isUnlocked: false, icon: "flame.fill"),
                
                // 连续打卡成就
                Achievement(id: "consecutive_7", title: "七日禅", description: "连续7天敲击木鱼", requirement: 7, type: .consecutive, isUnlocked: false, icon: "calendar"),
                Achievement(id: "consecutive_30", title: "月精进", description: "连续30天敲击木鱼", requirement: 30, type: .consecutive, isUnlocked: false, icon: "calendar.circle.fill")
            ]
            saveAchievements()
        }
    }
    
    private func loadStats() {
        maxStreak = defaults.integer(forKey: "maxStreak")
        consecutiveDays = defaults.integer(forKey: "consecutiveDays")
    }
    
    private func saveStats() {
        defaults.set(maxStreak, forKey: "maxStreak")
        defaults.set(consecutiveDays, forKey: "consecutiveDays")
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            defaults.set(data, forKey: "achievements")
        }
    }
    
    func checkAchievements(totalMerit: Int, dailyMerit: Int, consecutiveDays: Int) {
        // 检查总功德成就
        achievements.filter { $0.type == .totalMerit && !$0.isUnlocked }
            .forEach { achievement in
                if totalMerit >= achievement.requirement {
                    unlockAchievement(id: achievement.id)
                }
            }
        
        // 检查单日功德成就
        achievements.filter { $0.type == .dailyMerit && !$0.isUnlocked }
            .forEach { achievement in
                if dailyMerit >= achievement.requirement {
                    unlockAchievement(id: achievement.id)
                }
            }
        
        // 检查连续打卡成就
        achievements.filter { $0.type == .consecutive && !$0.isUnlocked }
            .forEach { achievement in
                if consecutiveDays >= achievement.requirement {
                    unlockAchievement(id: achievement.id)
                }
            }
    }
    
    func checkStreakAchievements() {
        // 检查连续敲击成就
        achievements.filter { $0.type == .streak && !$0.isUnlocked }
            .forEach { achievement in
                if currentStreak >= achievement.requirement {
                    unlockAchievement(id: achievement.id)
                }
            }
        
        // 更新最高连击数
        if currentStreak > maxStreak {
            maxStreak = currentStreak
            saveStats()
        }
    }
    
    func updateConsecutiveDays() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastTap = lastTapTime {
            // 如果是同一天，不更新连续天数
            if calendar.isDate(lastTap, inSameDayAs: now) {
                return
            }
            
            // 如果是第二天，增加连续天数
            if calendar.isDate(lastTap, equalTo: calendar.date(byAdding: .day, value: -1, to: now)!, toGranularity: .day) {
                consecutiveDays += 1
                saveStats()
            } else {
                // 如果间隔超过一天，重置连续天数
                consecutiveDays = 1
                saveStats()
            }
        } else {
            // 第一次敲击
            consecutiveDays = 1
            saveStats()
        }
        
        lastTapTime = now
    }
    
    func updateStreak() {
        let now = Date()
        if let last = lastTapTime {
            // 如果距离上次敲击不超过3秒，增加连击
            if now.timeIntervalSince(last) <= 3 {
                currentStreak += 1
                checkStreakAchievements()
            } else {
                // 重置连击
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        lastTapTime = now
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func getLockedAchievements() -> [Achievement] {
        return achievements.filter { !$0.isUnlocked }
    }
    
    private func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].isUnlocked = true
            saveAchievements()
            // 这里可以添加成就解锁的通知
            NotificationCenter.default.post(name: NSNotification.Name("AchievementUnlocked"), object: achievements[index])
        }
    }
}
