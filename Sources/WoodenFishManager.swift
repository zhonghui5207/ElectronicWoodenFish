import SwiftUI
import AVFoundation
import AudioToolbox

class WoodenFishManager: ObservableObject {
    @Published var merit: Int = 0
    @Published var volume: Double = 0.5
    @Published var showParticles: Bool = true
    @Published var showAchievementUnlock: Bool = false
    @Published var lastUnlockedAchievement: Achievement?
    @Published var currentStreak: Int = 0
    
    @Published var themeManager = ThemeManager()
    let achievementManager = AchievementManager()
    
    // 添加 dailyMerits 的访问权限
    var dailyMerits: [String: Int] {
        get { _dailyMerits }
        set { _dailyMerits = newValue }
    }
    private var _dailyMerits: [String: Int] = [:]
    
    private let defaults = UserDefaults.standard
    private var systemSounds: [String: SystemSoundID] = [:]
    private var lastTapTime: Date?
    private let streakTimeout: TimeInterval = 2.0 // 2秒内算连击
    
    init() {
        setupAudioSession()
        loadData()
        registerSystemSounds()
        NotificationCenter.default.addObserver(self, selector: #selector(achievementUnlocked(_:)), name: NSNotification.Name("AchievementUnlocked"), object: nil)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func registerSystemSounds() {
        // 为每个主题注册不同的系统音效
        let soundMappings = [
            "traditional": (id: SystemSoundID(1104), name: "Tock"),
            "golden": (id: SystemSoundID(1105), name: "Tink"),
            "jade": (id: SystemSoundID(1103), name: "Click"),
            "crystal": (id: SystemSoundID(1106), name: "Bell")
        ]
        
        for (theme, sound) in soundMappings {
            systemSounds[theme] = sound.id
            print("Registered system sound for theme \(theme): \(sound.name)")
        }
    }
    
    private func loadData() {
        merit = defaults.integer(forKey: "merit")
        volume = defaults.double(forKey: "volume")
        showParticles = defaults.bool(forKey: "showParticles")
        
        if let data = defaults.data(forKey: "dailyMerits"),
           let loadedMerits = try? JSONDecoder().decode([String: Int].self, from: data) {
            dailyMerits = loadedMerits
        }
    }
    
    private func saveData() {
        defaults.set(merit, forKey: "merit")
        defaults.set(volume, forKey: "volume")
        defaults.set(showParticles, forKey: "showParticles")
        
        if let data = try? JSONEncoder().encode(dailyMerits) {
            defaults.set(data, forKey: "dailyMerits")
        }
    }
    
    func incrementMerit() {
        let now = Date()
        
        // 检查是否在连击时间内
        if let lastTap = lastTapTime,
           now.timeIntervalSince(lastTap) <= streakTimeout {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
        lastTapTime = now
        
        // 根据连击次数增加功德
        let meritIncrease = min(currentStreak, 10) // 最多10倍
        merit += meritIncrease
        
        updateDailyMerit()
        playSound()
        achievementManager.checkAchievements(totalMerit: merit, dailyMerit: getTodayMerit(), consecutiveDays: achievementManager.consecutiveDays)
        achievementManager.checkStreakAchievements()
        achievementManager.updateConsecutiveDays()
        themeManager.checkAndUnlockThemes(merit: merit)
        saveData()
    }
    
    private func playSound() {
        let currentTheme = themeManager.getCurrentTheme()
        print("Playing sound for theme: \(currentTheme.id)")
        
        if let soundID = systemSounds[currentTheme.id] {
            AudioServicesPlaySystemSound(soundID)
        } else {
            // 如果没有找到对应的音效，使用默认音效
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    private func updateDailyMerit() {
        let today = formatDate(Date())
        dailyMerits[today] = (dailyMerits[today] ?? 0) + 1
        saveData()
    }
    
    func getTodayMerit() -> Int {
        let today = formatDate(Date())
        return dailyMerits[today] ?? 0
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func updateVolume(_ newVolume: Double) {
        volume = newVolume
        saveData()
    }
    
    func updateShowParticles(_ show: Bool) {
        showParticles = show
        saveData()
    }
    
    @objc private func achievementUnlocked(_ notification: Notification) {
        if let achievement = notification.object as? Achievement {
            lastUnlockedAchievement = achievement
            showAchievementUnlock = true
        }
    }
}
