import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe

public final class Freetype: BaseRecipe, RecipeProtocol {
    public var name: String = "freetype"
    
    public var version: String = "2.5.5"
    
    public var library: PathKit.Path = "objs/.libs/libfreetype.a"
    
    public var downloads: [URL] {[
        .init(string: "https://download.savannah.gnu.org/releases/freetype/freetype-old/freetype-\(version).tar.bz2")!
    ]}
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "freetype-\(version)"
    }
   
    public func includes() -> [Path]? {
        [
            "include",
            "builds/unix/ftconfig.h",
            //"config/ftconfig.h"
        ]
    }
    
    public func include_per_platform() -> Bool { true }
    
    public func build_platform(_ platform: AnyPlatform) async throws {
        var env = get_env(platform: platform).normalized
        
        env["CC"] = platform.cc_cmd
        let workDir = src_folder(platform)
        
        try configure(triple: platform.triple, env: env, currentDirectory: workDir)
        try make_clean(environment: env, currentDirectory: workDir)
        try make(context.concurrent_make, environment: env, currentDirectory: workDir)
    }
    
    fileprivate func configure(triple: String, env: [String : String]?, currentDirectory: Path) throws {
            let proc = Process()
            proc.executableURL = (currentDirectory + "configure").url
            proc.currentDirectoryURL = currentDirectory.url
            
            let arguments = [
                "--prefix=/dist",
                "--host=\(triple)",
                "--without-png",
                "--without-bzip2",
                "--without-fsspec",
                "--without-harfbuzz",
                "--without-old-mac-fonts",
                "--enable-static=yes",
                "--enable-shared=no"
            ]
            proc.arguments = arguments
            proc.environment = env
            try proc.run()
            proc.waitUntilExit()
            
        
    }
}
//
//public final class _Freetype: RecipeProtocol {
//    
//    
//    public let name: String = "Freetype"
//    
//    public var version: String = "2.5.5"
//    
//    public func src_folder(_ platform: AnyPlatform) -> Path {
//        build_dir(platform: platform) + "freetype-\(version)"
//    }
//    public var library: PathKit.Path { "objs/.libs/libfreetype.a"}
//    
//    public var downloads: [URL] {[
//        .init(string: "https://download.savannah.gnu.org/releases/freetype/freetype-old/freetype-\(version).tar.bz2")!
//    ]}
//    
//    public func includes() -> [Path]? {
//        let src = src_folder(<#T##platform: AnyPlatform##AnyPlatform#>)
//        return [
//            "include",
//            "builds/unix/ftconfig.h",
//            "config/ftconfig.h"
//        ].map({ main_src + $0})
//    }
//    
//    public var context: PyEnvironmentBuilder.Context
//    
//    public var platform: (any PyEnvironmentBuilder.GenericPlatform)?
//    
//    public var platforms: [any GenericPlatform]
//    
//    public init(ctx: Context, platforms: [any GenericPlatform]) {
//        context = ctx
//        self.platforms = platforms
//    }
//    
//    public func build_platform(_ platform: any GenericPlatform) async throws {
//        var env = get_env(platform: platform)
//        
//        let workDir = main_src
//        
//        try configure(triple: platform.triple, env: env, currentDirectory: workDir)
//        try make_clean(environment: env, currentDirectory: workDir)
//        try make(context.concurrent_make, environment: env, currentDirectory: workDir)
//    }
//    
//  
//    
//    
//
//}
