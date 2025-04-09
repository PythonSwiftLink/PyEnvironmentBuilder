// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import PathKit

extension String {
    static var whitespace: String { " " }
}

extension Array where Element == String {
    var whitespaced: String { joined(separator: .whitespace) }
}

public extension Path {
    static var xcodebuild: Self { "/usr/bin/xcodebuild" }
    
    func chdir(closure: () async throws -> ()) async rethrows {
      let previous = Path.current
      Path.current = self
      defer { Path.current = previous }
      try await closure()
    }
    
}

extension Path {
    
    func relative(to root: Self) -> Self? {
        let root_components = root.components
        guard starts(with: root) else { return nil }
        let relative_components = components[root_components.count...]
        return .init(components: relative_components)
    }
}
