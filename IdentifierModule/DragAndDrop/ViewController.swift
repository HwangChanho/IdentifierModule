//
//  ViewController.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/22.
//

import Cocoa
import SnapKit
import SystemExtensions
import ApplicationServices
import SQLite3

struct FILE_ITEM {
    var strProcessCWD: [String]
    var strFilePath: [String]
    var stStat: stat
    var bIsUsed: Bool
}

class ViewController: NSViewController {
    let mainView = MainView()
    
    let localizationManager = LocalizationManager.shared
    let fileManager = FileManagerUtil.shared
//    let testManager = JDFDAUtil.shared
    
    typealias OPEN_FILE_MAP = [pid_t: FILE_ITEM_MAP]
    typealias FILE_ITEM_MAP = [String: [FILE_ITEM]]
    
    var m_mapOpenFile = OPEN_FILE_MAP()
    
    override func loadView() {
        super.loadView()
        
        self.view = mainView
        mainView.languageComboBox.selectItem(at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setButton()
        
        testMakeSQLite()
    }
    
    func testMakeSQLite2() {
        do {
            try SQLiteBuilder(path: "/Library/Application Support/com.apple.TCC/TCC.db")
                .prepare(with: "SELECT * FROM access")
                .execute(rowHandler: { statement, msg in
                    guard let statement = statement else {
                        print("Error:", msg ?? "")
                        return
                    }
                    
                    print("access Count: ", sqlite3_column_count(statement))
                    
                    for column in 0..<sqlite3_column_count(statement) {
                        guard let columnName = sqlite3_column_name(statement, column) else {
                            return
                        }
                        
                        guard let columnValue = sqlite3_column_text(statement, column) else {
                            return
                        }
                        
                        print(String(cString: columnName) + " : " + String(cString: columnValue))
                    }
                })
                .closeDB()

        } catch {
            print(#function, error)
        }
    }
    
    func testMakeSQLite() {
        let dbLoc = "/Library/Application Support/com.apple.TCC/TCC.db"
        let service = "kTCCServiceSystemPolicyAllFiles"
        let client = "com.jiran.pcfilter.esextension"
        
        do {
            /*
            try SQLiteBuilder(path: dbLoc)
                .setDMLtype(type: .select)
                .setLookUpData(columnNameString: "auth_value")
                .setSelectTable(tableNameString: "access")
                .setSubQuery(where: "service = ? AND client = ?")
                .checkQuery(queryHandler: { query in
                    print(query)
                })
                
            try SQLiteBuilder(path: dbLoc)
                .setDMLtype(type: .delete)
                .setDeleteTable(tableNameString: "access")
                .setSubQuery(where: "service = ? AND client = ?")
                .checkQuery(queryHandler: { query in
                    print(query)
                })
            
            try SQLiteBuilder(path: dbLoc)
                .setDMLtype(type: .insert)
                .setInsertTable(tableNameString: "access (c1, c2)")
                .setSubQuery(where: "?, ?")
                .checkQuery(queryHandler: { query in
                    print(query)
                })
            
            try SQLiteBuilder(path: dbLoc)
                .setDMLtype(type: .update)
                .setUpdateTable(tableNameString: "access", setValues: "column1 = ?")
                .setSubQuery(where: "service = ? AND client = ?")
                .checkQuery(queryHandler: { query in
                    print(query)
                })
             */
            
            try SQLiteBuilder(path: dbLoc)
                .setDMLtype(type: .select)
                .setLookUpData(columnNameString: "auth_value")
                .setSelectTable(tableNameString: "access")
                .setSubQuery(where: "service = ? AND client = ?")
                .prepare()
                .bind(data: service, withType: .text, at: 1)
                .bind(data: client, withType: .text, at: 2)
                .execute(rowHandler: { statement, msg in
                    print("Service: \(service)")
                    print("Client: \(client)")

                    guard let statement else {
                        print("Error:", msg ?? "")
                        return
                    }

                    self.printSqliteStatementValue(statement)
                })
                .closeDB()
            
            
            /*
            try SQLiteBuilder(path: dbLoc)
                .setDMLtype(type: .select)
                .setLookUpData(columnNameString: "auth_value")
                .setSelectTable(tableNameString: "access")
                .setSubQuery(where: "service = ? AND client = ?")
                .prepare()
                .bind(data: service, withType: .text, at: 1)
                .bind(data: client, withType: .text, at: 2)
                .execute(nil)
                .closeDB()
            */
        } catch {
            print(#function, error)
        }
    }
    
    func printSqliteStatementValue(_ statement: OpaquePointer?) {
        if let expandedSQL = sqlite3_expanded_sql(statement) {
            let queryStatus = String(cString: expandedSQL)
            print("Query status: \(queryStatus)")
        }

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
    
    private func setButton() {
        mainView.testButton.target = self
        mainView.testButton.action = #selector(buttonPressed)
    }
    
    @objc func buttonPressed(sender: NSButton!) {
        print(#function)
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?" + "Privacy_AllFiles")!
        
        NSWorkspace.shared.open(url)
    }
    
    private func makeNewWindow() {
        let popupWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                                   styleMask: .titled,
                                   backing: .buffered,
                                   defer: false)
        
        popupWindow.titleVisibility = .visible
        popupWindow.title = "시스템 접근권한 동의가 필요합니다."
        popupWindow.makeKeyAndOrderFront(nil)
    }
    
    private func setDelegate() {
        mainView.dragView.delegate = self
        mainView.languageComboBox.delegate = self
        mainView.searchTextField.delegate = self
    }
    
    func checkfullDiskAccess() -> Bool {
        if let homePath = NSHomeDirectoryForUser("/") {
            print("home :: ", homePath)
            let path = URL(fileURLWithPath: homePath, isDirectory: true)
                .appendingPathComponent("Library/Application Support/com.apple.TCC", isDirectory: true)
                .appendingPathComponent("TCC.db", isDirectory: false)
            
            print(path)
            
            if FileManager.default.contents(atPath: path.path) == nil {
                return false
            }
        }
        
        return false
    }
    
    func checkFullDiskAccessPermission() -> Bool {
        let options: [CFString: Any] = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as CFString: true]
        let optionsDict = options as CFDictionary
        let status = AXIsProcessTrustedWithOptions(optionsDict)
        return status
    }
    
    func registerSystemExtensionIfNeeded() {
        let bundleIdentifier = "com.IdentifierModule"
        
        // Check if the system extension is already registered
        let manager = OSSystemExtensionManager.shared
        
        // Create a request to register the system extension
        let request = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: bundleIdentifier, queue: .main)
        
        // Submit the registration request
        manager.submitRequest(request)
    }
}

// MARK: - NSComboBoxDelegate
extension ViewController: NSComboBoxDelegate, NSTextFieldDelegate {
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let comboBox = notification.object as? NSComboBox {
            guard let _ = comboBox.objectValueOfSelectedItem else { return }
            
            localizationManager.setLanguage(mainView.languages[comboBox.indexOfSelectedItem].code)
            
            let test = LocalizationManager.shared.localizedString("DragFileInfo")
            
            mainView.infoLabel.stringValue = test
            // UI 다시 리로딩 하는 부분
            //            mainView.setNeedsDisplay(mainView.bounds)
            //
            //            DispatchQueue.main.async {
            //                RunLoop.current.run(mode: .default, before: Date.distantFuture)
            //            }
            //
        }
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if fieldEditor.string.isKR {
            NSApplication.shared.showAlert("한글은 검색이 불가합니다.", completionHandler: nil)
            return false
        }
        
        guard let url = URL(string: fieldEditor.string) else { return false }
        
        getDetail(from: [url])
        
        return true
    }
}

// MARK: - DragDelegate
extension ViewController: DragDelegate {
    func receiveURLInfo(_ url: [URL]) {
        getDetail(from: url)
    }
    
