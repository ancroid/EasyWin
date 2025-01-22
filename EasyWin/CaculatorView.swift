import SwiftUI

struct MahjongTile: Identifiable {
    let id = UUID()
    var value: String
    var isSelected: Bool = false
    var cardType: CardType?
}

struct CalculatorView: View {
    @State private var inputTiles: [MahjongTile] = Array(repeating: MahjongTile(value: ""), count: 14)
    @State private var selectedIndex: Int = 0
    @State private var possibleHands: [HandResult] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var lastInputIndex: Int? = nil
    
    // 将牌型分类
    let wanTiles = [CardType.character1, CardType.character2, CardType.character3, CardType.character4, CardType.character5,
                    CardType.character6, CardType.character7, CardType.character8, CardType.character9]
    let tongTiles = [CardType.dot1, CardType.dot2, CardType.dot3, CardType.dot4, CardType.dot5, CardType.dot6,CardType.dot7,CardType.dot8,CardType.dot9]
    let suoTiles = [CardType.bamboo1, CardType.bamboo2, CardType.bamboo3, CardType.bamboo4, CardType.bamboo5, CardType.bamboo6,CardType.bamboo7,CardType.bamboo8,CardType.bamboo9]
    let honorTiles = [CardType.redDragon, CardType.greenDragon, CardType.whiteDragon]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 提示文本
                Text("请选择格子并点击下方麻将牌进行输入")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // 输入展示区域
                inputTilesView
                    .padding(.horizontal)
                
                // 自定义键盘 - 移除水平内边距
                customKeyboardView
                
                // 使用新的结果显示视图
                resultView
            }
        }.navigationTitle("胡牌计算器")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: clearInput) {
                    Text("清空").foregroundStyle(.red)
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
            )
        }
    }
    
    var inputTilesView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                // 第一行 3+3
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        inputTileCell(index)
                    }
                }
                
                HStack(spacing: 2) {
                    ForEach(3..<6, id: \.self) { index in
                        inputTileCell(index)
                    }
                }
            }
            HStack(spacing: 10) {
                // 第二行 3+3+2
                HStack(spacing: 2) {
                    ForEach(6..<9, id: \.self) { index in
                        inputTileCell(index)
                    }
                }
                
                HStack(spacing: 2) {
                    ForEach(9..<12, id: \.self) { index in
                        inputTileCell(index)
                    }
                }
                
                HStack(spacing: 2) {
                    ForEach(12..<14, id: \.self) { index in
                        inputTileCell(index)
                    }
                }
            }
        }
    }
    
    // 抽取单个输入格子的视图
    private func inputTileCell(_ index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(selectedIndex == index ? Color.blue : Color.gray, lineWidth: selectedIndex == index ? 2 : 1)
                .frame(width: 40, height: 50)
            
            if !inputTiles[index].value.isEmpty {
                Text(inputTiles[index].value)
                    .font(.system(size: 30))
                    .scaleEffect(lastInputIndex == index ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: lastInputIndex)
            } else {
                Image(systemName: "plus")
                    .foregroundColor(selectedIndex == index ? .blue : .gray)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.blue, lineWidth: 2)
                .opacity(selectedIndex == index ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        )
        .onTapGesture {
            withAnimation {
                selectedIndex = index
            }
        }
    }
    
    var customKeyboardView: some View {
        VStack(spacing: 8) {
            // 筒子
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(tongTiles, id: \.self) { tile in
                        tileButton(tile)
                    }
                }
                .padding(.horizontal, 0)
            }
            
            // 条子
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(suoTiles, id: \.self) { tile in
                        tileButton(tile)
                    }
                }
                .padding(.horizontal, 0)
            }
            
            // 字牌
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(honorTiles, id: \.self) { tile in
                        tileButton(tile)
                    }
                }
                .padding(.horizontal, 0)
            }
        }
        .padding(.horizontal)
    }
    
    func tileButton(_ tile: CardType) -> some View {
        Button(action: {
            if selectedIndex < inputTiles.count {
                // 检查是否已经使用了4张相同的牌
                let sameCount = inputTiles.filter { $0.value == tile.emoji as String }.count
                if sameCount >= 4 {
                    showAlert = true
                    alertMessage = "同一种牌最多只能使用4张"
                    return
                }
                
                withAnimation {
                    inputTiles[selectedIndex].value = tile.emoji as String
                    inputTiles[selectedIndex].cardType = tile
                    lastInputIndex = selectedIndex
                    selectedIndex = min(selectedIndex + 1, inputTiles.count - 1)
                }
                
                // 重置动画状态
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    lastInputIndex = nil
                }
                
                if inputTiles.filter({ !$0.value.isEmpty }).count == 13 {
                    calculatePossibleHands()
                } else if inputTiles.filter({ !$0.value.isEmpty }).count == 14 {
                    checkCanWin()
                }
            }
        }) {
            Image(tile.description)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 50)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedIndex)
        }
    }
    
    func clearInput() {
        withAnimation {
            inputTiles = Array(repeating: MahjongTile(value: ""), count: 14)
            selectedIndex = 0
            possibleHands = []
        }
    }
    
    func checkCanWin() {
        let cardTypes = inputTiles.compactMap { $0.cardType }
        let calculationCore = CaculationCore()
        
        // 首先检查是否可以胡牌
        if calculationCore.canWin(cardTypes) {
            possibleHands = [HandResult(type: .win, description: "胡！！！")]
            return
        }
        
        // 如果不能胡牌，检查打出哪些牌可以听牌
        let discardResults = calculationCore.getDiscardTingList(cardTypes)
        if discardResults.isEmpty {
            possibleHands = [HandResult(type: .none, description: "相公")]
        } else {
            possibleHands = discardResults.map { result in
                let tingDescription = result.tingList.map { $0.description }.joined(separator: "、")
                return HandResult(
                    type: .discard,
                    description: "打出 \(result.discard.emoji) 可以听 \(tingDescription)"
                )
            }
        }
    }
    
    func calculatePossibleHands() {
        let cardTypes = inputTiles.compactMap { $0.cardType }
        let calculationCore = CaculationCore()
        let tingList = calculationCore.getTingList(cardTypes)
        
        if tingList.isEmpty {
            possibleHands = [HandResult(type: .none, description: "相公")]
        } else {
            let tingDescription = tingList.map { $0.emoji as String }.joined(separator: "、")
            possibleHands = [HandResult(type: .waiting, description: "可以听 \(tingDescription)")]
        }
    }
    
    // 修改结果显示区域的视图
    var resultView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if !possibleHands.isEmpty {
                    Text("计算结果：").font(.headline)
                    
                    ForEach(possibleHands) { result in
                        HStack {
                            // 状态图标
                            Image(systemName: result.type.iconName)
                                .foregroundColor(result.type.color)
                            
                            Text(result.description)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

// 新增辅助类型
struct HandResult: Identifiable {
    let id = UUID()
    let type: HandResultType
    let description: String
}

enum HandResultType {
    case win      // 可以胡牌
    case waiting  // 听牌中
    case discard  // 需要打出某张牌
    case none     // 无法胡牌或听牌
    
    var iconName: String {
        switch self {
        case .win: return "checkmark.circle.fill"
        case .waiting: return "ear.fill"
        case .discard: return "hand.point.up.fill"
        case .none: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .win: return .green
        case .waiting: return .blue
        case .discard: return .orange
        case .none: return .red
        }
    }
}

#Preview {
    CalculatorView()
}
