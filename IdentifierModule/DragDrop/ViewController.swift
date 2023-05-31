//
//  ViewController.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/22.
//

import Cocoa
import SnapKit

class ViewController: NSViewController {
    let mainView = MainView()
    
    let localizationManager = LocalizationManager.shared
    let fileManager = FileManagerUtil.shared
    
    override func loadView() {
        super.loadView()
        
        self.view = mainView
        mainView.languageComboBox.selectItem(at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
    }
    
    private func setDelegate() {
        mainView.dragView.delegate = self
        mainView.languageComboBox.delegate = self
        mainView.searchTextField.delegate = self
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
            NSApplication.shared.showAlert("한글은 검색이 불가합니다.")
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
            
            let absolutePath = url.path
            mainView.pathDetailLabel.setText(absolutePath)
            
            let identifier = fileManager.getBundleIdentifier(URL(string: url.path)!)
            mainView.identifierDetailLabel.setText(identifier)
            
            
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
