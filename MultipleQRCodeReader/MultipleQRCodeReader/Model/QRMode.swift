//
//  QRMode.swift
//  MultipleQRCodeReader
//
//  Created by 藤治仁 on 2021/09/06.
//

import Foundation

enum QRMode: Int {
    case numeric              = 1 // 0001 数字
    case alphanumeric         = 2 // 0010 英数字
    case byte                 = 4 // 0100 バイト
    case kanji                = 8 // 1000 漢字
    case structuredAppend     = 3 // 0011 構造的連接
    case eci                  = 7 // 0111 ECI
    case fnc1InFirstPosition  = 5 // 0101 FNC1（1番目の位置）
    case fnc1InSecondPosition = 9 // 1001 FNC1（1番目の位置）
    case endOfMessage         = 0 // 0000 終端パターン

    var description: String {
        switch self {
        case .numeric:              return "0001 数字"
        case .alphanumeric:         return "0010 英数字"
        case .byte:                 return "0100 バイト"
        case .kanji:                return "1000 漢字"
        case .structuredAppend:     return "0011 構造的連接"
        case .eci:                  return "0111 ECI"
        case .fnc1InFirstPosition:  return "0101 FNC1（1番目の位置）"
        case .fnc1InSecondPosition: return "1001 FNC1（1番目の位置）"
        case .endOfMessage:         return "0000 終端パターン"
        }
    }

    var hasNumberOfBitsInLengthFiled: Bool {
        switch self {
        case .numeric, .alphanumeric, .byte, .kanji:
            return true
        default:
            return false
        }
    }

    var numberOfBitsPerCharacter: Int? {
        switch self {
        case .numeric: return 10
        case .alphanumeric: return 11
        case .byte: return 8
        case .kanji: return 13
        default: return nil
        }
    }

    func numberOfBitsInLengthFiled(for symbolVersion: Int) -> Int? {
        guard let symbolType = QRSymbolType(version: symbolVersion) else { return nil }
        switch self {
        case .numeric:
            switch symbolType {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }

        case .alphanumeric:
            switch symbolType {
            case .small: return 9
            case .medium: return 11
            case .large: return 13
            }

        case .byte:
            switch symbolType {
            case .small: return 8
            case .medium: return 16
            case .large: return 16
            }

        case .kanji:
            switch symbolType {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            }

        default:
            return nil
        }
    }
}

private enum QRSymbolType {
    case small
    case medium
    case large

    init?(version: Int) {
        if 1 <= version, version <= 9 {
            self = .small
        } else if 10 <= version, version <= 26 {
            self = .medium
        } else if 27 <= version, version <= 40 {
            self = .large
        } else {
            return nil
        }
    }
}
