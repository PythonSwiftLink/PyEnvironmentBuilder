
import Foundation
import PyEnvironmentBuilder
import Recipe
import PathKit


public struct Patches {
    public static let _patches = Bundle.module.path(forResource: "patches", ofType: nil)!
    public static let patches = Path(_patches)
    static var harfbuzz: Path { patches + "harfbuzz.patch" }
}

extension Array where Element == String {
    var whitespaced: String { joined(separator: " ") }
}

extension Array where Element == RecipeEnv.Environment.CFlag {
    var whitespaced: String { map(\.description).joined(separator: " ") }
}

extension Array where Element == RecipeEnv.Environment.LDFlag {
    var whitespaced: String { map(\.description).joined(separator: " ") }
}

public let all_recipes: [RecipeProtocol.Type] = [
    Jpeg.self,
    PNG.self,
    Freetype.self,
    
    SDL2.self,
    SDL2Image.self,
    SDL2Mixer.self,
    SDL2TTF.self,
    
    Kivy.self,
    Pillow.self,
]
