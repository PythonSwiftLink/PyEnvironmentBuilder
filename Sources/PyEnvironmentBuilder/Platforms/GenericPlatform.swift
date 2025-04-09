import Foundation
import PathKit

public struct Platforms {
    public enum SDK: String {
        case iphoneos
        case iphonesimulator
        case macosx
    }
    public enum Arch: String {
        case x86_64
        case arm64
    }
}


public extension Platforms.SDK {
    var xc_app_platform: String {
        switch self {
        case .iphoneos:
            "iPhoneOS.platform"
        case .iphonesimulator:
            "iPhoneSimulator.platform"
        case .macosx:
            "MacOSX.platform"
        }
    }
}

public typealias AnyPlatform = any GenericPlatform

public protocol GenericPlatform: AnyObject, CustomStringConvertible {
    var sdk: Platforms.SDK { get }
    var arch: Platforms.Arch { get }
    var version_min: String { get }
    var triple: String { get }
    var host_tiple: String { get }
    
    var ctx: Context { get }
    
    var _sysroot: Path? { get set }
    
    var environment: [String:PlatformEnvironment.EnvironmentValue] { get }
    
    var cc_cxx: Platforms.CC_CXX_Cache? { get }
    
    init(ctx: Context) async
    //var temp: Path { get }
    
    func updateEnvironment() throws
}

extension GenericPlatform {
    public var name: String { "\(sdk)-\(arch)" }
    public var description: String {
        name
    }
    public var libs_dir: Path {
        (ctx.dist_dir + "lib") + sdk.rawValue
    }
    
    public var sysroot: Path {
        if let _sysroot { return _sysroot }
        let sys_root: Path? = Process.xcrun(["--sdk", sdk.rawValue, "--show-sdk-path"])
        _sysroot = sys_root
        return sys_root!
    }
    
}



extension GenericPlatform {
    
    public static func new(_ ctx: Context) async -> AnyPlatform {
        await Self(ctx: ctx)
    }
    
    public typealias LDFlag = PlatformEnvironment.LDFlag
    public typealias CFlag = PlatformEnvironment.CFlag
    
    public var ar: String? { Process.findInSDK(sdk: sdk, "ar") }
    public var ld: String? { Process.findInSDK(sdk: sdk, "ld") }
    //public var _cc: String? { (try? Path.processUniqueTemporary())?.string }
    //
    public var cc: String? { Process.findInSDK(sdk: sdk, "clang") }
    public var cxx: String? { Process.findInSDK(sdk: sdk, "clang++") }
    
    public func linked_includes(include_dirs: [Path]) -> [Path] {
        include_dirs.flatMap { path in
            if path.isDirectory {
                return try! path.children()
            }
            return [path]
        }
    }
    
    public func generate_cflags(include_dirs: [Path], recipe_name: String? = nil) -> [CFlag] {
        
        let linked_includes = linked_includes(include_dirs: include_dirs)
        
        var CFLAGS: [CFlag] = [
            .string("-O3"),
            .string(version_min),
        ] + linked_includes.map({.linkedPath($0)})
        if let recipe_name {
            CFLAGS.append(.linkedPath(ctx.include_dir + "\(name)/\(recipe_name)"))
        }
        CFLAGS.append(.linkedPath(ctx.include_dir + name))
        CFLAGS.append(.arch(arch))
        return CFLAGS
    }
    
    public func generate_ldflags(include_dirs: [Path], recipe_name: String? = nil) -> [LDFlag] {
        
        let linked_includes = linked_includes(include_dirs: include_dirs)
        
        var LDFLAGS: [LDFlag] = [
            .arch(arch),
        ] + linked_includes.map({.linkedPath($0)})
        LDFLAGS.append(.linkedPath(sysroot + "usr/lib"))
        LDFLAGS.append(.string(version_min))
        
        return LDFLAGS
    }
    
