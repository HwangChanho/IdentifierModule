//
//  Label.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/22.
//

import Cocoa

class Label: NSTextField, NSTextViewDelegate {
    var url: String?
    var linkClickedHandler: ((URL) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setConfig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func resetCursorRects() {
        if url != nil {
            discardCursorRects()
            addCursorRect(self.bounds, cursor: .pointingHand)
        }
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if url != nil {
            // create a click gesture recognizer
            let gesture = NSClickGestureRecognizer(target: self, action: #selector(textFieldClicked(_:)))
            self.addGestureRecognizer(gesture)
        }
    }
    
    @objc func textFieldClicked(_ sender: NSClickGestureRecognizer) {
        // handle the click event
        guard let stringUrl = self.url else { return }
        if let url = URL(string: stringUrl) {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func setConfig() {
        self.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
        self.backgroundColor = .clear
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = true
        self.sizeToFit()
    }
    
    func setText(_ text: String) {
        self.stringValue = text
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if let currentEditor = currentEditor() {
            currentEditor.selectAll(self)
        }
    }
}

