//
//  String.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/23.
//

import Foundation

extension String {
    var isKR: Bool {
        let koreanRegex = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", koreanRegex)
        return predicate.evaluate(with: self)
    }
}
