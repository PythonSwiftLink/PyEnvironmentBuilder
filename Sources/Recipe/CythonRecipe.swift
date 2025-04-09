//
//  File.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 07/12/2024.
//

import Foundation
import PyEnvironmentBuilder
import PathKit

extension Recipe {
    open class CythonRecipe: RecipeClass {
        
        public var context: PyEnvironmentBuilder.Context
        
        public var platforms: [any PyEnvironmentBuilder.GenericPlatform]
        
        public required init(ctx: PyEnvironmentBuilder.Context, platforms: [any PyEnvironmentBuilder.GenericPlatform]) {
            context = ctx
            self.platforms = platforms
            let ex = exclude_sdks_in_xcframework() ?? []
            print(Self.self,platforms.filter({!ex.contains($0.sdk)}))
        }
        
        public func exclude_sdks_in_xcframework() -> [Platforms.SDK]? {
            [.macosx]
        }
        
        open func get_env(platform: AnyPlatform) -> [String:PlatformEnvironment.EnvironmentValue] {
            var env = platform.environment
            
            env["KIVYIOSROOT"] = .path("/Volumes/CodeSSD/kivy_ios_playground/venv/lib/python3.11/site-packages/kivy_ios")
            env["IOSSDKROOT"] = .path(platform.sysroot)
            env["CUSTOMIZED_OSX_COMPILER"] = "True"
            
            env["ARM_LD"] = env["LD"]
            env["PLATFORM_SDK"] = "\(platform.sdk)"
            env["ARCH"] = "\(platform.arch)"
            env["LDSHARED"] = .path(.liblink)
            return env
        }
        
        
    }
}

public extension Recipe.CythonRecipe {
    
    
    
    func cy_build_platform(_ platform: AnyPlatform, src: Path) async throws {
        
        var env = get_env(platform: platform)
        
        try Process.exec(cmd: .systemPython, environment: env.normalized, currentDirectory: src) {
            [
                "setup.py", "build_ext", "-g"
            ]
        }
    }
}


