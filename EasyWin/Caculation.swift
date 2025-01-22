//
//  File.swift
//  EasyWin
//
//  Created by chenrui on 2025/1/22.
//

import Foundation

class CaculationCore: NSObject {
    // 检查是否胡牌
    func canWin(_ cards: [CardType]) -> Bool {
        guard cards.count == 14 else { return false }
        let sortedCards = cards.sorted { $0.rawValue < $1.rawValue }
        
        // 检查特殊牌型
        if isSevenPairs(sortedCards) || isThirteenOrphans(sortedCards) || 
           isSmallDragon(sortedCards) || isBigDragon(sortedCards) {
            return true
        }
        
        // 特殊情况：只有两张牌
        if sortedCards.count == 2 {
            return sortedCards[0] == sortedCards[1]
        }
        
        // 遍历所有可能的将牌
        var i = 0
        while i < sortedCards.count {
            let card = sortedCards[i]
            // 找到所有相同的牌
            let sameCards = sortedCards.filter { $0 == card }
            
            // 判断是否能做将牌
            if sameCards.count >= 2 {
                var remainCards = sortedCards
                // 移除两张将牌
                remainCards.remove(at: remainCards.firstIndex(of: card)!)
                remainCards.remove(at: remainCards.firstIndex(of: card)!)
                
                if checkHuPai(remainCards) {
                    return true
                }
                
                // 跳过相同的牌，避免重复计算
                i += sameCards.count
            } else {
                i += 1
            }
        }
        
        return false
    }
    
    private func checkHuPai(_ cards: [CardType]) -> Bool {
        guard !cards.isEmpty else { return true }
        
        let firstCard = cards[0]
        // 找到所有相同的牌
        let sameCards = cards.filter { $0 == firstCard }
        
        // 尝试组成刻子
        if sameCards.count >= 3 {
            var remainCards = cards
            remainCards.remove(at: remainCards.firstIndex(of: firstCard)!)
            remainCards.remove(at: remainCards.firstIndex(of: firstCard)!)
            remainCards.remove(at: remainCards.firstIndex(of: firstCard)!)
            
            return checkHuPai(remainCards)
        }
        
        // 尝试组成顺子
        let suit = firstCard.rawValue / 10
        if suit >= 1 && suit <= 3 {  // 只处理数字牌
            let value1 = firstCard.rawValue
            let value2 = value1 + 1
            let value3 = value1 + 2
            
            if cards.contains(where: { $0.rawValue == value2 }) && 
               cards.contains(where: { $0.rawValue == value3 }) {
                var remainCards = cards
                remainCards.remove(at: remainCards.firstIndex(where: { $0.rawValue == value3 })!)
                remainCards.remove(at: remainCards.firstIndex(where: { $0.rawValue == value2 })!)
                remainCards.remove(at: remainCards.firstIndex(where: { $0.rawValue == value1 })!)
                
                return checkHuPai(remainCards)
            }
        }
        
        return false
    }
    
