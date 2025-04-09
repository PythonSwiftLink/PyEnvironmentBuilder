import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe


func configureJPEG_library(triple: String, env: [String : String]?, currentDirectory: Path) throws {
    try Process.exec(cmd: currentDirectory + "configure", environment: env, currentDirectory: currentDirectory) {[
        "--prefix=/",
        "--host=\(triple)",
        "--disable-shared"
    ]}
}


public final class Jpeg: BaseRecipe, RecipeProtocol {
    
    
    public var name: String = "libjpeg"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "jpeg-\(version.dropFirst())"
    }
    
    public var version: String = "v9c"
    
    public var library: PathKit.Path = ".libs/libjpeg.a"
    
    public func includes() -> [Path]? {
        [
            "jpeglib.h",
            "jconfig.h",
            "jerror.h",
            "jmorecfg.h"
        ]
    }

    public var downloads: [URL] {[
        .init(string: "http://www.ijg.org/files/jpegsrc.\(version).tar.gz")!
    ]}
    
    public func include_per_platform() -> Bool { true }
    
    public func build_platform(_ platform: any GenericPlatform) async throws {
        var env = get_env(platform: platform).normalized
        env["CC"] = platform.cc_cmd
        let workDir = src_folder(platform)
        
        try configureJPEG_library(
            triple: platform.triple,
            env: env,
            currentDirectory: workDir
        )
        
        try make_clean(currentDirectory: workDir)
        try make(context.concurrent_make, environment: env, currentDirectory: workDir)
    }
    
    
    
    
}
