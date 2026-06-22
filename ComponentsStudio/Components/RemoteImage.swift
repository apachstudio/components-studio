import SwiftUI
import UIKit

/// Tiny in-memory image cache shared across bubbles + cards, so the cloud
/// (which re-renders every frame for breathing) never re-fetches and the hero /
/// card photos appear instantly once loaded.
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? { cache.object(forKey: url as NSURL) }
    func insert(_ image: UIImage, for url: URL) { cache.setObject(image, forKey: url as NSURL) }
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    func load(_ url: URL?) async {
        guard let url else { return }
        if let cached = ImageCache.shared.image(for: url) {
            image = cached
            return
        }
        if let primary = try? await fetchValidImage(from: url) {
            ImageCache.shared.insert(primary, for: url)
            image = primary
            return
        }
        // Primary failed — fall back to a guaranteed-working source so
        // no card ever ends up empty. We seed Picsum with the original
        // URL's hash so the SAME failing URL deterministically maps to
        // the same fallback photo across renders.
        if let fallback = picsumFallback(for: url),
           let img = try? await fetchValidImage(from: fallback) {
            // Cache under the ORIGINAL key so the fallback is reused
            // on every subsequent render of this Place.
            ImageCache.shared.insert(img, for: url)
            image = img
        }
    }

    /// Fetches `url` and returns the decoded image only when both the
    /// HTTP status is 2xx and the bytes decode to a `UIImage`. Anything
    /// else (4xx, 5xx, decode failure, network error) throws so the
    /// caller can fall back.
    private func fetchValidImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        guard let img = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return img
    }

    /// Deterministic Picsum fallback for a primary URL. Same input URL
    /// → same fallback photo (so a 404'd card doesn't shuffle its
    /// fallback every render). Picsum's free API serves real landscape
    /// photos at the requested size with zero auth.
    private func picsumFallback(for url: URL) -> URL? {
        let seed = abs(url.absoluteString.hashValue)
        return URL(string: "https://picsum.photos/seed/places-\(seed)/1200/1600")
    }
}

/// A cached remote image that fills its proposed frame without ever
/// dictating its own size. The photo lives in an `.overlay` over a
/// flexible `Color.clear`, so layout-driving modifiers on callers
/// (`.aspectRatio`, `.frame`) always win — otherwise a freshly-loaded
/// `Image.resizable().scaledToFill()` brings its pixel-intrinsic size
/// to the layout and, inside a vertical ScrollView with infinite
/// proposed height, inflates the parent to the photo's full size
/// (the "search-result card explodes to full-bleed when image loads"
/// bug). `.clipped()` keeps `scaledToFill`'s overflow inside the
/// frame; callers still own the shape clip for rounded corners.
struct RemoteImage: View {
    let url: URL?
    @StateObject private var loader = ImageLoader()

    var body: some View {
        Color.clear
            .overlay {
                if let img = loader.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Aurora.cardInk
                }
            }
            .clipped()
            .task(id: url) { await loader.load(url) }
    }
}
