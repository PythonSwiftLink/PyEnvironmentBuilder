//
//  create_xcframeworks.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 11/12/2024.
//
import Foundation
import PathKit

public extension RecipeProtocol {
    func create_xcframeworks() {
        //let excludes = exclude_sdks_in_xcframework() ?? []
        //let supported_platforms = platforms.filter({excludes.contains($0.sdk)})
        let library_name = library.lastComponentWithoutExtension
        let dist_xcframework = context.xcframework
        let xcframework_fn = dist_xcframework + "\(library_name).xcframework"
        if xcframework_fn.exists { return }
        let xcframework_args: [String] = supported_platforms.reduce(into: ["-create-xcframework"]) { partialResult, platform in
            partialResult.append("-library")
            partialResult.append(get_dist_lib_file(platform: platform).string)
        }
//        let xcframework_args: [String] = supported_platforms.lazy.map(get_library).compactMap {[weak self] library in
//            guard let this = self else { return nil }
//            //let library_fn = library.lastComponent
//            
//            
//            
//            let xcframework_args: [String] = platforms.flatMap { platform in
//                let dist = get_dist_lib_file(platform: platform)
//                
//                return ["-library", "\(dist)"]
//            }
//            
//            return xcframework_args
//        }
        
        let arguments = xcframework_args + ["-output", xcframework_fn.string]
        print(arguments)
        try! Process.run(
            Path.xcodebuild.url,
            arguments: arguments
        ).waitUntilExit()
    }
}
