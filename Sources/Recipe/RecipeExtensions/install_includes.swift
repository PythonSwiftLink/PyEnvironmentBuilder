import Foundation
import Algorithms
import PyEnvironmentBuilder
import PathKit

public extension RecipeProtocol {
    
    func install_include(platform: AnyPlatform) throws {
        
        let include_destination = if include_per_platform() {
            context.include_dir + "\(platform.name)/\(name)"
        } else {
            context.include_dir + "common/\(name)"
        }
                
        include_destination.ensure()
        let includes = get_includes(platform) ?? []
        for include in includes {
            
            let dst = include_destination + include.lastComponent
            
            
            if include.isDirectory {
                for var item in try include.children() {
                    if item.isSymlink { item = try! item.symlinkDestination() }
                    let item_dest = include_destination + item.lastComponent
                    if item_dest.exists { continue }
                    try! item.copy(item_dest)
                }
            } else {
                if dst.exists { continue }
                var _include = if include.isSymlink { try include.symlinkDestination() } else { include }
                try! _include.copy(dst)
            }
            
        }
        
    }
    
    func install_includes() throws {
        for platform in self.platforms {
            try install_include(platform: platform)
        }
    }
}
