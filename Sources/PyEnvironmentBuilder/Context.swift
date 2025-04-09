//
//  File.swift
//  
//
//  Created by CodeBuilder on 07/10/2024.
//

import Foundation
import PathKit

let processInfo = ProcessInfo.processInfo

public struct Context {
    public static let shared = try! Context(root_dir: .current)
    
    public let num_cores = processInfo.processorCount
	
    public let root_dir: Path
    public let build_dir: Path
    public let cache_dir: Path
    public let dist_dir: Path
    public let install_dir: Path
    public var include_dirs: [Path] = []
    public let include_dir: Path
    public let frameworks: Path
    public let common: Path
    public let swift_packages: Path
	
    public var xcframework: Path {
        let xc = dist_dir + "xcframework"
        try! xc.ensure()
        return xc
    }
	//public var env: [String : String]
	
	public init(root_dir: Path) throws {
		
		//self.env = processInfo.environment
		
		self.root_dir = root_dir
		
		self.build_dir = root_dir + "build"
		let dist_dir = root_dir + "dist"
		self.dist_dir = dist_dir
		self.cache_dir = root_dir + ".cache"
		let include_dir = dist_dir + "include"
		self.include_dir = include_dir
		self.install_dir = dist_dir + "root"
		self.frameworks = dist_dir + "frameworks"
		self.common = include_dir + "common"
        self.swift_packages = root_dir + "swift_packages"
        
	}
	
}

fileprivate extension Path {
	func ensure() throws {
		if exists { return }
        print("making dir -> \(self)")
		try mkdir()
	}
}

public extension Context {
	
	
	
	func ensure_dirs() throws {
		try root_dir.ensure()
		try build_dir.ensure()
		try cache_dir.ensure()
		try dist_dir.ensure()
		try frameworks.ensure()
		try include_dir.ensure()
		try install_dir.ensure()
		try common.ensure()
		
	}
	
	
	var concurrent_make: String { "-j\(num_cores)" }
	var concurrent_xcodebuild: String { "IDEBuildOperationMaxNumberOfConcurrentCompileTasks=\(num_cores)"}
}
