//
//  File.swift
//  
//
//  Created by CodeBuilder on 07/10/2024.
//

import Foundation
import PathKit


fileprivate extension URL {
    static var chmod: Self {
        .init(filePath: "/bin/chmod")
    }
}


public protocol iPhoneSimulatorPlatform: GenericPlatform {}
extension iPhoneSimulatorPlatform {
	public var sdk: Platforms.SDK { .iphonesimulator }
	public var version_min: String { "-miphonesimulator-version-min=9.0" }
}

public protocol iPhoneOSPlatform: GenericPlatform {}
extension iPhoneOSPlatform {
	public var sdk: Platforms.SDK { .iphoneos }
	public var version_min: String { "-miphoneos-version-min=9.0" }
}

public protocol macOSPlatform: GenericPlatform {}
public extension macOSPlatform {
	var sdk: Platforms.SDK { .macosx }
	//var version_min: String { "-mmacosx-version-min=10.9" }
    var version_min: String { "-mmacosx-version-min=11.0" }
}


public extension Platforms {
    
    final class CC_CXX_Cache: CustomStringConvertible {
        
        
        private let temp: Path = try! .uniqueTemporary()
        
        private var _ccsh: Path?
        private var _cxxsh: Path?
        
        private let sdk: SDK
        
        private let arch: Arch
        
        private let sysroot: Path
        
        public let clang: Path
        
        init(sdk: SDK, arch: Arch, sysroot: Path) {
            self.sdk = sdk
            self.arch = arch
            self.sysroot = sysroot
            
            self.clang = .init(Process.findInSDK(sdk: sdk, "clang")!)
        }
        private var cflags: String {
            [
                "--sysroot", sysroot.string,
                "-arch", arch.rawValue,
                "-pipe", "-no-cpp-precomp"
            ].joined(separator: " ")
        }
        
        public var ccsh: Path {
            if let _ccsh { return _ccsh }
            
            if !temp.exists { try! temp.mkpath() }
            
            //guard let clang = Process.findInSDK(sdk: sdk, "clang") else { fatalError("sdk clang not found")}
            let file = """
            #!/bin/sh
            \(clang) \(cflags) "$@"\n
            """
            let _ccsh: Path = temp + "cc"
            
            self._ccsh = _ccsh
            try! _ccsh.write(file, encoding: .utf8)
            let proc = try! Process.run(.chmod, arguments: ["-x", _ccsh.string])
            proc.waitUntilExit()
            assert(_ccsh.exists)
            try! Process.run(.zsh, arguments: [_ccsh.string, "test.c"])
            
            return _ccsh
        }
        
        public var cxxsh: Path {
            if let _cxxsh { return _cxxsh }
            guard let clang = Process.findInSDK(sdk: sdk, "clang++") else { fatalError("sdk clang not found")}
            let file = """
            #!/bin/sh
            \(clang) \(cflags) "$@"\n
            """
            let _cxxsh: Path = temp + "cxx"
            self._cxxsh = _cxxsh
            try! _cxxsh.write(file, encoding: .utf8)
            try! Process.run(.chmod, arguments: ["-x", _cxxsh.string]).waitUntilExit()
            return _cxxsh
        }
        
        
        deinit {
            //try? temp.delete()
        }
        
        public var description: String { fatalError() }
    }
	
	final class iPhoneSimulatorARM64: iPhoneSimulatorPlatform {
		public let arch: Platforms.Arch = .arm64
		public let triple: String = "aarch64-apple-darwin"
        public var host_tiple: String = "arm64-apple-ios-simulator"
		public var ctx: Context
        public var _sysroot: Path?
		//public var temp: Path = try! .uniqueTemporary()
        @PlatformEnvironment public var environment
        public var cc_cxx: Platforms.CC_CXX_Cache?
		
        public init(ctx: Context) async {
			self.ctx = ctx
            _environment.projectedValue = .init(platform: self)
            cc_cxx = .init(sdk: sdk, arch: arch, sysroot: sysroot)
            //self.sysroot = Process.xcrun(["--sdk", sdk.rawValue, "--show-sdk-path"])
		}
        
