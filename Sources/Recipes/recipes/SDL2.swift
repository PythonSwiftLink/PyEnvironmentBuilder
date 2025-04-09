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

public final class SDL2: BaseRecipe, RecipeProtocol {

    public let name = "SDL2"
    
    public var version: String = "2.28.5"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "SDL2-\(version)"
    }
    
    
    public var downloads: [URL] {[
        .init(stringLiteral: "https://github.com/libsdl-org/SDL/releases/download/release-\(version)/SDL2-\(version).tar.gz")
    ]}
    
    public func includes() -> [Path]? {
        ["include"]
    }
//    public func get_include(_ platform: AnyPlatform) -> [Path]? {
//       
//    }
    
    public func get_library(_ platform: AnyPlatform) -> Path {
        let src = src_folder(platform)
        
        return switch platform.sdk {
        case .iphoneos, .iphonesimulator:
            src + "Xcode/SDL/build/Release-\(platform.sdk)/libSDL2.a"
        case .macosx:
            src + "Xcode/SDL/build/Release/libSDL2.a"
        }
    }
    
    public var library: PathKit.Path = "libSDL2.a"
    
    public func pbx_frameworks() -> [String] {[
        "OpenGLES", "AudioToolbox", "QuartzCore", "CoreGraphics",
        "CoreMotion", "GameController", "AVFoundation", "Metal",
        "UIKit", "CoreHaptics"
    ]}
    
    public func build_platform(_ platform: any GenericPlatform) async throws {
        var env = get_env(platform: platform)
        
        env.removeValue(forKey: "CC")
        try xc_build(
            context.concurrent_xcodebuild,
            project: "Xcode/SDL/SDL.xcodeproj",
            target: platform.sdk == .macosx ? "Static Library" : "Static Library-iOS",
            configuration: "Release",
            platform: platform,
            env: env.normalized,
            currentDirectory: src_folder(platform)
        )
    }
    
    
}
    

