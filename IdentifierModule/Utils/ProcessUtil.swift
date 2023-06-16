//
//  CommonUtil.swift
//  IdentifierModule
//
//  Created by jiran_daniel on 2023/05/22.
//

import Foundation
import AppKit

class ProcessUtil: NSObject {
    static let shared = ProcessUtil()
    private override init() {}
    
    func getProcIdentifier(_ pid: pid_t) -> NSString? {
        guard let strProcessPath = getProcessPath(for: pid) else { return nil }
        
        let urlPath = NSURL(string: strProcessPath)
        
        var secCode: SecStaticCode? = nil
        var osStatus = OSStatus()
        osStatus = SecStaticCodeCreateWithPath(urlPath!, [], &secCode)
        
        if secCode == nil || osStatus == errSecSuccess {
            return nil
        }
        
        var cfSignInfoDict: CFDictionary? = nil
        osStatus = SecCodeCopySigningInformation(secCode!, SecCSFlags(rawValue: kSecCSInternalInformation), &cfSignInfoDict)
        
        if cfSignInfoDict == nil || osStatus != errSecSuccess {
            return nil
        }
        
        let dictSignInfo: NSDictionary = cfSignInfoDict!
        return dictSignInfo.object(forKey: "identifier") as? NSString
    }
    
    func getProcessPath(for processID: pid_t) -> String? {
        print(#function)
        let process = Process()
        process.launchPath = "/bin/ps" // 정상적인 프로세스인지 체크 해야한다 안할경우 악성코드를 실행할 여지도 있다.
        process.arguments = ["-p", "\(processID)", "-o", "comm="]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            let trimmedOutput = output?.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedOutput
        } else {
            return nil
        }
    }
    
    func getProcessPID(for processPath: String) -> pid_t? {
        let workspace = NSWorkspace.shared
        let runningApplications = workspace.runningApplications
        
        for application in runningApplications {
            let bundleURL = application.bundleURL
            let bundlePath = bundleURL?.path
                
            if bundlePath == processPath {
                return application.processIdentifier
            }
        }
        
        return nil
    }
}