    private func getDetail(from urls: [URL]) {
        mainView.initTextInfo()
        
        for url in urls {
            var isDirectory: ObjCBool = false
            
            var absolutePath = url.path
            
            if let urlPath = URL(string: url.path) {
                if let identifier = fileManager.getBundleIdentifier(urlPath) {
                    mainView.identifierDetailLabel.setText(identifier)
                    
                    let appPath = fileManager.getApplicationPath(bundleIdentifier: identifier) ?? ""
                    let exPath = fileManager.getExecutablePath(bundleIdentifier: identifier) ?? ""
                    
                    print("ExecutablePath :", exPath)
                    
                    absolutePath += " " + exPath
                    
                    mainView.pathDetailLabel.setText(absolutePath)
                }
            }
            
            mainView.pathDetailLabel.setText(absolutePath)
            
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    mainView.fileInfoLabel.setText("Folder :: \(url.path)")
                } else {
                    var text: String = ""
                    text += "File Path: \(url.path)\n"
                    
                    do {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
                        if let fileSize = fileAttributes[.size] as? UInt64 {
                            text += "File Size: \(fileSize) bytes\n"
                        }
                        if let creationDate = fileAttributes[.creationDate] as? Date {
                            text += "Creation Date: \(creationDate.toyyyyMMdd)\n"
                        }
                        if let modificationDate = fileAttributes[.modificationDate] as? Date {
                            text += "Modification Date: \(modificationDate.toyyyyMMdd)\n"
                        }
                        
                        mainView.fileInfoLabel.setText(text)
                        
                    } catch {
                        print("Failed to retrieve file attributes: \(error)")
                    }
                }
            }
        }
    }
}
