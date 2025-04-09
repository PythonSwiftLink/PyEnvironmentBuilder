

import Foundation
import PathKit


public struct Recipe {}



public let tools: Path = .init(Bundle.module.path(forResource: "tools", ofType: nil)!)

public extension Path {
    static let cythonize: Path = tools + "cythonize"
    static let cythonize_py: Path = tools + "cythonize.py"
    static let toolchain_cythonize = tools + "toolchain_cythonize.py"
    static let cythonize_folder: Path = tools + "cythonize_folder.py"
    static let liblink: Path = tools + "liblink"
    static let biglink: Path = tools + "biglink"
    
    static let zsh = URL.zsh.asPath
    static let sh = URL.sh.asPath
}


public extension Path {
    
    func relative(to root: Self) -> Self? {
        let src = string
        let root_string = root.string
        if src.starts(with: root_string) {
            return .init(String(string.suffix(src.count - root_string.count - 1)))
        }
        return nil
    }
    
    func _relative(to root: Self) -> Self? {
        let root_components = root.components
        //let is_relative = start
        guard string.hasPrefix(root.string) else { fatalError(self.string) }
        let relative_components = components[root_components.count...]
        print("relative_components", Path(components: relative_components))
        return .init(components: relative_components)
    }
}


public enum EnvironmentKeys: String {
    case CC, CXX, AR, LD,
         CFLAGS, LDFLAGS,
         OTHER_CFLAGS, OTHER_LDFLAGS
    
    case KIVYIOSROOT, IOSSDKROOT, CUSTOMIZED_OSX_COMPILER, LDSHARED,
         ARM_LD, ARCH, C_INCLUDE_PATH, LIBRARY_PATH, PATH, PKG_CONFIG
        
}
