import Foundation
import PathKit

public struct Platforms {
    public enum SDK: String {
        case iphoneos
        case iphonesimulator
        case macosx
        case android
        case android_simulator
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
        case .android, .android_simulator:
            fatalError()
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
    
    var environment: [String:PlatformEnvironmentValue] { get }
    
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
    public static func new(_ ctx: Context) async -> AnyPlatform {
        await Self(ctx: ctx)
    }
    
    //public typealias LDFlag = LDFlag
    //public typealias CFlag = PlatformEnvironment<Self>.CFlag
}
