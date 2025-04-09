//
//  File.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 11/12/2024.
//

import Foundation
import Algorithms
import PyEnvironmentBuilder


public extension RecipeProtocol {
    func lipoize_libraries() throws {
        
        let chucked_platforms = supported_platforms
            .chunked(on: \.sdk)
        
        for (sdk, platforms) in chucked_platforms {
//            let excludes = exclude_sdks_in_xcframework()
//            if excludes?.contains(sdk) ?? false {
//                continue
//            }
            //let dest = context.dist_dir + "lib/\(sdk)/\(recipe.library.lastComponent)"
            let platform = platforms.first!
            let dist_file = get_dist_lib_file(platform: platform)
            if dist_file.exists { continue }
            switch sdk {
            case .iphoneos:
                
                try get_library(platform).copy(dist_file)
            case .iphonesimulator, .macosx:
                try lipo(
                    output: dist_file,
                    libs: platforms.map { ($0.arch, get_library($0)) }
                )
            }
        }
        
    }
}
