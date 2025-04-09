//
//  File.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 07/12/2024.
//

import Foundation
import PathKit


public extension Path {
    static var lipo: Self { "/usr/bin/lipo" }
    
    static var systemPython: Self { "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3.11" }
}
