//
//  File.swift
//  
//
//  Created by CodeBuilder on 17/08/2024.
//

import Foundation
import PathKit

let toolchain_path = "/Library/Frameworks/Python.framework/Versions/3.11/bin/toolchain"

extension Process {
    
    public var currentDirectory: Path? {
        get {
            if let currentDirectoryURL {
                return .init(currentDirectoryURL.path())
            }
            return nil
        }
        set {
            currentDirectoryURL = newValue?.url
        }
    }
    public var executablePath: Path? {
        get {
            if let executableURL {
                return .init(executableURL.path())
            }
            return nil
        }
        set {
            executableURL = newValue?.url
        }
    }
	
	static func toolchain(build recipes: [String], path: Path) -> Self {
		let process = Self()
		//process.currentDirectoryURL = path.url
		process.executableURL = .init(filePath: toolchain_path)
		var arguments = [
			//"toolchain",
			//"/Users/codebuilder/Library/Python/3.11/bin/toolchain",
			"build",
		]
		arguments.append(contentsOf: recipes)
		print(arguments)
		process.arguments = arguments
		return process
	}
    
    @discardableResult
    public static func exec(cmd: Path, environment: [String:String]? = nil, currentDirectory: Path? = nil, _ arguments: (()->[String])?) throws -> Bool {
        let proc = Process()
        proc.executablePath = cmd
        proc.environment = environment
        
        proc.currentDirectory = currentDirectory
        proc.arguments = arguments?()
        try proc.run()
        proc.waitUntilExit()
        return proc.terminationStatus == 0
    }
}
