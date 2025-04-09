import Foundation
import PathKit
import PyEnvironmentBuilder
import Algorithms

public extension RecipeProtocol {
    func execute() async throws {
        ensure_dir()
        try await download_files()
        for platform in supported_platforms {
            extracts(platform: platform)
            try await pre_build_platform(platform)
            try await build_platform(platform)
            try await post_build_platform(platform)
            try install_include(platform: platform)
            //try platform.updateEnvironment()
        }
        
    }
}
