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
import SwiftPrettyPrint

public final class Pillow: Recipe.CythonRecipe , RecipeProtocol {
    
    public let name: String = "pillow"
    public let version: String = "8.2.0"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "Pillow-\(version)"
    }
    public var downloads: [URL] {
        [.init(string: "https://pypi.python.org/packages/source/P/Pillow/Pillow-\(version).tar.gz")!]
    }
    
    public func pbx_frameworks() -> [String] {
        ["CoreGraphics", "MobileCoreServices"]
    }
    
    public var library: Path = "libpillow.a"
    
    public func include_per_platform() -> Bool { true }
    
    public func pre_build_platform(_ platform: AnyPlatform) async throws {
        apply_patch(Patches.patches + "pillow/bypass-find-library.patch", target: src_folder(platform), platform: platform)
        print("applied patch <pillow/bypass-find-library.patch>")
        
    }
    
    
    
    public func build_platform(_ platform: AnyPlatform) async throws {
//        var env: [String: PlatformEnvironment.EnvironmentValue] = get_env(platform: platform).reduce(into: [:]) { partialResult, next in
//            var (key, value) = next
//            switch EnvironmentKeys(rawValue: key) {
//            case .none:
//                break
//            case .CC:
//                partialResult[key] = .string(platform.cc_cmd)
//            case .LDFLAGS:
//                switch value {
//                case .ldflags(var flags):
//                    flags.remove(atOffsets: [1,2, 3])
//                    partialResult[key] = .ldflags(flags)
//                default: break
//                }
//                
//            default:
//                partialResult[key] = value
//            }
//        }
        
        var env = get_env(platform: platform)
        let main_src = src_folder(platform)
        
        //env.removeValue(forKey: "CC")
//        print("pillow setup.py env:")
//        for item in env {
//            //print("\t\(item.key): \(item.value)")
//        }
        Pretty.prettyPrint(label: "pillow setup.py env", env.normalized)
        print()
        try Process.exec(cmd: .systemPython, environment: env.normalized, currentDirectory: main_src) {
            return [
                "setup.py",
                "build_ext",
                "--disable-tiff",
                "--disable-webp",
                "--disable-jpeg2000",
                "--disable-lcms",
                "--disable-platform-guessing",
                "-g"
            ]
        }
    }
    
    public override func get_env(platform: AnyPlatform) -> [String : PlatformEnvironmentValue] {
        var env = super.get_env(platform: platform)
        if let platform = platform as? ApplePlatform {
            let sysroot_usr = platform.sysroot + "usr"
            env["C_INCLUDE_PATH"] = .path(sysroot_usr + "include")
            env["LIBRARY_PATH"] = .path(sysroot_usr + "lib")
            //        if var CFLAGS = env["CFLAGS"] {
            //            let include_plat = context.include_dir + platform.name
            //            CFLAGS += [
            //                " -I\(include_plat + "freetype")",
            //                "-I\(include_plat + "libjpeg")"
            //            ].whitespaced
            //            env["CFLAGS"] = CFLAGS
            //        }
            //env["CC"] = .string(platform.cc_cmd)
            env["ARCHFLAGS"] = "-arch \(platform.arch)"
            if platform.sdk != .macosx {
                env["PKG_CONFIG"] = "ios-pkg-config"
            }
            
           
        }
        return env
    }
    
    public func post_build_platform(_ platform: AnyPlatform) async throws {
        if platform.sdk == .macosx { return }
        biglink(output: src_folder(platform), platform: platform)
    }
    
    func process_env(_ env: inout [String:String]) {
        
    }
}
