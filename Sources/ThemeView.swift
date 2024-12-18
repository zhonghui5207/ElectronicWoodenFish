import SwiftUI

struct ThemeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: WoodenFishManager
    @State private var selectedThemeId: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("已解锁主题")) {
                    ForEach(manager.themeManager.themes.filter(\.unlocked)) { theme in
                        ThemeRow(
                            theme: theme,
                            isSelected: theme.id == (selectedThemeId.isEmpty ? manager.themeManager.currentThemeId : selectedThemeId),
                            isLocked: false,
                            onSelect: {
                                selectedThemeId = theme.id
                                manager.themeManager.setCurrentTheme(id: theme.id)
                            }
                        )
                    }
                }
                
                Section(header: Text("未解锁主题")) {
                    ForEach(manager.themeManager.themes.filter { !$0.unlocked }) { theme in
                        ThemeRow(
                            theme: theme,
                            isSelected: false,
                            isLocked: true
                        )
                    }
                }
            }
            .navigationTitle("主题")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("重置") {
                        manager.themeManager.resetThemes()
                        selectedThemeId = manager.themeManager.currentThemeId
                    }
                }
            }
            .onAppear {
                selectedThemeId = manager.themeManager.currentThemeId
            }
        }
    }
}

struct ThemeRow: View {
    let theme: Theme
    var isSelected: Bool = false
    var isLocked: Bool = false
    var onSelect: (() -> Void)? = nil
    
    var themeIcon: String {
        switch theme.id {
        case "traditional":
            return "circle.fill"
        case "golden":
            return "circle.circle.fill"
        case "jade":
            return "seal.fill"
        case "crystal":
            return "sparkle"
        default:
            return "circle.fill"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: themeIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color(themeName: theme.woodenFishColor))
                .opacity(isLocked ? 0.5 : 1.0)
            
            VStack(alignment: .leading) {
                Text(theme.name)
                    .font(.headline)
                Text(theme.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if isLocked {
                    Text(theme.requirement)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isLocked {
                onSelect?()
            }
        }
    }
}

struct ThemeUnlockView: View {
    let theme: Theme
    let manager: WoodenFishManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color(themeName: theme.woodenFishColor))
                .frame(width: 80, height: 80)
                .padding()
            
            Text("解锁新主题！")
                .font(.title2)
                .bold()
            
            Text(theme.name)
                .font(.title3)
                .padding(.vertical, 4)
            
            Text(theme.description)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("立即使用") {
                manager.themeManager.setCurrentTheme(id: theme.id)
                isPresented = false
            }
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding()
    }
}
