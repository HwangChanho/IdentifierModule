//
//  FileManagerUtil.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/25.
//

import Foundation
import AppKit
import SQLite3

enum UnderRootDir: CaseIterable {
    case root
    case Applications
    case Documents
    case Library
    case Music
    case publica
    case Desktop
    case Downloads
    case Movies
    case pictures
    
    var title: String {
        switch self {
        case .root:
            return "/"
        case .Applications:
            return "/Applications"
        case .Documents:
            return "/Documents"
        case .Library:
            return "/Library"
        case .Music:
            return "/Music"
        case .publica:
            return "/public"
        case .Desktop:
            return "/Desktop"
        case .Downloads:
            return "/Downloads"
        case .Movies:
            return "/Movies"
        case .pictures:
            return "/pictures"
        }
    }
}

class FileManagerUtil: NSObject {
    static let shared = FileManagerUtil()
    private override init() {}
    
    let fileManager = FileManager.default
    let workspace = NSWorkspace.shared
    
    let TCCLoc = "/Library/Application Support/com.apple.TCC/TCC.db"
    let rootLoc = "root"
    
    func getCurrentProjectName() -> String? {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return nil
        }
        
        let components = bundleIdentifier.components(separatedBy: ".")
        if let projectName = components.last {
            return projectName
        }
        
        return nil
    }
    
    func selectRowsForService(service: String) {
        // TCC.db 파일 경로
        let tccDBPath = "\(NSHomeDirectory())/Library/Application Support/com.apple.TCC/TCC.db"
        let escapedPath = tccDBPath.replacingOccurrences(of: " ", with: "\\ ")

        // SQLite3 데이터베이스 핸들 생성
        var db: OpaquePointer?
        
        if sqlite3_open(tccDBPath, &db) == SQLITE_OK {
            // SQL 쿼리문
            let query = "SELECT * FROM access WHERE service = ?;"

            // SQL 스테이먼트 생성
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                // 매개변수 바인딩
                sqlite3_bind_text(statement, 1, (service as NSString).utf8String, -1, nil)
                
                // 결과 조회
                while sqlite3_step(statement) == SQLITE_ROW {
                    // 각 컬럼의 데이터 가져오기
                    print("in")
                    print(sqlite3_column_count(statement))
                    
                    for column in 0..<sqlite3_column_count(statement) {
                        if let columnName = sqlite3_column_name(statement, column) {
                            let columnNameString = String(cString: columnName)
                            if let columnValue = sqlite3_column_text(statement, column) {
                                let columnValueString = String(cString: columnValue)
                                print("\(columnNameString): \(columnValueString)")
                            }
                        }
                    }
                    print("---")
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("SQL 스테이먼트 생성에 실패했습니다. 오류 메시지: \(errorMessage)")
            }

            // 스테이먼트 해제
            sqlite3_finalize(statement)

            // 데이터베이스 연결 종료
            sqlite3_close(db)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("TCC.db 파일 열기에 실패했습니다. 오류 메시지: \(errorMessage)")
        }
    }
    
    func insertIntoTccTable(service: String, client: String, clientType: Int, authValue: Int, authReason: Int, authVersion: Int) -> Bool {
        var db: OpaquePointer?
        
        let dbPath = "\(NSHomeDirectory())/Library/Application Support/com.apple.TCC/TCC.db" // SQLite 데이터베이스 파일 경로
        //        let escapedPath = dbPath.replacingOccurrences(of: " ", with: "\\ ")
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            let insertStatementString = "INSERT into access (service, client, client_type, auth_value, auth_reason, auth_version) VALUES (?, ?, ?, ?, ?, ?)"
            
//            "INSERT INTO access (service, client, client_type, allowed, prompt_count, csreq, policy_id) VALUES (?, ?, ?, ?, ?, ?, ?)"
            
            var insertStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, service, -1, nil)
                sqlite3_bind_text(insertStatement, 2, client, -1, nil)
                sqlite3_bind_int(insertStatement, 3, Int32(clientType))
                sqlite3_bind_int(insertStatement, 4, Int32(authValue))
                sqlite3_bind_int(insertStatement, 5, Int32(authReason))
                sqlite3_bind_int(insertStatement, 6, Int32(authVersion))
