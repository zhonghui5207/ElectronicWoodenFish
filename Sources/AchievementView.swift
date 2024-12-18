import SwiftUI

struct AchievementView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: WoodenFishManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("已解锁成就")) {
                    ForEach(manager.achievementManager.getUnlockedAchievements()) { achievement in
                        AchievementRow(achievement: achievement, isLocked: false)
                    }
                }
                
                Section(header: Text("未解锁成就")) {
                    ForEach(manager.achievementManager.getLockedAchievements()) { achievement in
                        AchievementRow(achievement: achievement, isLocked: true)
                    }
                }
            }
            .navigationTitle("成就")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let isLocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .foregroundColor(isLocked ? .gray : .yellow)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !isLocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .opacity(isLocked ? 0.6 : 1.0)
    }
}

struct AchievementUnlockView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Image(systemName: achievement.icon)
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .padding()
            
            Text("解锁成就")
                .font(.headline)
            
            Text(achievement.title)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(achievement.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    AchievementView()
        .environmentObject(WoodenFishManager())
}
