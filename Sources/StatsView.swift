import SwiftUI

struct StatsView: View {
    @EnvironmentObject var manager: WoodenFishManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("功德统计")) {
                    HStack {
                        Text("总功德")
                        Spacer()
                        Text("\(manager.merit)")
                    }
                    
                    HStack {
                        Text("今日功德")
                        Spacer()
                        Text("\(manager.getTodayMerit())")
                    }
                    
                    if manager.currentStreak > 1 {
                        HStack {
                            Text("当前连击")
                            Spacer()
                            Text("\(manager.currentStreak)连击")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("最近七天")) {
                    let dailyMerits = getLastSevenDaysMerits()
                    VStack(spacing: 12) {
                        // 简单的柱状图
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(dailyMerits, id: \.date) { dayStats in
                                VStack {
                                    // 柱子
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.8))
                                        .frame(height: getBarHeight(merit: dayStats.merit, maxMerit: dailyMerits.map { $0.merit }.max() ?? 1))
                                    
                                    // 日期
                                    Text(formatDate(dayStats.date))
                                        .font(.caption)
                                        .rotationEffect(.degrees(-30))
                                }
                            }
                        }
                        .frame(height: 150)
                        .padding(.top)
                        
                        // 详细数据
                        ForEach(dailyMerits, id: \.date) { dayStats in
                            HStack {
                                Text(formatDate(dayStats.date))
                                Spacer()
                                Text("\(dayStats.merit)")
                            }
                            .font(.subheadline)
                        }
                    }
                }
                
                Section(header: Text("成就")) {
                    NavigationLink(destination: AchievementView()) {
                        Text("查看成就")
                    }
                }
                
                Section(header: Text("主题")) {
                    NavigationLink(destination: ThemeView()) {
                        Text("查看主题")
                    }
                }
            }
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
        }
    }
    
    private func getBarHeight(merit: Int, maxMerit: Int) -> CGFloat {
        if maxMerit == 0 { return 0 }
        let minHeight: CGFloat = 20
        let maxHeight: CGFloat = 130
        let ratio = CGFloat(merit) / CGFloat(maxMerit)
        return minHeight + (maxHeight - minHeight) * ratio
    }
    
    private func getLastSevenDaysMerits() -> [(date: String, merit: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let dateString = formatDateToString(date)
            return (date: dateString, merit: manager.dailyMerits[dateString] ?? 0)
        }.reversed()
    }
    
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(WoodenFishManager())
    }
}
