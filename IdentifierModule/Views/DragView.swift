//
//  View.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/22.
//

import Cocoa

protocol DragDelegate {
    func receiveURLInfo(_ url: [URL])
}

class DragView: NSView {
    var delegate: DragDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func setView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        
        registerForDraggedTypes([.URL, .fileURL, .fileContents])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingSourceOperationMask.contains(.copy) {
            return .copy
        }
        return []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL]
        
        guard let urls = fileURLs else {
            return false
        }
        
        delegate?.receiveURLInfo(urls)
        
        return true
    }
}
