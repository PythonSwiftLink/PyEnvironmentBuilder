//
//  SDL2TTF.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 04/12/2024.
//

import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe


public final class SDL2TTF: BaseRecipe, RecipeProtocol {
    public let name: String = "SDL_ttf"
    
    public let version: String =  "2.20.2"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "SDL2_ttf-\(version)"
        //"SDL_ttf-2.6.3"
    }
    
    public func get_library(_ platform: AnyPlatform) -> Path {
        let src = src_folder(platform)
        return switch platform.sdk {
        case .macosx:
            src + "Xcode/build/Release/\(library)"
        default:
            src + "Xcode/build/Release-\(platform.sdk)/\(library)"
        }
    }
    public var library: Path = "libSDL2_ttf.a"
    
    
    
    public func includes() -> [Path]? {
        ["SDL_ttf.h"]
    }
    
    public var downloads: [URL] {[
        // "https://github.com/libsdl-org/SDL_ttf/releases/download/release-{version}/SDL2_ttf-{version}.tar.gz"
        .init(string: "https://github.com/libsdl-org/SDL_ttf/releases/download/release-\(version)/SDL2_ttf-\(version).tar.gz")!
    ]}
    
    public func pbx_frameworks() -> [String] {
        ["ImageIO"]
    }
    
    public func pbx_libraries() -> [String] {
        ["libc++"]
    }

    public func pre_build_platform(_ platform: AnyPlatform) async throws {
        apply_patch(Patches.harfbuzz, target: src_folder(platform), platform: platform)
    }
    
    public func build_platform(_ platform: any GenericPlatform) async throws {
        var env = get_env(platform: platform)
        
        env.removeValue(forKey: "CC")
        
        let common = context.common
        
        let header_search_paths = [
            "sdl2", "libpng"
        ].lazy
            .map({common + $0})
            .map(\.string)
            .joined(separator: " "
        )
        let args: [String] = [
            "GENERATE_MASTER_OBJECT_FILE=YES",
            "GCC_PREPROCESSOR_DEFINITIONS=$(GCC_PREPROCESSOR_DEFINITIONS) FT_CONFIG_OPTION_USE_PNG=1"
        ]
        
        try xc_build(
            args: args,
            header_search_paths: header_search_paths,
            project: "Xcode/SDL_ttf.xcodeproj",
            target: "Static Library",
            platform: platform,
            env: env.normalized,
            currentDirectory: src_folder(platform)
        )
        
    }
    
}
