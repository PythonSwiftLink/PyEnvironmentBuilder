//
//  File.swift
//  
//
//  Created by CodeBuilder on 07/10/2024.
//

import Foundation
import PathKit

public extension URL {
	static let which = URL(filePath: "/usr/bin/which")
	static let patch = URL(filePath: "/usr/bin/patch")
	static let xcrun = URL(filePath: "/usr/bin/xcrun")
	static let tar = URL(filePath: "/usr/bin/tar")
    static let xcodebuild = URL(filePath: "/usr/bin/xcodebuild")
    static let sh = URL(filePath: "/bin/sh")
    static let zsh = URL(filePath: "/bin/zsh")
    static let make = URL(filePath: "/usr/bin/make")
}

extension String {
	func strip() -> String {
		var this = self
		this.removeLast()
		return this
	}
}

public extension Process {
    static func patch(target_dir: String, filename: String) {
        let prc = Self()
        
        prc.executableURL = .patch
        prc.arguments = ["-t", "-d", target_dir, "-p1", "-i", filename]
        
    }
    
    static func patch(target_dir: Path, filename: Path) {
        let prc = Self()
        
        prc.executableURL = .patch
        prc.arguments = ["-t", "-d", target_dir.string, "-p1", "-i", filename.string]
        try! prc.run()
        prc.waitUntilExit()
    }
    
    static func command(_ command: Path, args: [String], environment: [String:String]? = nil, currentDirectory: Path? = nil) throws {
        let proc = Self()
        
        proc.executableURL = command.url
        proc.arguments = args
        
        
        
        proc.environment = environment
        proc.currentDirectoryURL = currentDirectory?.url
        try proc.run()
        proc.waitUntilExit()
        let status = proc.terminationStatus
        if status != 0 { fatalError("exit code \(status)") }
        
    }
    
    static func sh(_ args: [String], environment: [String:String]? = nil) {
        let proc = Self()
        
        proc.executableURL = .zsh
        proc.arguments = args
    }
    
    static func which(_ name: String) -> String? {
        let proc = Process()
        //proc.executableURL = .init(filePath: "/bin/zsh")
        proc.executableURL = .which
        proc.arguments = [name]
        let pipe = Pipe()
        
        proc.standardOutput = pipe
        
        
        try? proc.run()
        proc.waitUntilExit()
        
        guard
            let data = try? pipe.fileHandleForReading.readToEnd(),
            let path = String(data: data, encoding: .utf8)
        else { return nil }
        
        return path.strip()
    }
    @_disfavoredOverload
    static func which(_ name: String) -> Path? {
        if let path: String = which(name) {
            return .init(path)
        }
        return nil
    }
    
    static func xcrun(_ args: [String]) -> String? {
        let proc = Process()
        //proc.executableURL = .init(filePath: "/bin/zsh")
        proc.executableURL = .xcrun
        proc.arguments = args
        let pipe = Pipe()
        
        proc.standardOutput = pipe
        
        
        try? proc.run()
        proc.waitUntilExit()
        
        guard
            let data = try? pipe.fileHandleForReading.readToEnd(),
            let path = String(data: data, encoding: .utf8)
        else { return nil }
        
        return path.strip()
    }
    
    @_disfavoredOverload
    static func xcrun(_ args: [String]) -> Path? {
        if let path: String = xcrun(args) {
            return .init(path)
        }
        return nil
    }
    
    
    
    static func findInSDK(sdk: Platforms.SDK, _ name: String) -> String? {
        xcrun(["-find", "-sdk", sdk.rawValue, name])
    }
    
    static func untar(file: Path, destination: Path) {
        let proc = Process()
        
        proc.executableURL = .init(filePath: "/usr/bin/tar")
        proc.arguments = [
            "-C",
            destination.string,
            "-x","-z","-f",
            file.string
            
        ]
        try? proc.run()
        proc.waitUntilExit()
    }
    
    static func cmd() {
        let proc = Process()
        proc.environment?[""] = ""
    }
    
    static func xcodebuild(
        concurrent: String,
        args: [String]? = nil,
        env: [String:String]? = nil,
        arch: Platforms.Arch,
        header_search_paths: String? = nil,
        sdk: Platforms.SDK,
        project: Path,
        target: String,
        configuration: String = "Release",
        currentDirectory: Path? = nil
    ) throws {
        
        let proc = Process()
        proc.executableURL = .xcodebuild
        
        var arguments = [
            concurrent,
            "ONLY_ACTIVE_ARCH=NO",
            "ARCHS=\(arch)",
            //"CC=\(platform.temp)",
        ]
        if let args {
            arguments.append(contentsOf: args)
        }
        if let header_search_paths {
            arguments.append("HEADER_SEARCH_PATHS=\(header_search_paths)")
        }
        arguments.append(contentsOf: [
            "-sdk", sdk.rawValue,
            "-project", project.string,
            "-target", target,
            "-configuration", configuration
        ])
        proc.arguments = arguments
        proc.environment = env
        proc.currentDirectoryURL = currentDirectory?.url
        try proc.run()
        
        proc.waitUntilExit()
    }
    
    static func make(_ args: [String], environment: [String:String]? = nil, currentDirectory: Path? = nil) throws {
        let proc = Process()
        
        proc.executableURL = .make
        
        proc.arguments = args
        proc.environment = environment
        proc.currentDirectoryURL = currentDirectory?.url
        print(proc.arguments!)
        
        try proc.run()
        
        proc.waitUntilExit()
        
    }
    
    static func make_clean(currentDirectory: Path? = nil) throws {
        let proc = Process()
        
        proc.executableURL = .make
        
        proc.arguments = ["clean"]
        proc.currentDirectoryURL = currentDirectory?.url
        try proc.run()
        
        proc.waitUntilExit()
    }
    
    static func make(_ concurrent_make: String, environment: [String:String]? = nil, currentDirectory: Path? = nil) throws {
        let proc = Process()
        
        proc.executableURL = .make
        
        proc.arguments = [ concurrent_make]
        proc.environment = environment
        proc.currentDirectoryURL = currentDirectory?.url
        
        try proc.run()
        
        proc.waitUntilExit()
        
    }
    
    static func make_install(environment: [String:String]? = nil, currentDirectory: Path? = nil) throws {
        let proc = Process()
        
        proc.executableURL = .make
        
        proc.arguments = ["install"]
        proc.environment = environment
        proc.currentDirectoryURL = currentDirectory?.url
        
        try proc.run()
        
        proc.waitUntilExit()
        
    }
    
}

