//
//  File.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 02/12/2024.
//

import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe


public final class SDL2Mixer: BaseRecipe, RecipeProtocol {
    public let name: String = "SDL2_mixer"
    
    public let version: String = "2.6.3"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "SDL2_mixer-\(version)"
    }
    
    public var library: Path = ""
    
    public func get_library(_ platform: AnyPlatform) -> Path {
        let src = src_folder(platform)
        return switch platform.sdk {
        case .macosx:
            src + "Xcode/build/Release/libSDL2_mixer.a"
        default:
            src + "Xcode/build/Release-\(platform.sdk)/libSDL2_mixer.a"
        }
    }
    
    public func includes() -> [Path]? {
        ["include/"]
    }
    
    public var downloads: [URL] {[
        .init(string: "https://github.com/libsdl-org/SDL_mixer/releases/download/release-\(version)/SDL2_mixer-\(version).tar.gz")!
    ]}
    public func pbx_frameworks() -> [String] {
        ["ImageIO"]
    }
    public func pbx_libraries() -> [String] {
        ["libc++"]
    }
    
    public func build_platform(_ platform: any GenericPlatform) async throws {
        var env = get_env(platform: platform)
        
        env.removeValue(forKey: "CC")
        let sdl2 = SDL2(ctx: context, platforms: platforms)
        let sdl2_includes = sdl2.get_includes(platform)!.first!
        let head_search = "$HEADER_SEARCH_PATHS /usr/include/machine \(sdl2_includes) "
        
        try xc_build(
            context.concurrent_xcodebuild,
            header_search_paths: head_search,
            project: "Xcode/SDL_mixer.xcodeproj",
            target: "Static Library",
            configuration: "Release",
            platform: platform,
            env: env.normalized,
            currentDirectory: src_folder(platform)
        )
        
    }
    
}


