//
//  EWCardModel.swift
//  EasyWin
//
//  Created by chenrui on 2024/12/20.
//

import Foundation

enum CardType: Int, CaseIterable, Comparable{
    case character1 = 1, character2, character3, character4, character5, character6, character7, character8, character9
    case dot1 = 11, dot2, dot3, dot4, dot5, dot6, dot7, dot8, dot9
    case bamboo1 = 21, bamboo2, bamboo3, bamboo4, bamboo5, bamboo6, bamboo7, bamboo8, bamboo9
    case eastWind = 31, southWind, westWind, northWind
    case redDragon = 41, greenDragon, whiteDragon
    
    var description: String {
        switch self {
        case .character1: return "一万"
        case .character2: return "二万"
        case .character3: return "三万"
        case .character4: return "四万"
        case .character5: return "五万"
        case .character6: return "六万"
        case .character7: return "七万"
        case .character8: return "八万"
        case .character9: return "九万"
        case .dot1: return "一筒"
        case .dot2: return "二筒"
        case .dot3: return "三筒"
        case .dot4: return "四筒"
        case .dot5: return "五筒"
        case .dot6: return "六筒"
        case .dot7: return "七筒"
        case .dot8: return "八筒"
        case .dot9: return "九筒"
        case .bamboo1: return "一条"
        case .bamboo2: return "二条"
        case .bamboo3: return "三条"
        case .bamboo4: return "四条"
        case .bamboo5: return "五条"
        case .bamboo6: return "六条"
        case .bamboo7: return "七条"
        case .bamboo8: return "八条"
        case .bamboo9: return "九条"
        case .redDragon: return "红中"
        case .greenDragon: return "发财"
        case .whiteDragon: return "白板"
        case .eastWind: return "东风"
        case .southWind: return "南风"
        case .westWind: return "西风"
        case .northWind: return "北风"
        }
    }
    
    var emoji: NSString {
        switch self {
        case .dot1: return "🀙"
        case .dot2: return "🀚"
        case .dot3: return "🀛"
        case .dot4: return "🀜"
        case .dot5: return "🀝"
        case .dot6: return "🀞"
        case .dot7: return "🀟"
        case .dot8: return "🀠"
        case .dot9: return "🀡"
        case .bamboo1: return "🀐"
        case .bamboo2: return "🀑"
        case .bamboo3: return "🀒"
        case .bamboo4: return "🀓"
        case .bamboo5: return "🀔"
        case .bamboo6: return "🀕"
        case .bamboo7: return "🀖"
        case .bamboo8: return "🀗"
        case .bamboo9: return "🀘"
        case .redDragon: return "🀄"
        case .greenDragon: return "🀅"
        case .whiteDragon: return "🀆"
        default: return "🀫"
        }
    }

    // 实现 Comparable 协议
    static func < (lhs: CardType, rhs: CardType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
