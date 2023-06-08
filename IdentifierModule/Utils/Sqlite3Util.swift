//
//  JDFDAUtil.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/06/07.
//

import Foundation
import SQLite3

enum FDAStatus {
    case complete
    case noData
    case none
    case error
}

enum AuthValueStatus: Int {
    case denied = 0
    case unDefined
    case allowed
    case restricted
}

enum KTCServices: String {
    case FDA = "kTCCServiceSystemPolicyAllFiles"
}

// JD(All), PF(PcFilter)

class JDFDAUtil: NSObject {
    static let shared = JDFDAUtil()
    private override init() {}
    
    let TCCLoc = "/Library/Application Support/com.apple.TCC/TCC.db"
    
    /**
     TCC.db 에서 입력 받은 값 기준 조회
     
     - author:  Daniel Hwang
     - date: 2023/06/07
     - parameters: service: 조회할 TCC.db의 서비스명, identifierOrPath: 조회할 TCC.db의 bundle, path명
     - returns: FDAStatus, errMsg
     */
    func selectRowsForService(service: KTCServices, identifierOrPath: String?) -> (FDAStatus, String?, AuthValueStatus?) {
        guard identifierOrPath != nil else {
            return (.error, "조회 대상이 없습니다.", nil)
        }
        
        var db: OpaquePointer?
        
        if sqlite3_open(TCCLoc, &db) == SQLITE_OK {
            let query = "SELECT * FROM access WHERE service='\(service.rawValue)' AND client='\(identifierOrPath!)';"

            print("query :: ", query)
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (service.rawValue as NSString).utf8String, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    for column in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, column) {
                            let columnNameString = String(cString: columnName)
                            
                            if let columnValue = sqlite3_column_text(statement, column) {
                                let columnValueString = String(cString: columnValue)
                                
                                print("\(columnNameString): \(columnValueString)")
                                
                                if columnNameString == "auth_value" {
                                    sqlite3_finalize(statement)
                                    sqlite3_close(db)
                                    
                                    return (.complete, "done", AuthValueStatus(rawValue: Int(columnValueString)!))
                                }
                            }
                        }
                    }
                }
                
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                return (.error, "SQL 스테이먼트 생성에 실패했습니다. 오류 메시지: \(errorMessage)", nil)
            }

            sqlite3_finalize(statement)
            sqlite3_close(db)
            
            return (.noData, nil, nil)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            return (.error, "TCC.db 파일 열기에 실패했습니다. 오류 메시지: \(errorMessage)", nil)
        }
    }
    
    func selectRowsForServiceAll(service: KTCServices, identifierOrPath: String?) -> (FDAStatus, String?, AuthValueStatus?) {
        guard identifierOrPath != nil else {
            return (.error, "조회 대상이 없습니다.", nil)
        }
        
        var db: OpaquePointer?
        
        if sqlite3_open(TCCLoc, &db) == SQLITE_OK {
            let query = "SELECT * FROM access WHERE service='\(service.rawValue)' AND client='\(identifierOrPath!)';"

            print("query :: ", query)
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (service.rawValue as NSString).utf8String, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    for column in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, column) {
                            let columnNameString = String(cString: columnName)
                            
                            if let columnValue = sqlite3_column_text(statement, column) {
                                let columnValueString = String(cString: columnValue)
                                
                                print("\(columnNameString): \(columnValueString)")
                            }
                        }
                    }
                }
                
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                return (.error, "SQL 스테이먼트 생성에 실패했습니다. 오류 메시지: \(errorMessage)", nil)
            }

            sqlite3_finalize(statement)
            sqlite3_close(db)
            
            return (.noData, nil, nil)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            return (.error, "TCC.db 파일 열기에 실패했습니다. 오류 메시지: \(errorMessage)", nil)
        }
    }
}
