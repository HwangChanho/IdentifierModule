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
        
        label.stringValue = "이곳에 파일을 드레그 하세요."
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
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setDisplay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func setDisplay() {
        [dragView, identifierLabel, pathLabel].forEach {
            self.addSubview($0)
        }
        
        dragView.addSubview(infoLabel)
        
        dragView.layer?.cornerRadius = 8
        
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
            make.left.equalTo(dragView.snp.right).offset(50)
            make.top.equalTo(dragView.snp.top).offset(50)
        }
        
        pathLabel.snp.makeConstraints { make in
            make.left.equalTo(dragView.snp.right).offset(50)
            make.top.equalTo(identifierLabel.snp.bottom).offset(50)
        }
    }
}
