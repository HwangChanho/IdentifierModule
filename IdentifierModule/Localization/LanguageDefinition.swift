//
//  LanguageState.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/23.
//

import Foundation

enum Language: Equatable {
    case english
    case korean
}

extension Language {
    var code: String {
        switch self {
        case .english: return "en"
        case .korean:  return "ko"
        }
    }
    
    var name: String {
        switch self {
        case .english:
            return "english"
        case .korean:
            return "korean"
        }
    }
}
