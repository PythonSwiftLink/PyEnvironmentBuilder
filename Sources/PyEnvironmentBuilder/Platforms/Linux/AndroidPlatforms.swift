//
//  Linux.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 20/04/2025.
//

import Foundation
import PathKit

public protocol AndroidPlatform: LinuxPlatform {
    
}

public protocol AndroidSimulator: AndroidPlatform {
    
}



public extension Platforms {
    
    final class AndroidSimulatorArm64: AndroidSimulator {
        public let sdk: Platforms.SDK = .android
        
        public var arch: Platforms.Arch = .arm64
        
        public var version_min: String = ""
        
        public var triple: String
        
        public var host_tiple: String
        
        public var ctx: Context
        
        public var _sysroot: PathKit.Path?
        
        public var environment: [String : PlatformEnvironmentValue]
        
        public var cc_cxx: Platforms.CC_CXX_Cache?
        
        public required init(ctx: Context) async {
            fatalError()
        }
        
        public func updateEnvironment() throws {
            fatalError()
        }
        
        
    }
    
    final class AndroidSimulatorX86_64: AndroidSimulator {
        public let sdk: Platforms.SDK = .android
        
        public var arch: Platforms.Arch = .x86_64
        
        public var version_min: String = ""
        
        public var triple: String
        
        public var host_tiple: String
        
        public var ctx: Context
        
        public var _sysroot: PathKit.Path?
        
        public var environment: [String : PlatformEnvironmentValue]
        
        public var cc_cxx: Platforms.CC_CXX_Cache?
        
        public required init(ctx: Context) async {
            fatalError()
        }
        
        public func updateEnvironment() throws {
            fatalError()
        }
        
        
    }
    
    final class AndroidArm64: AndroidPlatform {
        public let sdk: Platforms.SDK = .android
        
        public var arch: Platforms.Arch = .arm64
        
        public var version_min: String = ""
        
        public var triple: String
        
        public var host_tiple: String
        
        public var ctx: Context
        
        public var _sysroot: PathKit.Path?
        
        public var environment: [String : PlatformEnvironmentValue]
        
        public var cc_cxx: Platforms.CC_CXX_Cache?
        
        public required init(ctx: Context) async {
            fatalError()
        }
        
        public func updateEnvironment() throws {
            fatalError()
        }
        
        
    }
    
    final class AndroidX86_64: AndroidPlatform {
        public let sdk: Platforms.SDK = .android
        
        public var arch: Platforms.Arch = .x86_64
        
        public var version_min: String = ""
        
        public var triple: String
        
        public var host_tiple: String
        
        public var ctx: Context
        
        public var _sysroot: PathKit.Path?
        
        public var environment: [String : PlatformEnvironmentValue]
        
        public var cc_cxx: Platforms.CC_CXX_Cache?
        
        public required init(ctx: Context) async {
            fatalError()
        }
        
        public func updateEnvironment() throws {
            fatalError()
        }
        
        
    }
    
}
