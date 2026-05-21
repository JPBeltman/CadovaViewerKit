import Foundation
import AppKit

public enum Viewer {
    public enum Error: Swift.Error, LocalizedError {
        case viewerNotInstalled
        case launchFailed(any Swift.Error)
        case connectionInvalidated
        case openFailed(String)

        public var errorDescription: String? {
            switch self {
            case .viewerNotInstalled:
                "Cadova Viewer is not installed."
            case .launchFailed(let error):
                "Failed to launch Cadova Viewer: \(error.localizedDescription)"
            case .connectionInvalidated:
                "The connection to Cadova Viewer was invalidated."
            case .openFailed(let message):
                "Cadova Viewer rejected the model: \(message)"
            }
        }
    }

    public static func open(_ data: Data, named name: String) async throws {
        try await ensureViewerRunning()

        let connection = NSXPCConnection(machServiceName: CadovaPreview.machServiceName, options: [])
        connection.remoteObjectInterface = CadovaPreview.xpcInterface
        connection.resume()
        defer { connection.invalidate() }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Swift.Error>) in
            let state = ContinuationState(continuation: continuation)

            connection.interruptionHandler = { state.resume(throwing: Error.connectionInvalidated) }
            connection.invalidationHandler = { state.resume(throwing: Error.connectionInvalidated) }

            let proxy = connection.remoteObjectProxyWithErrorHandler { error in
                state.resume(throwing: error)
            } as? CadovaPreviewService

            guard let proxy else {
                state.resume(throwing: Error.connectionInvalidated)
                return
            }

            proxy.openModel(named: name, threeMFData: data) { success, message in
                if success {
                    state.resume(returning: ())
                } else {
                    state.resume(throwing: Error.openFailed(message ?? "unknown error"))
                }
            }
        }
    }

    private static func ensureViewerRunning() async throws {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: CadovaPreview.viewerBundleIdentifier) else {
            throw Error.viewerNotInstalled
        }

        let alreadyRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == CadovaPreview.viewerBundleIdentifier
        }
        guard alreadyRunning == false else { return }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        configuration.addsToRecentItems = false

        do {
            _ = try await NSWorkspace.shared.openApplication(at: appURL, configuration: configuration)
        } catch {
            throw Error.launchFailed(error)
        }

        // The Mach service is published shortly after launch. Give it a moment to register.
        try? await Task.sleep(for: .milliseconds(300))
    }
}

private final class ContinuationState: @unchecked Sendable {
    private let lock = NSLock()
    private var resumed = false
    private let continuation: CheckedContinuation<Void, any Swift.Error>

    init(continuation: CheckedContinuation<Void, any Swift.Error>) {
        self.continuation = continuation
    }

    func resume(returning value: Void) {
        lock.lock()
        let shouldResume = !resumed
        resumed = true
        lock.unlock()
        if shouldResume { continuation.resume(returning: value) }
    }

    func resume(throwing error: any Swift.Error) {
        lock.lock()
        let shouldResume = !resumed
        resumed = true
        lock.unlock()
        if shouldResume { continuation.resume(throwing: error) }
    }
}

public extension Data {
    func preview(named name: String) async throws {
        try await Viewer.open(self, named: name)
    }
}
