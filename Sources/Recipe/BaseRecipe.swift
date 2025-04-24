//
//  BaseRecipe.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 08/12/2024.
//

import PyEnvironmentBuilder
import Foundation
import PathKit

open class BaseRecipe {
    
    public var context: PyEnvironmentBuilder.Context
    
    public var platforms: [any PyEnvironmentBuilder.GenericPlatform]
    
    public required init(ctx: PyEnvironmentBuilder.Context, platforms: [any PyEnvironmentBuilder.GenericPlatform]) {
        context = ctx
        self.platforms = platforms
        let ex = exclude_sdks_in_xcframework() ?? []
        print(Self.self,platforms.filter({!ex.contains($0.sdk)}))
        
    }
    
}

extension BaseRecipe: RecipeClass {
    
    
    public func get_env(platform: AnyPlatform) -> [String : PlatformEnvironmentValue] {
        platform.environment
    }
}
