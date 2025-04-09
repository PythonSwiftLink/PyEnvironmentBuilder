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

   
    
public final class SDL2Image: BaseRecipe, RecipeProtocol {
    
    public let name: String = "SDL2_image"
    
    public let version: String = "2.8.0"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "SDL2_image-\(version)"
    }
    public var library: Path = ""
    
    public func get_library(_ platform: AnyPlatform) -> Path {
        let src = src_folder(platform)
        return switch platform.sdk {
        case .iphoneos, .iphonesimulator:
            src + "Xcode/build/Release-\(platform.sdk)/libSDL2_image.a"
        case .macosx:
            src + "Xcode/build/Release/libSDL2_image.a"
        }
    }
    
    public func includes() -> [Path]? {
        ["include/SDL_image.h"]
    }
    
    public var downloads: [URL] {[
        .init(string: "https://github.com/libsdl-org/SDL_image/releases/download/release-\(version)/SDL2_image-\(version).tar.gz")!
    ]}
    
    public func pbx_frameworks() -> [String] { ["CoreGraphics", "MobileCoreServices"] }
        
    public func build_platform(_ platform: any GenericPlatform) async throws {
        
        var env = get_env(platform: platform)
        env.removeValue(forKey: "CC")
        
        let sdl2 = SDL2(ctx: context, platforms: platforms)
        let sdl2_includes = sdl2.get_includes(platform)!.first!
        try xc_build(
            context.concurrent_xcodebuild,
            args: nil,
            header_search_paths: sdl2_includes.string,
            project: "Xcode/SDL_image.xcodeproj",
            target: "Static Library",
            configuration: "Release",
            platform: platform,
            env: env.normalized,
            currentDirectory: src_folder(platform)
        )
        
    }
    
    
}


