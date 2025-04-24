
import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe


public final class Kivy: Recipe.CythonRecipe, RecipeProtocol {
    public var name: String = "kivy"
    
    public var version: String = "master"
    
    public func src_name(_ platform: PyEnvironmentBuilder.AnyPlatform?) -> String {
        "kivy-\(version)"
    }
    
    public var library: PathKit.Path = "libkivy.a"
    
    public var downloads: [URL] {[
        .init(string: "https://github.com/kivy/kivy/archive/\(version).zip")!
    ]}
    
    public func pbx_frameworks() -> [String] {
        ["OpenGLES", "Accelerate", "CoreMedia", "CoreVideo"]
    }
    
    public override func get_env(platform: AnyPlatform) -> [String : PlatformEnvironmentValue] {
        var env = super.get_env(platform: platform)
        let include_platform = context.include_dir + "\(platform.name)/"
        env["KIVY_SDL2_PATH"] = .string( [
                "sdl2", "sdl2_image", "sdl2_ttf", "sdl2_mixer"
            ].map({(include_platform + $0).string}).joined(separator: ":")
        )
        return env
    }
    
    public func _cythonize_build(platform: AnyPlatform) throws {
        
        //let src = src_folder(platform)
        //print(src)
        //let kivy_root = src + "kivy"
        //let env = get_env(platform: platform)
        //try cythonize(folder: src, currentDirectory: nil)
        //try src.chdir {
//            print(src)
//            
//            for pyx in src.filter({$0.extension == "pyx"}) {
//                print(pyx)
//                if let relative_pyx = pyx.relative(to: src) {
//                    print(relative_pyx)
//                    
//                    try cythonize(
//                        //file: .init(pyx.string.replacingOccurrences(of: src.string + "/", with: "")),
//                        file: relative_pyx,
//                        env: ProcessInfo.processInfo.environment.mapValues({.string($0)}),
//                        currentDirectory: nil
//                    )
//                }
//                //            } else {
//                //                print("couldnt make \n\t\(pyx)\relative to:\n\t\(src)")
//                //            }
//            }
        //}
        
    }
    
    public func pre_build_platform(_ platform: AnyPlatform) async throws {
        try cythonize_build(platform: platform)
    }
    
    public func build_platform(_ platform: PyEnvironmentBuilder.AnyPlatform) async throws {
        //try await cy_build_platform(platform, src: src_folder(platform))
    }
    
    
}
