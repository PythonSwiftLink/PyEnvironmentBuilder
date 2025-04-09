import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe


public final class Python3: BaseRecipe, RecipeProtocol {
    
    
    public var name: String = "libpython"
    
    public var version: String = "3.11.6"
    
    public func src_name(_ platform: AnyPlatform?) -> String {
        "python-\(version)"
    }
    
    public var library: PathKit.Path {
        .current
    }
    
    public var downloads: [URL] {
        []
    }
    
    public func include_per_platform() -> Bool { true }
    
    public func build_platform(_ platform: AnyPlatform) async throws {
        
    }
    
    
}
