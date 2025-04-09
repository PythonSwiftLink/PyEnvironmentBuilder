//
//  File.swift
//  PyEnvironmentBuilder
//
//  Created by CodeBuilder on 03/12/2024.
//

import Foundation
import PathKit



public protocol BuildCommand {
    var cmd: Path? { get }
    var args: [String] { get }
    var environment: [String: String]? { get }
    func run() async throws
}

public protocol PreBuildCommand {
    var cmd: Path? { get }
    var args: [String] { get }
    var environment: [String: String]? { get }
    func run() async throws
}

extension BuildCommand {
    public func run() async throws {
        let proc = Process()
        //proc.executableURL = .init(filePath: "/bin/zsh")
        var args = args
        if let cmd {
            //args.insert(cmd.string, at: 0)
            proc.executableURL = cmd.url
        }
        print("BuildCommand:\n\t\( args.joined(separator: " ") )\n\n")
        proc.arguments = args
        if let environment {
            //proc.environment = environment
        }
        guard cmd!.exists else { fatalError() }
        try! proc.run()
        proc.waitUntilExit()
        
    }
}


class BaseBuildCommand: BuildCommand {
    var cmd: PathKit.Path?
    
    var args: [String]
    
    var environment: [String: String]?
    
    
    init(cmd: PathKit.Path, args: [String], environment: [String:String]?) {
        self.cmd = cmd
        self.args = args
        self.environment = environment
    }
    
}

public class XcodeBuildCommand: BuildCommand {
    public var cmd: PathKit.Path? = .xcodebuild
    public var args: [String] = []
    public var __args: [String] {
        [
            context.concurrent_xcodebuild,
            "ONLY_ACTIVE_ARCH=NO",
            "ARCHS=\(arch)",
            //"CC=\(platform.temp)",
            "-sdk", sdk.rawValue,
            "-project", "\(project)",
            "-target", platform.sdk == .macosx ? "Static Library" : "Static Library-iOS",
            "-configuration", "Release"
        ]
    }
    
    public var environment: [String : String]?
    
    let context: Context
    let platform: any GenericPlatform
    let arch: Platforms.Arch
    let sdk: Platforms.SDK
    let project: Path
    let header_search_paths: String?
    let target: String
    let configuration: String
    let currentDirectory: Path?
    
    public init(
        args: [String]? = nil,
        environment: [String : String]? = nil,
        context: Context,
        platform: any GenericPlatform,
        project: Path,
        header_search_paths: String? = nil,
        target: String ,
        configuration: String = "Release",
        currentDirectory: Path? = nil
    ) {
        self.environment = environment
        self.context = context
        self.platform = platform
        self.arch = platform.arch
        self.sdk = platform.sdk
        self.project = project
        self.header_search_paths = header_search_paths
        self.target = target
        self.configuration = configuration
        self.currentDirectory = currentDirectory
    }
    
    public func run() async throws {
   
        try await Process.xcodebuild(
            concurrent: context.concurrent_xcodebuild,
            args: args.isEmpty ? nil : args,
            env: environment,
            arch: arch,
            header_search_paths: header_search_paths,
            sdk: sdk,
            project: project,
            target: target,
            currentDirectory: currentDirectory
        )
    }
}


extension BaseBuildCommand {
    public enum Executable: Path {
        case tar = ""
    }
}


public final class PatchCommand: PreBuildCommand {
    public var cmd: PathKit.Path?
    
    public var args: [String] = []
    
    public var environment: [String : String]?
    
    var target_dir: String
    
    var filename: String
    
    public init(target_dir: String, filename: String) {
        self.target_dir = target_dir
        self.filename = filename
    }
    
    public func run() async throws {
        Process.patch(target_dir: target_dir, filename: filename)
    }
    
    
}

public final class ShellBuild: BuildCommand {
    public var cmd: PathKit.Path?
    
    public var args: [String]
    
    public var environment: [String : String]?
    
    var currentDirectory: Path?
    
    public init(cmd: PathKit.Path, args: [String], environment: [String : String]? = nil, currentDirectory: Path? = nil) {
        self.cmd = cmd
        self.args = args
        self.environment = environment
        self.currentDirectory = currentDirectory
    }
    
    public func run() async throws {
        if let cmd {
            try Process.command(
                cmd,
                args: args,
                environment: environment,
                currentDirectory: currentDirectory
            )
        }
    }
}

public final class MakeCommand: BuildCommand {
    public var cmd: PathKit.Path? = nil
    
    public var args: [String]
    
    public var environment: [String : String]?
    
    var currentDirectory: Path?
    
    public init(args: [String], environment: [String : String]? = nil, currentDirectory: Path? = nil) {
        self.args = args
        self.environment = environment
        self.currentDirectory = currentDirectory
    }
    
    public func run() async throws {
        try Process.make(
            args,
            environment: environment,
            currentDirectory: currentDirectory
        )
        
    }
}
