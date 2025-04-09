
import Foundation
import PyEnvironmentBuilder
import Recipes
import Recipe
import PathKit

let currentEnvironment = ProcessInfo.processInfo.environment

//print(Process.which("cython") ?? "cython not found")
print(currentEnvironment)

let context = try Context(root_dir: .current)

func reset_environment(_ state: Bool) {
    if state {
        try? context.build_dir.delete()
        try? context.dist_dir.delete()
    }
}

reset_environment(false)

try context.ensure_dirs()

let platforms: [any GenericPlatform] = await [
    Platforms.iPhoneOSARM64(ctx: context),
//    Platforms.iPhoneSimulatorARM64(ctx: context),
//    Platforms.iPhoneSimulatorx86_64(ctx: context),
//    Platforms.macOSx86_64(ctx: context),
//    Platforms.macOSARM64(ctx: context)
]

for platform in platforms {
    let libs = platform.libs_dir
    
        if libs.exists { continue }
    print(libs)
        try libs.mkpath()
    
}


//let recipes = Recipes.all_recipes.map({$0.create(ctx: context, platforms: platforms)})

// build_phase

for recipe_type in Recipes.all_recipes {
    
    let recipe = recipe_type.create(ctx: context, platforms: platforms)
    
    let build_libraries = recipe.all_platform_libraries()
    
    if !build_libraries.allSatisfy(\.exists) {
        try await recipe.execute()
        
//        if recipe.name == "pillow" {
//            continue
//        }
        try! recipe.lipoize_libraries()
        
    }
    
    for platform in recipe.supported_platforms {
        //if recipe.exclude_sdks_in_xcframework()?.contains(platform.sdk) ?? false { continue }
        let lib = recipe.get_library(platform)
        let build_library = lib
        print(lib)
        assert(build_library.exists, "\(build_library) dont exist")
    }
    
    recipe.create_xcframeworks()
    
    
}


//for recipe in recipes {
//    
//    
//    
//    for platform in platforms {
//    
//   
//        
//        let recipe_library = recipe.library
//        
//        let library_exists = recipe_library.exists
//        
//        if !library_exists {
//            try await recipe.execute()
//        }
//        
//        assert(recipe_library.exists, "\(recipe_library) dont exist")
//        
//        let recipe_dest = platform.libs_dir + recipe_library.lastComponent
//        
//        if recipe_dest.exists { try! recipe_dest.delete() }
//        //try? recipe_library.copy(
//            //platform.libs_dir + recipe_library.lastComponent
//        //)
//        
//        // copy includes
//        //try recipe.install_include()
//        try recipe.install_include(common: false)
//        
////        Path.current = last_path
//    }
//    
//    let lipos = platforms.reduce(into: [Platforms.SDK:[(Platforms.Arch,Path)]]()) { partialResult, next in
//        recipe.platform = next
//        if next.sdk == .iphoneos {
//            partialResult[next.sdk] = [(next.arch, recipe.library)]
//            return
//        }
//        
//        if partialResult.contains(where: {$0.key == next.sdk}) {
//            partialResult[next.sdk]?.append((next.arch,recipe.library))
//        } else {
//            partialResult[next.sdk] = [(next.arch,recipe.library)]
//        }
//    }
//    for (sdk, arch_libs) in lipos {
//        let dest = context.dist_dir + "lib/\(sdk)/\(recipe.library.lastComponent)"
//        switch sdk {
//        case .iphoneos:
//            try recipe.library.copy(dest)
//        case .iphonesimulator:
//            try recipe.lipo(output: dest, libs: arch_libs)
//            
//        case .macosx:
//            try recipe.lipo(output: dest, libs: arch_libs)
//        }
//    }
//    
//    
//}
//
//
