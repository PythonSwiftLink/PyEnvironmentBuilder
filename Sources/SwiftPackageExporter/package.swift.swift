//
//  package.awift.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 11/12/2024.
//
import Foundation
import SwiftSyntax
import SwiftParser
import Recipe
import Recipes

public extension SwiftPackageExporter {
    
    class PackageBase {
        
        private var statements: CodeBlockItemListSyntax
        
        public static var recipes: [RecipeProtocol.Type]? {[
            SDL2.self
        ]}
        
        public var xc_frameworks: [String]?
        
        
        
        init() {
            statements = .init([])
            
            for recipe_type in Self.recipes! {
               //let  xc.create(ctx: .shared, platforms: [])
            }
        }
    }
    
}

extension SwiftPackageExporter.PackageBase: Sequence {
    public typealias Element = CodeBlockItemListSyntax.Element
    public typealias Iterator = CodeBlockItemListSyntax.Iterator
    
    public func makeIterator() -> CodeBlockItemListSyntax.Iterator {
        statements.makeIterator()
    }
    
    
}
