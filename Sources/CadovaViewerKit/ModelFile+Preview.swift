import Foundation
import Cadova

public extension ModelFile {
    /// Renders the model and opens it in Cadova Viewer in-memory.
    ///
    /// Cadova Viewer is launched if not already running. Calling `preview()` repeatedly reuses the window with the same name
    func preview() async throws {
        let data = try await data()
        try await Viewer.open(data, named: suggestedFileName)
    }
}
