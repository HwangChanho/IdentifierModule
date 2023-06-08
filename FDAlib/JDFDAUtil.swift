//
//  FDAStatus.swift
//  dylibTest
//
//  Created by jiran_daniel on 2023/06/07.
//

import AppKit
import SQLite3

@objc enum FDAStatus: Int {
    case complete = 0
    case noData
    case none
    case error
}

@objc enum AuthValueStatus: Int {
    case denied = 0 // 액세스가 거부
    case unDefined  // 알 수 없음
    case allowed    // 허용
    case restricted // 제한
    case error
    case DBError
    case noData
}

// JD(All), PF(PcFilter)
@objcMembers
class JDFDAUtil: NSObject {
    static let shared = JDFDAUtil()
    private override init() {}
    
    let TCCLoc = "/Library/Application Support/com.apple.TCC/TCC.db"
    let FDA = "kTCCServiceSystemPolicyAllFiles"
    
    /**
     TCC.db 에서 입력 받은 값 기준 조회
     
     - author:  Daniel Hwang
     - date: 2023/06/07
     - parameters: service: 조회할 TCC.db의 서비스명, identifierOrPath: 조회할 TCC.db의 bundle, path명
     - returns: FDAStatus, errMsg
     */
    // (FDAStatus, String?, AuthValueStatus?)
    func selectRowsForService(service: String, identifierOrPath: String?) -> AuthValueStatus {
        guard identifierOrPath != nil else {
            return (.error)
        }
        
        var db: OpaquePointer?
        
        if sqlite3_open(TCCLoc, &db) == SQLITE_OK {
            let query = "SELECT * FROM access WHERE service='\(service)' AND client='\(identifierOrPath!)';"
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (service as NSString).utf8String, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    for column in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, column) {
                            let columnNameString = String(cString: columnName)
                            
                            if let columnValue = sqlite3_column_text(statement, column) {
                                let columnValueString = String(cString: columnValue)
                                
                                if columnNameString == "auth_value" {
                                    sqlite3_finalize(statement)
                                    sqlite3_close(db)
                                    
                                    return (AuthValueStatus(rawValue: Int(columnValueString)!)!)
                                }
                            }
                        }
                    }
                }
                
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                return (.DBError)
            }
            
            sqlite3_finalize(statement)
            sqlite3_close(db)
            
            return (.noData)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            return (.DBError)
        }
    }
    
    /**
     권한상태 확인
     
     - author:  Daniel Hwang
     - date: 23/06/07
     - parameters: service: 조회할 TCC.db의 서비스명, identifierOrPath: 조회할 TCC.db의 bundle, path명
     - returns: not defined
     */
    func checkStatus(service: String, identifierOrPath: String?) {
        let status = selectRowsForService(service: service, identifierOrPath: identifierOrPath)
        
        switch status {
        case .allowed:
            print("allowed")
        case .denied:
            showAlert("시스템 접근권한 동의가 필요합니다.", isHandle: true)
                
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?" + "Privacy_AllFiles")!
            NSWorkspace.shared.open(url)
        case .restricted:
            print("restricted")
        case .unDefined:
            print("unDefined")
        default:
            print("none")
        }
        
        
    }
    
    /**
     Alert 창 표시
     
     - author:  Daniel Hwang
     - date: 23/06/07
     - parameters: text: 노출할 텍스트, style: Alert Style, isHandle: 핸들여부, completionHandler: 컴플리션핸들러
     - returns: not defined
     */
    func showAlert(_ text: String, isHandle: Bool = false) {
        let alert = NSAlert()
        alert.messageText = text
        alert.addButton(withTitle: "confirm")
        alert.alertStyle = .informational
        
        let window = alert.window
        let screenFrame = NSScreen.main?.visibleFrame ?? NSZeroRect
        let alertFrame = window.frame
        let centerX = NSMidX(screenFrame) - (alertFrame.size.width / 2)
        let centerY = NSMidY(screenFrame) - (alertFrame.size.height / 2)
        
        window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        
//        if isHandle {
//            alert.beginSheetModal(for: NSApplication.shared.windows.first!, completionHandler: completionHandler)
//        }
        
        alert.runModal()
    }
}
