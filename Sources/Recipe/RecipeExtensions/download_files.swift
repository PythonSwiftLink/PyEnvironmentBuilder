//
//  download_files.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 11/12/2024.
//

import Foundation
import PathKit
import PyEnvironmentBuilder


public extension RecipeProtocol {
    
    func download_files() async throws {
        for download in self.downloads {
            let dst = context.cache_dir + download.lastPathComponent
            if dst.exists {
                if try! dst.read().isEmpty { try! dst.delete()}
                else { continue }
            }
            let request = URLRequest(url: download)
            let _result = try await URLSession.shared.download(for: request).0
            let result = _result.asPath
                
                print("moving:\n\tfrom: \(result)\n\tto: \(dst)")
                try! result.move(dst)
            
        }
    }
}
