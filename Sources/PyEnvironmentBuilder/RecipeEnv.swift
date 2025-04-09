//
//  File.swift
//  
//
//  Created by CodeBuilder on 06/10/2024.
//

import Foundation
import PathKit

public struct RecipeEnv {
	public class Environment {
        public var AR: String
        public var CC: String
        public var CXX: String
        public var LD: String
        public var CFLAGS: [CFlag]
        public var LDFLAGS: [LDFlag]
        public var OTHER_CFLAGS: [CFlag]
        public var OTHER_LDFLAGS: [LDFlag]
        public var PATH: String?
		
		var _err_to_out = true
		var _iter = true
		var _out_bufsize = 1
        
        init(AR: String, CC: String, CXX: String, LD: String, CFLAGS: [CFlag], LDFLAGS: [LDFlag], OTHER_CFLAGS: [CFlag], OTHER_LDFLAGS: [LDFlag], PATH: String? = nil) {
            self.AR = AR
            self.CC = CC
            self.CXX = CXX
            self.LD = LD
            self.CFLAGS = CFLAGS
            self.LDFLAGS = LDFLAGS
            self.OTHER_CFLAGS = OTHER_CFLAGS
            self.OTHER_LDFLAGS = OTHER_LDFLAGS
            self.PATH = PATH
        }
        
        public var dictionary: [String:String] {
            
            var env = ProcessInfo.processInfo.environment
            
            env["AR"] = AR
            env["CC"] = CC
            env["CXX"] = CXX
            env["LD"] = LD
            env["CFLAGS"] = CFLAGS.map(\.description).whitespaced
            env["LDFLAGS"] = LDFLAGS.map(\.description).whitespaced
            env["OTHER_CFLAGS"] = OTHER_CFLAGS.map(\.description).whitespaced
            env["OTHER_LDFLAGS"] = OTHER_LDFLAGS.map(\.description).whitespaced
            
            return env
        }
	}
	static var workdir = Path.current
	
	public struct Paths {
		static let XCApp: Path = "/Applications/Xcode.app"
		static let Contents = XCApp + "Contents"
		static let Developer = Contents + "Developer"
		static let Toolchains: Path = Developer + "Toolchains"
		static let XCToolchain: Path = Toolchains + "XcodeDefault.xctoolchain"
		static let Platforms = Developer + "Platforms"
		static let AR: Path = XCToolchain + "usr/bin/ar"
		
		static let LD = XCToolchain + "/usr/bin/ld"
		static let MacOSX_SDKs = Platforms + "/MacOSX.platform/Developer/SDKs"
		
		
		static let DIST_FOLDER = Path.current + "dist"
		static let DIST_INCLUDE = DIST_FOLDER + "include"
		static let DIST_LIB = DIST_FOLDER + "lib"
		static let DIST_IPHONEOS = DIST_LIB + "iphoneos"
	}
}

public extension RecipeEnv.Environment {
    enum CFlag: CustomStringConvertible {
        
        case arch(Platforms.Arch)
        case string(String)
        case linkedPath(Path)
        
        public var description: String {
            switch self {
            case .arch(let arch): "-arch \(arch)"
            case .string(let string): string
            case .linkedPath(let path): "-I\(path)"
            }
        }
    }
    
    enum LDFlag: CustomStringConvertible {
        
        case arch(Platforms.Arch)
        case string(String)
        case linkedPath(Path)
        
        public var description: String {
            switch self {
            case .arch(let arch): "-arch \(arch)"
            case .string(let string): string
            case .linkedPath(let path): "-L\(path)"
            }
        }
    }
}
