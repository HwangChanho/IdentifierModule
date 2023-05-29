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
    }
    
    func checkLocTest(withKeyword keyword: String) {
        if searchFilesAndFolders(withKeyword: keyword) {
            print(keyword)
        }
    }
    
    func searchFilesAndFolders(withKeyword keyword: String, _ atPath: String = "/") -> Bool {
        let fileManager = FileManager.default
        let searchURL = URL(fileURLWithPath: atPath)
        
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
                        // Recursively search subdirectories
                        searchFilesAndFolders(withKeyword: keyword, itemURL.path)
                    } else {
                        // Check if the item matches the search predicate
                        if predicate.evaluate(with: itemURL.lastPathComponent) {
                            print(itemURL.path)
                            return true
                        }
                    }
                }
            }
            
            // Print the matching file or folder paths
            //            if !filteredContents.isEmpty {
            //                print("Files and folders matching '\(keyword)':")
            //                for itemURL in filteredContents {
            //                    print("done ::", itemURL.path)
            //                    return true
            //                }
            //            } else {
            //                print("No files or folders found matching '\(keyword)'.")
            //                return false
            //            }
        } catch {
//            print("Error accessing directory: \(error)")
            return false
        }
        
        return false
    }
}
