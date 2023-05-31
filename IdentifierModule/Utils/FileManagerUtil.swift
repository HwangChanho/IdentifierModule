//
//  FileManagerUtil.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/25.
//

import Foundation
import AppKit

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
    
    func openDirectory(_ directoryURL: URL) {
        if fileManager.fileExists(atPath: directoryURL.path) {
            workspace.open(directoryURL)
        } else {
            NSApplication.shared.showAlert("Directory not found at the specified path.")
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
    
    func getBundleIdentifier(_ url: URL) -> String {
        if let bundle = Bundle(path: url.path) {
            if let bundleIdentifier = bundle.bundleIdentifier {
                return bundleIdentifier
            } else {
                return "No Identifier"
            }
        } else {
            return "File or Directory"
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
        
        openApplication(withBundleIdentifier: getBundleIdentifier(searchURL))
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
    
    
    func getApplicationPath(bundleIdentifier: String) -> URL? {
        if let appPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return appPath
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
