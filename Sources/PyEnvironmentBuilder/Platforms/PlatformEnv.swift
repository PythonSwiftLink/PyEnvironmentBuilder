import Foundation
import PathKit
@propertyWrapper
public class PlatformEnvironment<P: GenericPlatform> {

    public typealias Value = [String:PlatformEnvironmentValue]
    
    private var env: Environment?
    
    
    
    public var wrappedValue: Value {
        (try? env?.new_environment()) ?? [:]
    }
    
    public var projectedValue: Environment? {
        get {
            env
        }
        set {
            env = newValue
        }
    }
    
    public init() {
    }
    
    
    
    public struct _Environment {
        
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
}


public extension PlatformEnvironment {
    
}

public enum CFlag: CustomStringConvertible {
    
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

public enum LDFlag: CustomStringConvertible {
    
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

public extension PlatformEnvironment {
    
    
    
    class Environment {
        static var processEnvironment: [String:String] { ProcessInfo.processInfo.environment }
        
        var envDictionary: [String: PlatformEnvironmentValue]
        
        weak var platform: P?
        
        public var cc_cxx: Platforms.CC_CXX_Cache?
        
        public init(platform: P? = nil) {
            self.platform = platform
            envDictionary = Self.processEnvironment.mapValues({ value in
                    .string(value)
            })
//            if let platform {
//                cc_cxx = .init(sdk: platform.sdk, arch: platform.arch, sysroot: platform.sysroot)
//            }
        }
        
        public init(platform: P? = nil) where P: ApplePlatform {
            self.platform = platform
            envDictionary = Self.processEnvironment.mapValues({ value in
                    .string(value)
            })
            if let platform {
                cc_cxx = .init(sdk: platform.sdk, arch: platform.arch, sysroot: platform.sysroot)
            }
        }
        
        public func new_environment() throws -> [ String : PlatformEnvironmentValue ] {
            guard let platform else { fatalError() }
            fatalError()
//            let ctx = platform.ctx
//            let include_dirs = try! ctx.include_dir.children()
//
//            let CFLAGS = platform.generate_cflags(include_dirs: include_dirs, recipe_name: nil)
//            let LDFLAGS = platform.generate_ldflags(include_dirs: include_dirs)
//            
//            let OTHER_CFLAGS: [CFlag] = platform.linked_includes(include_dirs: include_dirs).map({.linkedPath($0)})
//            
//            let libs_dir = platform.libs_dir
//            if !libs_dir.exists { try libs_dir.mkpath() }
//            let lib_dirs: [LDFlag] = try! libs_dir.children().map({.linkedPath($0)}) + [.linkedPath(libs_dir)]
//            
//            guard let cc_cxx, let ar = platform.ar, let ld = platform.ld else { fatalError() }
//            
//            var newEnv = envDictionary
//            
//            
//            
//            newEnv["AR"] = .path(.init(ar))
//            newEnv["LD"] = .path(.init(ld))
//            newEnv["CC"] = .string(platform.cc_cmd)
//            newEnv["CXX"] = .path(cc_cxx.cxxsh)
//            newEnv["CFLAGS"] = .cflags(CFLAGS)
//            newEnv["LDFLAGS"] = .ldflags(LDFLAGS)
//            newEnv["OTHER_CFLAGS"] = .cflags(OTHER_CFLAGS)
//            newEnv["OTHER_LDFLAGS"] = .ldflags(lib_dirs)
//            
//            return newEnv
            
        }
        
        
        public func new_environment() throws -> [ String : PlatformEnvironmentValue ] where P: ApplePlatform {
            guard let platform else { fatalError() }
            let ctx = platform.ctx
            let include_dirs = try! ctx.include_dir.children()

            let CFLAGS = platform.generate_cflags(include_dirs: include_dirs, recipe_name: nil)
            let LDFLAGS = platform.generate_ldflags(include_dirs: include_dirs)
            
            let OTHER_CFLAGS: [CFlag] = platform.linked_includes(include_dirs: include_dirs).map({.linkedPath($0)})
            
            let libs_dir = platform.libs_dir
            if !libs_dir.exists { try libs_dir.mkpath() }
            let lib_dirs: [LDFlag] = try! libs_dir.children().map({.linkedPath($0)}) + [.linkedPath(libs_dir)]
            
            guard let cc_cxx, let ar = platform.ar, let ld = platform.ld else { fatalError() }
            
            var newEnv = envDictionary
            
            
            
            newEnv["AR"] = .path(.init(ar))
            newEnv["LD"] = .path(.init(ld))
            newEnv["CC"] = .string(platform.cc_cmd)
            newEnv["CXX"] = .path(cc_cxx.cxxsh)
            newEnv["CFLAGS"] = .cflags(CFLAGS)
            newEnv["LDFLAGS"] = .ldflags(LDFLAGS)
            newEnv["OTHER_CFLAGS"] = .cflags(OTHER_CFLAGS)
            newEnv["OTHER_LDFLAGS"] = .ldflags(lib_dirs)
            
            return newEnv
            
        }
    }
    
    
}

public enum PlatformEnvironmentValue: CustomStringConvertible, ExpressibleByStringLiteral, RawRepresentable, ExpressibleByStringInterpolation {
    public var rawValue: String { description }
    
    case string(String)
    case strings([String])
    case path(Path)
    case paths([Path])
    case cflags([CFlag])
    case ldflags([LDFlag])
    
    public init?(rawValue: String) {
        self = .string(rawValue)
    }
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    
    public var description: String {
        switch self {
        case .string(let string):
            string
        case .strings(let strings):
            strings.whitespaced
        case .path(let path):
            path.string
        case .paths(let paths):
            paths.map(\.string).whitespaced
        case .cflags(let array):
            array.map(\.description).whitespaced
        case .ldflags(let array):
            array.map(\.description).whitespaced
        }
    }
}

public extension Dictionary where Value: CustomStringConvertible {
    var normalized: [Key : String] { mapValues(\.description) }
}
