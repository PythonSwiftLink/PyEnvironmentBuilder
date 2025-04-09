//
//  File.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 07/12/2024.
//

import Foundation

public enum RecipeError: Error {
    case missingPlatform(any RecipeProtocol)
}
