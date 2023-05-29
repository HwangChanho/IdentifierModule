//
//  NSApplication.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/25.
//

import Foundation
import AppKit

extension NSApplication {
    func showAlert(_ text: String, style: NSAlert.Style = .warning) {
        let alert = NSAlert()
        alert.messageText = text
        alert.addButton(withTitle: "confirm")
        alert.alertStyle = style
        alert.runModal()
    }
}
