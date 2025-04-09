import Foundation
import PathKit
import PyEnvironmentBuilder
import Recipe


public final class FFMpeg: BaseRecipe, RecipeProtocol {
    
    public var name: String = "libffmpeg"
    
    public var version: String = "n4.4.2"
    
    public func src_name(_ platform: PyEnvironmentBuilder.AnyPlatform?) -> String {
        "ffmpeg"
    }
    
    public var library: PathKit.Path = "libavcodec/libavcodec.a"
    
    public var downloads: [URL] {[
        .init(string: "https://github.com/FFmpeg/FFmpeg/archive/\(version).zip")!
    ]}
    
    public func include_per_platform() -> Bool { true }
    
    func build_options(_ platform: any GenericPlatform) -> [String] {[
        "--disable-everything",
        "--enable-parsers",
        "--enable-decoders",
        "--enable-demuxers",
        "--enable-filter=aresample,resample,crop,scale",
        "--enable-protocol=file,http,rtmp",
        "--enable-pic",
        "--enable-small",
        "--enable-hwaccels",
        "--enable-static",
        "--disable-shared",
        // libpostproc is GPL: https://ffmpeg.org/pipermail/ffmpeg-user/2012-February/005162.html
        "--enable-gpl",
        // disable some unused algo
        // note: "golomb" are the one used in our video test, so don't use --disable-golomb
        // note: and for aac decoding: "rdft", "mdct", and "fft" are needed
        "--disable-dxva2",
        "--disable-vdpau",
        "--disable-vaapi",
        "--disable-dct",
        // disable binaries / doc
        "--enable-cross-compile",
        "--disable-debug",
        "--disable-programs",
        "--disable-doc",
        "--enable-pic",
        "--enable-avresample"
    ]}
    
    public func build_platform(_ platform: any GenericPlatform) async throws {
        
    }
    
    
}