        public func updateEnvironment() throws {
            
        }
        
		deinit {
			//try? temp.delete()
		}
	}
	
	final class iPhoneSimulatorx86_64: iPhoneSimulatorPlatform {
		public let arch: Platforms.Arch = .x86_64
		public let triple: String = "x86_64-apple-darwin"
        public var host_tiple: String = "x86_64-apple-ios-simulator"
		public var ctx: Context
        public var _sysroot: Path?
        
        @PlatformEnvironment
        public var environment
        public var cc_cxx: Platforms.CC_CXX_Cache?
        
        public init(ctx: Context) async {
            
			self.ctx = ctx
            _environment.projectedValue = .init(platform: self)
            cc_cxx = .init(sdk: sdk, arch: arch, sysroot: sysroot)
			//self.sysroot = Process.xcrun(["--sdk", sdk.rawValue, "--show-sdk-path"])
		}
        
        public func updateEnvironment() throws {
            _environment.projectedValue = .init(platform: self)
        }
        
		deinit {
			//try? temp.delete()
		}
	}
	
	final class iPhoneOSARM64: iPhoneOSPlatform {
		public let arch: Platforms.Arch = .arm64
		public let triple: String = "aarch64-apple-darwin"
        public var host_tiple: String = "arm64-apple-ios"
		public var ctx: Context
        public var _sysroot: Path?
        
        @PlatformEnvironment
        public var environment
        
        public var cc_cxx: Platforms.CC_CXX_Cache?

		
        public init(ctx: Context) async {
			self.ctx = ctx
            _environment.projectedValue = .init(platform: self)
            cc_cxx = .init(sdk: sdk, arch: arch, sysroot: sysroot)
			//self.sysroot = Process.xcrun(["--sdk", sdk.rawValue, "--show-sdk-path"])
		}
        
        
        public func updateEnvironment() throws {
            _environment.projectedValue = .init(platform: self)
        }
        
		deinit {
			//try? temp.delete()
		}
	}
	
	final class macOSx86_64: macOSPlatform {
		public let arch: Platforms.Arch = .x86_64
		public let triple: String = "x86_64-apple-darwin"
        public var host_tiple: String { triple }
		public var ctx: Context
        public var _sysroot: Path?
        
        @PlatformEnvironment
        public var environment
        
        public var cc_cxx: Platforms.CC_CXX_Cache?

		
        public init(ctx: Context) async {
			self.ctx = ctx
            _environment.projectedValue = .init(platform: self)//self.sysroot = Process.xcrun(["--sdk", sdk.rawValue, "--show-sdk-path"])
            cc_cxx = .init(sdk: sdk, arch: arch, sysroot: sysroot)
		}
        
        public func updateEnvironment() throws {
            _environment.projectedValue = .init(platform: self)
        }
        
        
		deinit {
			//try? temp.delete()
		}
	}
	
	final class macOSARM64: macOSPlatform {
		public let arch: Platforms.Arch = .arm64
		public let triple: String = "aarch64-apple-darwin"
        public var host_tiple: String { "arm64-apple-darwin" }
		public var ctx: Context
        public var _sysroot: Path?
        
        @PlatformEnvironment
        public var environment

        public var cc_cxx: Platforms.CC_CXX_Cache?
		
        public init(ctx: Context) async {
			self.ctx = ctx
            _environment.projectedValue = .init(platform: self)
			//self.sysroot = Process.xcrun(["--sdk", sdk.rawValue, "--show-sdk-path"])
            cc_cxx = .init(sdk: sdk, arch: arch, sysroot: sysroot)
		}
        
        public func updateEnvironment() throws {
            _environment.projectedValue = .init(platform: self)
        }
        
		deinit {
			//try? temp.delete()
		}
	}
}

extension Path {
	mutating func appending(_ path: String) -> Self {
		self + path
	}
}

