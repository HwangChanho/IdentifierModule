//
//  MainVIew.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/22.
//

import Cocoa

class MainView: NSView {
    let dragView = DragView()
    let infoLabel: Label = {
        let label = Label()
        
        label.stringValue = NSLocalizedString("DragFileInfo", comment: "")
        label.textColor = .white
        
        return label
    }()
    
    let identifierLabel: Label = {
        let label = Label()
        
        label.stringValue = "Bundle Identifier :: "
        label.textColor = .white
        
        return label
    }()
    
    let pathLabel: Label = {
        let label = Label()
        
        label.stringValue = "Path :: "
        label.textColor = .white
        
        return label
    }()
    
    let identifierDetailLabel = Label()
    let pathDetailLabel = Label()
    let fileInfoLabel = Label()
    
    let languageComboBox = NSComboBox()
    
    var languages: [Language] = [.english, .korean]
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setDisplay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func initTextInfo() {
        identifierDetailLabel.setText("")
        pathDetailLabel.setText("")
        fileInfoLabel.setText("")
    }
    
    private func setDisplay() {
        languages.forEach {
            languageComboBox.addItem(withObjectValue: $0.name)
        }
        
        dragView.layer?.cornerRadius = 8
        pathDetailLabel.textColor = .white
        identifierDetailLabel.textColor = .white
        languageComboBox.isEditable = false
        
        [dragView, identifierLabel, pathLabel, identifierDetailLabel, pathDetailLabel, fileInfoLabel, languageComboBox].forEach {
            self.addSubview($0)
        }
        
        dragView.addSubview(infoLabel)
        
        languageComboBox.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        dragView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(30)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        identifierLabel.snp.makeConstraints { make in
            make.left.equalTo(dragView.snp.right).offset(20)
            make.top.equalTo(dragView.snp.top).offset(20)
            make.width.equalTo(identifierLabel.intrinsicContentSize)
        }
        
        identifierDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(identifierLabel)
            make.left.equalTo(identifierLabel.snp.right)
            make.right.equalToSuperview().offset(-20)
        }
        
        pathLabel.snp.makeConstraints { make in
            make.left.equalTo(identifierLabel)
            make.top.equalTo(identifierLabel.snp.bottom).offset(30)
            make.width.equalTo(pathLabel.intrinsicContentSize)
        }
        
        pathDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(pathLabel)
            make.left.equalTo(pathLabel.snp.right)
            make.right.equalTo(identifierDetailLabel)
        }
        
        fileInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(pathDetailLabel.snp.bottom).offset(30)
            make.left.equalTo(identifierLabel)
            make.right.equalTo(identifierDetailLabel)
        }
    }
}
