import Foundation
import PathKit
import PyEnvironmentBuilder
import Algorithms

public extension RecipeProtocol {
    
    
    func create_xcframework() async throws {
        
    }
    
    func updateContext() {
        
    }
    
    
   

    func build() async throws {
        for platform in self.platforms {
            try await build_platform(platform)
        }
    }
    
    
    
    
    func all_platform_libraries() -> [Path] {
        supported_platforms.map(get_library(_:))
    }
    
    
    var build_root_dir: Path { context.build_dir + name }
    
    func build_dir(platform: AnyPlatform) -> Path {
        //guard let platform else { fatalError() }
        return switch platform.sdk {
        case .macosx, .iphonesimulator:
            build_root_dir + "\(platform.sdk)_\(platform.arch)"
        default:
            build_root_dir + platform.sdk.rawValue
        }
    }
    
    func ensure_dir() {
        for platform in self.platforms {
            let build_dir = build_dir(platform: platform)
            build_dir.ensure()
            swift_package_src.ensure()
        }
    }
    

    
    func extracts(platform: AnyPlatform) {
        let build_root = build_dir(platform: platform)
        //if build_root.exists { return }
        for file in downloads.lazy.map(\.lastPathComponent) {
            let cache_file = context.cache_dir + file
            if (build_root + file).exists { continue }
            //print("extracting: \(cache_file)")
            Process.untar(file: cache_file, destination: build_root )
        }
    }
    
}

public extension RecipeProtocol {
    
    func get_dist_lib_file(platform: AnyPlatform) -> Path {
        platform.libs_dir + get_library(platform).lastComponent
    }
    
//    var dist_lib_a: Path {
//        platform!.libs_dir + library.lastComponent
//    }
    
    func clean(platform: AnyPlatform) throws {
        
        let src = src_folder(platform)
        if src.exists { try src.delete() }
        
        let dist = get_dist_lib_file(platform: platform)
        
        if dist.exists { try dist.delete() }
    }
    
    
}


extension URL {
    var asPath: Path { .init(path())}
}


public extension RecipeProtocol {
    
    var swift_package_src: Path {
        build_root_dir + "swift_package_src"
    }
    
}


public extension RecipeProtocol {
    
}




extension Path {
    func ensure() {
        if exists { return }
        try! mkpath()
    }
    
    
}

public extension Dictionary where Key == String, Value == String {
    @inlinable subscript(key: Key) -> Path? {
        get {
            guard let value: String = self[key] else { return nil }
            return .init(value)
        }
        set {
            guard let newValue else { return }
            self[key] = newValue.string
        }
    }
  
    
}
