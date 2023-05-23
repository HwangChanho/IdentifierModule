//
//  LocaleManager.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/23.
//

import Cocoa


class LocalizationManager {
    static let shared = LocalizationManager()
    
    private var currentLanguage: String
    
    private init() {
        // 초기 언어 설정을 UserDefaults에서 가져옵니다.
        self.currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    }
    
    func setLanguage(_ languageCode: String) {
        guard Bundle.main.localizations.contains(languageCode) else {
            return // 해당 언어가 지원되지 않을 경우 종료
        }
        
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        
        // 화면을 업데이트하는 메서드를 호출합니다.
        updateUI()
    }
    
    func localizedString(_ key: String) -> String {
        // 현재 선택된 언어에 맞는 번들을 로드합니다.
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        
        return NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "")
    }
    
    private func updateUI() {
        // 화면을 업데이트하는 로직을 구현합니다.
        // 예: ViewController에서 라벨의 텍스트를 업데이트하는 경우
        NotificationCenter.default.post(name: NSNotification.Name("LanguageDidChangeNotification"), object: nil)
    }
}
