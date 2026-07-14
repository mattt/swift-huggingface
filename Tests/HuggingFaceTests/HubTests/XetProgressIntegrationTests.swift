#if HUGGINGFACE_ENABLE_XET

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import Testing

@testable import HuggingFace

/// Thread safe `Progress` observation using an `NSLock`.
///
/// Note: A more modern version would be to use a Swift Syncronization Mutex, however that would prevent this test from running on macOS 13 & 14 as it is only avialable starting in macOS 15.
private final class ProgressSnapshoter: NSObject, @unchecked Sendable {
    private let lock = NSLock()
    private var observation: NSKeyValueObservation?
    private var _completed: [Int64] = []
    
    var completed: [Int64] {
        lock.lock()
        defer { lock.unlock() }
        return _completed
    }

    func observe(progress: Progress) {
        observation = progress.observe(\.completedUnitCount) { [weak self] progress, _ in
            self?.record(progress.completedUnitCount)
            print(progress.completedUnitCount)
        }
    }
    
    private func record(_ value: Int64) {
        lock.lock()
        _completed.append(value)
        lock.unlock()
    }
}


@Suite("Xet Download Progress Reporting Integration Tests", .serialized)
struct XetProgressIntegrationTests {
    private static let hasToken: Bool = (ProcessInfo.processInfo.environment["HF_TOKEN"]?.isEmpty == false)

    @Test("Xet download reports progress incrementally", .enabled(if: hasToken))
    func xetDownloadReportsIncrementalProgress() async throws {
        let cacheDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("xet-progress-test-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        let client = HubClient(
            host: URL(string: "https://huggingface.co")!,
            cache: HubCache(cacheDirectory: cacheDirectory)
        )

        // Use bart-large and download the 1.02 GB pytorch_model.bin. We want something over the 16mb Xet threashold.
        let repoID: Repo.ID = "facebook/bart-large"
        let filePath = "pytorch_model.bin"

        let progress = Progress(totalUnitCount: 0)
        let snapshoter = ProgressSnapshoter()
        snapshoter.observe(progress: progress)

        let destination = try await client.downloadFile(
            at: filePath,
            from: repoID,
            to: cacheDirectory,
            progress: progress,
            transport: .xet
        )
        defer { try? FileManager.default.removeItem(at: destination) }

        // Make sure we have actually downloaded something.
        let fileSize = try FileManager.default.attributesOfItem(atPath: destination.path)[.size] as? Int64
        #expect(fileSize != nil)
        
        // 16 mb is the Xet starting amount, so make sure we are over that.
        #expect((fileSize ?? 0) > 16 * 1024 * 1024)

        let completedValues = snapshoter.completed
        #expect(
            completedValues.count > 5,
            "expected multiple progress snapshots, got \(completedValues.count)"
        )

        for (previous, current) in zip(completedValues, completedValues.dropFirst()) {
            #expect(current >= previous, "completedUnitCount must not decrease over time")
        }

        #expect(progress.totalUnitCount > 0)
        #expect(progress.completedUnitCount == progress.totalUnitCount)
    }
}

#endif
