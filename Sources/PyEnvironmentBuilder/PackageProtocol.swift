//
//  File.swift
//  
//
//  Created by CodeBuilder on 06/10/2024.
//

import Foundation
import PathKit

extension URL: ExpressibleByStringLiteral  {
	public typealias StringLiteralType = String
	
	public init(stringLiteral value: String) {
		self = .init(string: value)!
	}
	
	
}


public protocol PackageProtocol {
	var urls: [Path] { get }
	
	//var CC: String? { get }
	var env: RecipeEnv.Environment? { get set }
	
}