    // 存储每种牌的数量
    private func countTiles(_ cards: [CardType]) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        for card in cards {
            counts[card.rawValue, default: 0] += 1
        }
        return counts
    }
    
    // 获取听牌列表
    func getTingList(_ cards: [CardType]) -> [CardType] {
        guard cards.count == 13 else { return [] }
        
        var tingList: [CardType] = []
        
        for card in CardType.allCases {
            let cardCount = cards.filter { $0 == card }.count
            if cardCount >= 4 { continue }
            
            var newCards = cards
            newCards.append(card)
            if canWin(newCards) {
                tingList.append(card)
            }
        }
        
        return tingList.sorted { $0.rawValue < $1.rawValue }
    }
    
    // 获取可以打出的牌列表及其对应的听牌
    func getDiscardTingList(_ cards: [CardType]) -> [(discard: CardType, tingList: [CardType])] {
        guard cards.count == 14 else { return [] }
        
        var result: [(CardType, [CardType])] = []
        var processedCards = Set<CardType>()
        
        for i in 0..<cards.count {
            let discardCard = cards[i]
            
            if processedCards.contains(discardCard) {
                continue
            }
            processedCards.insert(discardCard)
            
            var remainCards = cards
            remainCards.remove(at: i)
            let tingList = getTingList(remainCards)
            if !tingList.isEmpty {
                result.append((discardCard, tingList))
            }
        }
        
        return result.sorted { $0.0.rawValue < $1.0.rawValue }
    }
    
    // 判断七对子
    private func isSevenPairs(_ cards: [CardType]) -> Bool {
        guard cards.count == 14 else { return false }
        
        var i = 0
        while i < cards.count - 1 {
            if cards[i].rawValue != cards[i + 1].rawValue {
                return false
            }
            i += 2
        }
        return true
    }
    
    // 判断十三幺
    private func isThirteenOrphans(_ cards: [CardType]) -> Bool {
        guard cards.count == 14 else { return false }
        
        // 十三幺需要的牌
        let requiredTiles: Set<Int> = [1, 9,  // 万子
                                      11, 19,  // 筒子
                                      21, 29,  // 条子
                                      31, 32, 33, 34, 41, 42, 43]  // 字牌
        
        // 统计牌的数量
        var counts: [Int: Int] = [:]
        for card in cards {
            counts[card.rawValue, default: 0] += 1
        }
        
        // 检查是否包含所有幺九牌
        for tile in requiredTiles {
            if counts[tile] ?? 0 == 0 {
                return false
            }
        }
        
        // 检查是否有一个对子（总共14张牌，13种牌型，必须有一个对子）
        let hasPair = counts.values.contains(2)
        
        return hasPair
    }
    
    // 判断小三元：中发白三张牌中，其中两组刻子，一组将牌
    private func isSmallDragon(_ cards: [CardType]) -> Bool {
        // 中发白牌的值
        let dragonTiles = [41, 42, 43] // 中发白
        
        // 统计三元牌的数量
        var dragonCounts: [Int: Int] = [:]
        for card in cards {
            if dragonTiles.contains(card.rawValue) {
                dragonCounts[card.rawValue, default: 0] += 1
            }
        }
        
        // 检查是否有两组刻子和一组将牌
        var hasThreePair = false // 刻子数量
        var hasTwoPair = false // 对子数量
        
        for count in dragonCounts.values {
            if count == 3 {
                hasThreePair = true
            } else if count == 2 {
                hasTwoPair = true
            }
        }
        
        // 小三元需要两组刻子和一组将牌
        let isSmallDragon = dragonCounts.values.reduce(0, +) == 8 && 
                           hasThreePair && hasTwoPair
        
        if isSmallDragon {
            // 检查剩余牌是否能组成合法的面子
            let remainCards = cards.filter { !dragonTiles.contains($0.rawValue) }
            return checkHuPai(remainCards)
        }
        
        return false
    }
    
    // 判断大三元：中发白三张牌都是刻子
    private func isBigDragon(_ cards: [CardType]) -> Bool {
        // 中发白牌的值
        let dragonTiles = [41, 42, 43] // 中发白
        
        // 统计三元牌的数量
        var dragonCounts: [Int: Int] = [:]
        for card in cards {
            if dragonTiles.contains(card.rawValue) {
                dragonCounts[card.rawValue, default: 0] += 1
            }
        }
        
        // 检查是否所有三元牌都是刻子
        let allThreePairs = dragonCounts.values.allSatisfy { $0 >= 3 }
        
        if allThreePairs && dragonCounts.values.reduce(0, +) == 9 {
            // 检查剩余牌是否能组成合法的面子和将牌
            let remainCards = cards.filter { !dragonTiles.contains($0.rawValue) }
            // 剩余5张牌需要包含一个对子和一个顺子/刻子
            return checkRemainCardsForDragon(remainCards)
        }
        
        return false
    }
    
    // 检查大三元剩余牌是否合法
    private func checkRemainCardsForDragon(_ cards: [CardType]) -> Bool {
        guard cards.count == 5 else { return false }
        
        // 尝试每种牌作为将牌
        for i in 0..<cards.count {
            let card = cards[i]
            // 找到所有相同的牌
            let sameCards = cards.filter { $0 == card }
            
            if sameCards.count >= 2 {
                var remainCards = cards
                // 移除两张将牌
                remainCards.remove(at: remainCards.firstIndex(of: card)!)
                remainCards.remove(at: remainCards.firstIndex(of: card)!)
                
                // 检查剩余三张牌是否能组成顺子或刻子
                if checkHuPai(remainCards) {
                    return true
                }
            }
        }
        
        return false
    }
}
