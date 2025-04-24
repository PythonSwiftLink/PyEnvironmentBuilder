//
//  Recipe.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 02/12/2024.
//
import Foundation
import PathKit
import PyEnvironmentBuilder

public protocol RecipeClass: AnyObject {
    var context: Context { get set }
    init(ctx: Context, platforms: [AnyPlatform])
    static func create(ctx: Context, platforms: [AnyPlatform]) -> Self
    
    func get_env(platform: AnyPlatform) -> [String:PlatformEnvironmentValue]
    
    func exclude_sdks_in_xcframework() -> [Platforms.SDK]?
    
}

public protocol RecipeProtocol: RecipeClass {
    var name: String { get }
    var version: String { get }
    //var main_src: Path { get }
    func src_name(_ platform: AnyPlatform?) -> String
    
    func src_folder(_ platform: AnyPlatform) -> Path
    
    var library: Path { get }
    func get_library(_ platform: AnyPlatform) -> Path
    
    func includes() -> [Path]?
    func get_includes(_ platform: AnyPlatform) -> [Path]?
    
    
    var downloads: [URL] { get }
    func pbx_frameworks() -> [String]
    func pbx_libraries() -> [String]
    
    var platforms: [AnyPlatform] { get }
    
    func include_per_platform() -> Bool

    func extracts(platform: AnyPlatform)

    func pre_build_platform(_ platform: AnyPlatform) async throws
    func build_platform(_ platform: AnyPlatform) async throws
    func post_build_platform(_ platform: AnyPlatform) async throws
    
    func create_xcframework() async throws
    
    
}

// makes the following protocol functions optional

public extension RecipeClass {
    
    
    
    static func create(ctx: Context, platforms: [AnyPlatform]) -> Self {
       
        return .init(ctx: ctx, platforms: platforms)
    }
    func _get_env(platform: AnyPlatform) -> [String:PlatformEnvironmentValue] {
        platform.environment
    }
    
    func exclude_sdks_in_xcframework() -> [Platforms.SDK]? { nil }
    
    func include_per_platform() -> Bool { false }
    
}

public extension RecipeProtocol {
    
    var supported_platforms: [AnyPlatform] {
        if let excluded_sdks = exclude_sdks_in_xcframework() {
           return platforms.filter({!excluded_sdks.contains($0.sdk)})
        }
        
        return platforms
    }
    
    func src_folder(_ platform: AnyPlatform) -> Path { build_dir(platform: platform) + src_name(platform) }
    
    func get_library(_ platform: AnyPlatform) -> Path {
        src_folder(platform) + library
    }
    func pre_build_platform(_ platform: AnyPlatform) async throws {}
    func post_build_platform(_ platform: AnyPlatform) async throws {}
        
    func includes() -> [PathKit.Path]? { nil }
    
    func get_includes(_ platform: AnyPlatform) -> [Path]? {
        guard let _includes = includes() else { return nil }
        let src = src_folder(platform)
        return _includes.map({src + $0})
    }
    
    func pbx_frameworks() -> [String] {[]}
    func pbx_libraries() -> [String] {[]}
    
    
//    func get_env(platform: AnyPlatform) -> [String:String] {
//        _get_env(platform: platform)
//    }
//    
    
}


extension RecipeProtocol where Self: Recipe.CythonRecipe {
    public func cythonize_build(platform: AnyPlatform) throws {
        let src = src_folder(platform)
        let kivy_src = src.parent()
        //var env = platform.environment
        var env = ProcessInfo.processInfo.environment
        //try cythonize(folder: src, currentDirectory: src)
        //CYTHONIZE(file: <#T##Path#>, env: <#T##[String : String]?#>, currentDirectory: <#T##Path?#>)
        //try src.chdir {
        //env["PWD"] = (src + "kivy").string
        
            for pyx in src.filter({$0.extension == "pyx"}) {
                let current = pyx.parent()
                //env["PWD"] = current.string
                try CYTHONIZE(
                    file: pyx.relative(to: current)!,
                    env: env,
                    currentDirectory: current.parent()
                )
                //try? pyx.delete()
            }
        //}
    }
    
    public func cythonize(file: Path, env: [String:String]?,  currentDirectory: Path?) throws {
        let proc = Process()
        proc.executablePath = .cythonize_py
        proc.environment = env
        proc.arguments = [
            file.string,
        ]
        proc.currentDirectory = currentDirectory
        try proc.run()
        proc.waitUntilExit()
    }
    
    public func CYTHONIZE(file: Path, env: [String:String]?,  currentDirectory: Path?) throws {
        //guard let cython: Path = Process.which("cython") else { fatalError("cython not found")}
        let process = Process()
        process.executablePath = .systemPython
        process.processArguments = [
            Path.cythonize_py,
            file,
            //"--working", currentDirectory!
        ]
        //print(env)
        
        process.environment = env
        process.currentDirectory = currentDirectory
        try process.run()
        process.waitUntilExit()
    }
    
    public func cythonize(file: Path, env: [String:PlatformEnvironmentValue],  currentDirectory: Path?) throws {
        let proc = Process()
        proc.executablePath = .cythonize_py
        proc.arguments = [
            //"python",
            //"-C",
            //Path.cythonize_py.string,
//            "-m",
//            "cython",
            file.string,
            //"-I\(currentDirectory!)"
        ]
        proc.currentDirectory = currentDirectory
        try proc.run()
        proc.waitUntilExit()
    }
    
    public func cythonize(folder: Path,  currentDirectory: Path?) throws {
        let proc = Process()
        proc.executablePath = .systemPython
        var env = ProcessInfo.processInfo.environment
        env["PWD"] = currentDirectory?.string
        let PATH = [
            "/usr/local/opt/cython/bin",
            //"/Library/Frameworks/Python.framework/Versions/3.13/bin",
            "/Library/Frameworks/Python.framework/Versions/3.11/bin",
            "/usr/local/bin",
            "/System/Cryptexes/App/usr/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin",
            "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin",
            "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin",
            "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin",
            "/Library/Apple/usr/bin",
            "/usr/local/opt/cython/bin",
            //"/Library/Frameworks/Python.framework/Versions/3.13/bin",
            "/Library/Frameworks/Python.framework/Versions/3.11/bin"
        ].joined(separator: ":")
        //env["PATH"]? += ":\(PATH)"
        proc.environment = env
        proc.processArguments = [
            Path.toolchain_cythonize,
            "cythonize_folder",
            //Path.cythonize_folder.string,
            //Path.cythonize.string,
            folder,
            //Path.systemPython.string
        ]
        proc.currentDirectory = currentDirectory
        try proc.run()
        
        proc.waitUntilExit()
    }
}



public protocol ProcessArgument {
    func processArg() -> String
}

extension String: ProcessArgument {
    public func processArg() -> String {
        self
    }
}
extension Path: ProcessArgument {
    public func processArg() -> String {
        string
    }
}
extension Process {
    public var processArguments: [any ProcessArgument]? {
        get {
            arguments
        }
        set {
            arguments = newValue?.map({$0.processArg()})
        }
    }
}


