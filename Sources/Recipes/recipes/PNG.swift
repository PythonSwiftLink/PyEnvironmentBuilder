import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe




public final class PNG: BaseRecipe, RecipeProtocol {
    public var name: String = "libpng"
    
    public var version: String = "1.6.40"
    
    public func src_name(_ platform: AnyPlatform? = nil) -> String {
        "libpng-\(version)"
    }
    
    public var library: PathKit.Path {
        ".libs/libpng16.a"
    }
    
    
    public var downloads: [URL] {[
        .init(string: "https://downloads.sourceforge.net/sourceforge/libpng/libpng-\(version).tar.gz")!
    ]}
    
    public func includes() -> [Path]? {
        ["dist/include"]
    }
    
    public func build_platform(_ platform: any GenericPlatform) async throws {
        let env = get_env(platform: platform).normalized
        
        let workDir = src_folder(platform)
        try configure(
            triple: platform.triple,
            env: env,
            currentDirectory: workDir
        )
        try make(context.concurrent_make, environment: env, currentDirectory: workDir)

        try Process.make_install(
            environment: env,
            currentDirectory: workDir
        )
        
    }
    
    fileprivate func configure(triple: String, env: [String : String]?, currentDirectory: Path) throws {
            let proc = Process()
            proc.executableURL = (currentDirectory + "configure").url
            proc.currentDirectoryURL = currentDirectory.url
            
            let arguments = [
                "--prefix=\(currentDirectory + "dist")",
                "--host=\(triple)",
                "--disable-shared"
            ]
            proc.arguments = arguments
            proc.environment = env
            try proc.run()
            proc.waitUntilExit()
            
        
    }

}