//                sqlite3_bind_int(insertStatement, 7, Int32(authVersion))
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("INSERT operation completed successfully.")
                    
                    return true
                } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("Failed to execute INSERT statement. Error: \(errorMessage)")
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error in preparing INSERT statement. Error: \(errorMessage)")
            }
            
            sqlite3_finalize(insertStatement)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Failed to open database. Error: \(errorMessage)")
        }
        
        sqlite3_close(db)
        
        return false
    }
    
    func openDirectory(_ directoryURL: URL) {
        if fileManager.fileExists(atPath: directoryURL.path) {
            workspace.open(directoryURL)
        } else {
            NSApplication.shared.showAlert("Directory not found at the specified path.", completionHandler: nil)
        }
        
        //        let runningApplications = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        //        if let pid = runningApplications.first?.processIdentifier {
        //            print("Process ID (PID): \(pid)")
        //        }
    }
    
    func checkLocTest(withKeyword keyword: String) {
        var path = "/"
        if keyword.contains("/") {
            path = keyword
        }
        
        if searchFilesAndFolders(withKeyword: keyword, path) {
            print(keyword)
        }
    }
    
    func getBundleIdentifier(_ url: URL) -> String? {
        if let bundle = Bundle(path: url.path) {
            if let bundleIdentifier = bundle.bundleIdentifier {
                return bundleIdentifier
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func openApplication(withBundleIdentifier bundleIdentifier: String) {
        let workspace = NSWorkspace.shared
        
        guard let url = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            print("애플리케이션을 찾을 수 없습니다.")
            return
        }
        
        print("1: ", getApplicationPath(bundleIdentifier: bundleIdentifier))
        print("2: ", getExecutablePath(bundleIdentifier: bundleIdentifier))
        
        //        workspace.open(url)
    }
    
    func openFolderAndFile(atPath path: String) {
        if let url = URL(string: path) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func openFile() {
        let openPanel = NSOpenPanel()
        
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.url {
                // 파일 액세스 권한을 얻은 후 처리할 로직을 작성합니다.
                // 선택한 파일에 대한 작업을 수행할 수 있습니다.
                print("Selected file: \(url.path)")
            }
        }
    }
    
    func searchFilesAndFolders(withKeyword keyword: String, _ atPath: String?) -> Bool {
        let fileManager = FileManager.default
        let searchURL = URL(fileURLWithPath: atPath ?? "/")
        
        print(searchURL)
        
        openApplication(withBundleIdentifier: getBundleIdentifier(searchURL)!)
        do {
            // Get the contents of the directory at the given path
            let contents = try fileManager.contentsOfDirectory(at: searchURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // Set up the search predicate with the keyword
            let predicate = NSPredicate(format: "lastPathComponent CONTAINS[c] %@", keyword)
            
            // Filter the contents using the search predicate
            let filteredContents = contents.filter { predicate.evaluate(with: $0.lastPathComponent) }
            
            for itemURL in contents {
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 폴더일 경우
                        print("folder :: ", itemURL.path, itemURL.pathExtension)
                        //                        searchFilesAndFolders(withKeyword: keyword, itemURL.path)
                    } else {
                        // 파일일 경우
                        if predicate.evaluate(with: itemURL.lastPathComponent) {
                            print("file ::", itemURL.path)
                        }
                    }
                    
                    openFolderAndFile(atPath: itemURL.path)
                }
            }
            
        } catch {
            //            print("Error accessing directory: \(error)")
            print(error)
            return false
        }
        
        return false
    }
    
    
    func getApplicationPath(bundleIdentifier: String) -> String? {
        if let appPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return appPath.path
        }
        return nil
    }
    
    func getExecutablePath(bundleIdentifier: String) -> String? {
        if let appPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            
            do {
                let strURL = try String(contentsOf: appPath)
                let appBundle = Bundle(path: strURL)
                let executablePath = appBundle?.executablePath
                
                return executablePath
            } catch {
                print("convert Url to String Error", error)
                
                return nil
            }
        }
        
        return nil
    }
}