    public var ccflags: [String] {[
        "--sysroot","\(sysroot)",
        "-arch", "\(arch)",
        "-pipe", "-no-cpp-precomp"
    ]}
    
    public var cc_cmd: String {
        "\(cc!) \(ccflags.whitespaced)"
    }
    
    func createEnvironment() throws -> PlatformEnvironment.Environment {
        let include_dir = ctx.include_dir
        //let _include = include_dir + name
        fatalError()
        let include_dirs = try! ctx.include_dir.children()

        let CFLAGS = generate_cflags(include_dirs: include_dirs, recipe_name: nil)
        let LDFLAGS = generate_ldflags(include_dirs: include_dirs)
        
        let OTHER_CFLAGS: [CFlag] = linked_includes(include_dirs: include_dirs).map({.linkedPath($0)})
        
        if !libs_dir.exists { try libs_dir.mkpath() }
        let lib_dirs: [LDFlag] = try! libs_dir.children().map({.linkedPath($0)}) + [.linkedPath(libs_dir)]
        
        guard let ar, let cc, let cxx, let ld else { fatalError() }
        
        let flags = [
            "--sysroot","\(sysroot)",
            "-arch", "\(arch)",
            "-pipe", "-no-cpp-precomp"
        ].whitespaced
 
//        return .init(
//            AR: ar,
//            CC: "\(cc) \(flags)",
//            CXX: "\(cxx) \(flags)",
//            LD: ld,
//            CFLAGS: CFLAGS,
//            LDFLAGS: LDFLAGS,
//            OTHER_CFLAGS: OTHER_CFLAGS,
//            OTHER_LDFLAGS: lib_dirs,
//            PATH: nil
//        )
    }
    
//    public func get_env(recipe_name: String? = nil) throws -> RecipeEnv.Environment {
//        
//        let include_dir = ctx.include_dir
//        //let _include = include_dir + name
//        
//        let include_dirs = try! ctx.include_dir.children()
//
//        let CFLAGS = generate_cflags(include_dirs: include_dirs, recipe_name: recipe_name)
//        let LDFLAGS = generate_ldflags(include_dirs: include_dirs)
//        
//        let OTHER_CFLAGS: [CFlag] = include_dirs.map({.linkedPath($0)})
//        
//        let lib_dirs: [LDFlag] = try! libs_dir.children().map({.linkedPath($0)})
//        
//        guard let ar, let cc, let cxx, let ld else { fatalError() }
//        
//        let flags = [
//            "--sysroot","\(sysroot)",
//            "-arch", "\(arch)",
//            "-pipe", "-no-cpp-precomp"
//        ].whitespaced
// 
//        return .init(
//            AR: ar,
//            CC: "\(cc) \(flags)",
//            CXX: "\(cxx) \(flags)",
//            LD: ld,
//            CFLAGS: CFLAGS,
//            LDFLAGS: LDFLAGS,
//            OTHER_CFLAGS: OTHER_CFLAGS,
//            OTHER_LDFLAGS: lib_dirs,
//            PATH: nil
//        )
//    }
    
    /*
     /Volumes/CodeSSD/kivy_ios_playground/build/libjpeg/iphoneos-arm64/jpeg-9d/configure
     
     CC=/var/folders/bj/tfgvjfdn7s9gg_n0tjgrkw900000gn/T/tmpub22s6p0
     LD=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld
     CFLAGS=-O3 -miphoneos-version-min=9.0 -I/Volumes/CodeSSD/kivy_ios_playground/dist/include/iphoneos-arm64/libjpeg -I/Volumes/CodeSSD/kivy_ios_playground/dist/include/iphoneos-arm64
     LDFLAGS=-arch arm64 -L/Volumes/CodeSSD/kivy_ios_playground/dist/lib/iphoneos -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/usr/lib -miphoneos-version-min=9.0
     --prefix=/ --host=aarch64-apple-darwin13
     --disable-shared-
    */
}
