//
//  MenuView.swift
//  EasyWin
//
//  Created by chenrui on 2025/1/9.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct MenuView: View {
    let items = [
        MenuItem(title: "胡牌计算器", icon: "123.rectangle", color: .blue),
        MenuItem(title: "选座位", icon: "person.3.fill", color: .green),
        MenuItem(title: "摇骰子", icon: "dice", color: .purple),
        MenuItem(title: "神之一手", icon: "sparkles", color: .orange)
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(items) { item in
                            NavigationLink(destination: destinationView(for: item.title)) {
                                MenuItemView(item: item)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("菜单")
        }
    }
    
    @ViewBuilder
    func destinationView(for title: String) -> some View {
        switch title {
        case "胡牌计算器":
            CalculatorView()
        case "选座位":
            Text("选座位功能开发中...")
        case "摇骰子":
            Text("摇骰子功能开发中...")
        default:
            Text("功能开发中...")
        }
    }
}

struct MenuItemView: View {
    let item: MenuItem
    
    var body: some View {
        VStack {
            Image(systemName: item.icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(item.color)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 3)
            
            Text(item.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    MenuView()
}
