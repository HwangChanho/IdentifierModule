//
//  FDAStatus.swift
//  dylibTest
//
//  Created by jiran_daniel on 2023/06/07.
//
import AppKit
import SQLite3

@objc enum FDAAuthValueStatus: Int {
    case denied = 0 // 액세스가 거부 (실제 꺼져있을떄 응답값)
    case unDefined  // 알 수 없음
    case allowed    // 허용
    case restricted // 제한
    
    case error = 97
    case DBError
    case noData
}

@objcMembers class JDFDAUtil: NSObject {
    static let shared = JDFDAUtil()
    private override init() {}
    
    private let TCCLoc = "/Library/Application Support/com.apple.TCC/TCC.db"
    private let FDA = "kTCCServiceSystemPolicyAllFiles"
    private let settingURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?" + "Privacy_AllFiles")!
    private let FDAType = "auth_value"
    
    private let AccessAlertMessage = "시스템 접근권한 동의가 필요합니다."
    private let noDataAlertMessage = "조회된 데이터가 없습니다."
    private let wrongClientAlertMessage = "검색 값을 입력해 주세요."
    private let DBErrorAlertMessage = "DB관련 오류입니다. 오류 내용을 확인해 주세요."
    
    /**
     권한상태 확인
     
     - author:  Daniel Hwang
     - date: 23/06/07
     - parameters: service: 조회할 TCC.db의 서비스명, identifierOrPath: 조회할 TCC.db의 bundle, path명
     */
    func checkFDAStatusOfApp(from bundleID: String) {
        var errMsg: String = ""
        let status = selectFDAAuthValueFromService(bundleID: bundleID, errorMessage: &errMsg)
        
        print(status.rawValue)
        
        switch status {
        case .denied:
            showAlert(AccessAlertMessage) { response in
                if response == .OK {
                    NSWorkspace.shared.open(self.settingURL)
                }
            }
        case .DBError:
            showAlert(DBErrorAlertMessage)
        case .error:
            showAlert(wrongClientAlertMessage)
        case .noData:
            showAlert(noDataAlertMessage)
        default:
            print("status ::", status) // FDA 상태값
        }
        
        return
    }
}

// MARK: - Private Method
extension JDFDAUtil {
    /**
     TCC.db 에서 값 조회
     - discussion: Sqlite3
     - author:  Daniel Hwang
     - date: 2023/06/07
     - parameters: service: 조회할 TCC.db의 서비스명, identifierOrPath: 조회할 TCC.db의 bundle, path명
     - returns: AuthValueStatus, errorMessage
     */
    private func selectFDAAuthValueFromService(bundleID: String, errorMessage: inout String) -> FDAAuthValueStatus {
        var autValue = ""
        
        do {
            try SQLiteBuilder(path: TCCLoc)
                .prepare(with: "SELECT * FROM access WHERE service = '\(FDA)' AND client = '\(bundleID)';")
                .execute(rowHandler: { statement, msg in
                    guard let statement = statement else { return }
                    
                    for column in 0..<sqlite3_column_count(statement) {
                        guard let columnName = sqlite3_column_name(statement, column) else { return }
                        guard let columnValue = sqlite3_column_text(statement, column) else { return }
                        
                        if String(cString: columnName) == "auth_value" {
                            autValue = String(cString: columnValue)
                        }
                    }
                })
                .closeDB()
        } catch {
            return .DBError
        }
        
        guard let StringtoInt = Int(autValue) else { return .error }
        return FDAAuthValueStatus(rawValue: StringtoInt)!
    }
    
    /**
     Close DB
     
     - author:  Daniel Hwang
     - date: 23/06/12
     - parameters: DB, Statement
     */
    private func close(_ DB: OpaquePointer?, And Statement: OpaquePointer?) {
        sqlite3_finalize(Statement)
        sqlite3_close(DB)
    }
    
    /**
     Alert 창 표시
     
     - author:  Daniel Hwang
     - date: 23/06/07
     - parameters: message: 노출할 텍스트,  completionHandler: {}
     - returns: not defined
     */
    private func showAlert(_ message: String, completionHandler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = ""
        alert.addButton(withTitle: "confirm")
        alert.alertStyle = .warning
        
        let window = alert.window
        let screenFrame = NSScreen.main?.visibleFrame ?? NSZeroRect
        let alertFrame = window.frame
        let centerX = NSMidX(screenFrame) - (alertFrame.size.width / 2)
        let centerY = NSMidY(screenFrame) - (alertFrame.size.height / 2)
        
        window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        
        let modalResponse = alert.runModal()
        
        if modalResponse == .alertFirstButtonReturn {
            completionHandler!(.OK)
        }
    }
}
