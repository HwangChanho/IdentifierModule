//
//  NSApplication.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/25.
//

import Foundation
import AppKit

extension NSApplication {
    func showAlert(_ text: String, style: NSAlert.Style = .warning, isHandle: Bool = false, completionHandler: ((NSApplication.ModalResponse) -> Void)?) {
        let alert = NSAlert()
        alert.messageText = text
        alert.addButton(withTitle: "confirm")
        alert.alertStyle = style
        
        let window = alert.window
        let screenFrame = NSScreen.main?.visibleFrame ?? NSZeroRect
        let alertFrame = window.frame
        let centerX = NSMidX(screenFrame) - (alertFrame.size.width / 2)
        let centerY = NSMidY(screenFrame) - (alertFrame.size.height / 2)
        
        window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        
        if isHandle {
            alert.beginSheetModal(for: NSApplication.shared.windows.first!, completionHandler: completionHandler)
        }
        
        alert.runModal()
    }
}
