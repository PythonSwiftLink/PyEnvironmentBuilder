import Foundation
import PathKit
import PyEnvironmentBuilder


public extension RecipeProtocol {

    
    func apply_patch(_ file: Path, target: Path?, platform: AnyPlatform) {
        if let target {
            Process.patch(target_dir: target, filename: file)
        } else {
            Process.patch(target_dir: src_folder(platform), filename: file)
        }
    }
    
    func lipo(output: Path, libs: [(Platforms.Arch, Path)]) throws {
        try Process.exec(cmd: .lipo, environment: nil, currentDirectory: nil) {
            
            let args = libs.flatMap { (arch, path) in
                ["-arch", arch.rawValue, path.string]
                }
            
            return [
                "-create", "-output", output.string
            ] + args
        }
    }
    
    func biglink(output: Path, platform: AnyPlatform) {
        var dirs: [String] = src_folder(platform).reduce(into: [(output + library).string]) { partialResult, path in
            //print(path.extension ?? "no ext")
            if path.extension == "libs" {
                let parent = path.parent().string
                if !partialResult.contains(parent) {
                    partialResult.append(parent)
                }
            }
        }
        print("biglink", dirs)
        try! Process.run(Path.biglink.url, arguments: dirs).waitUntilExit()
    }
    
    
}

extension Array where Element == Path {
    func reduceInto(_ updateAccumulatingResult: (_ partialResult: inout Self, Self.Element) throws -> ()) rethrows -> Self
    
    {
        try reduce(into: Self.init(), updateAccumulatingResult)
    }
}
// make commands

public extension RecipeProtocol {
    
    func make_clean(environment: [String : String]? = nil, currentDirectory: Path) throws {
        try Process.make_clean(currentDirectory: currentDirectory)
    }
    
    func make(_ concurrent_make: String, environment: [String : String]?, currentDirectory: Path) throws {
        try Process.make(concurrent_make, environment: environment, currentDirectory: currentDirectory)
    }
    
    func make_install(environment: [String : String]?, currentDirectory: Path?) throws {
        try Process.make_install(environment: environment, currentDirectory: currentDirectory)
    }
    
    func xc_build(
        _ concurrent: String? = nil,
        args: [String]? = nil,
        header_search_paths: String? = nil,
        project: Path,
        target: String,
        configuration: String = "Release",
        platform: AnyPlatform ,
        env: [String : String]? = nil,
        currentDirectory: Path
    ) throws {
        //guard let platform else { fatalError("no platform")}
        try Process.xcodebuild(
            concurrent: concurrent ?? context.concurrent_xcodebuild,
            args: args,
            env: env,
            arch: platform.arch,
            header_search_paths: header_search_paths,
            sdk: platform.sdk,
            project: project,
            target: target,
            configuration: configuration,
            currentDirectory: currentDirectory
        )
    }
}
