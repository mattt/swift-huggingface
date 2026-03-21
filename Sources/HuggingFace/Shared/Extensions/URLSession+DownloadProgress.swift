import Foundation

#if !canImport(FoundationNetworking)
    private final class DownloadTaskHandle: @unchecked Sendable {
        private let lock = NSLock()
        private var task: URLSessionTask?
        private var isCancelled = false

        func setTask(_ task: URLSessionTask) {
            lock.lock()
            self.task = task
            let shouldCancel = isCancelled
            lock.unlock()

            if shouldCancel {
                task.cancel()
            }
        }

        func cancel() {
            lock.lock()
            isCancelled = true
            let task = task
            lock.unlock()
            task?.cancel()
        }

        func clear() {
            lock.lock()
            task = nil
            lock.unlock()
        }
    }

    extension URLSession {
        /// Downloads a file from a URL to a temporary location while updating progress.
        ///
        /// This uses a dedicated delegate-backed session so progress comes from
        /// `URLSessionDownloadDelegate.urlSession(_:downloadTask:didWriteData:...)`
        /// instead of `task.progress`, which is not reliable for this code path.
        func asyncDownloadWithProgress(
            for request: URLRequest,
            progress: Progress? = nil,
            resumeOffset: Int64 = 0
        ) async throws -> (URL, URLResponse) {
            let taskHandle = DownloadTaskHandle()

            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    let delegate = DownloadProgressDelegate(
                        progress: progress,
                        resumeOffset: resumeOffset,
                        continuation: continuation,
                        taskHandle: taskHandle
                    )

                    let session = URLSession(
                        configuration: self.configuration,
                        delegate: delegate,
                        delegateQueue: nil
                    )
                    let task = session.downloadTask(with: request)
                    taskHandle.setTask(task)

                    if Task.isCancelled {
                        taskHandle.cancel()
                    }

                    task.resume()
                }
            } onCancel: {
                taskHandle.cancel()
            }
        }

        /// Downloads a file from a resume payload while updating progress.
        func asyncResumeDownloadWithProgress(
            resumeData: Data,
            progress: Progress? = nil
        ) async throws -> (URL, URLResponse) {
            let taskHandle = DownloadTaskHandle()

            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    let delegate = DownloadProgressDelegate(
                        progress: progress,
                        resumeOffset: 0,
                        continuation: continuation,
                        taskHandle: taskHandle
                    )

                    let session = URLSession(
                        configuration: self.configuration,
                        delegate: delegate,
                        delegateQueue: nil
                    )
                    let task = session.downloadTask(withResumeData: resumeData)
                    taskHandle.setTask(task)

                    if Task.isCancelled {
                        taskHandle.cancel()
                    }

                    task.resume()
                }
            } onCancel: {
                taskHandle.cancel()
            }
        }
    }

    private final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
        private let progress: Progress?
        private let resumeOffset: Int64
        private let continuation: CheckedContinuation<(URL, URLResponse), Error>
        private let taskHandle: DownloadTaskHandle
        private var didResume = false

        init(
            progress: Progress?,
            resumeOffset: Int64,
            continuation: CheckedContinuation<(URL, URLResponse), Error>,
            taskHandle: DownloadTaskHandle
        ) {
            self.progress = progress
            self.resumeOffset = resumeOffset
            self.continuation = continuation
            self.taskHandle = taskHandle
        }

        private func resumeOnce(_ result: Result<(URL, URLResponse), Error>) {
            guard !didResume else { return }
            didResume = true
            taskHandle.clear()

            switch result {
            case let .success(value):
                continuation.resume(returning: value)
            case let .failure(error):
                continuation.resume(throwing: error)
            }
        }

        private func normalizeError(_ error: Error) -> Error {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                return CancellationError()
            }
            return error
        }

        private func copyDownloadedFile(from location: URL) throws -> URL {
            let newTempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
            try FileManager.default.copyItem(at: location, to: newTempURL)
            return newTempURL
        }

        private func progressDescription() -> String {
            guard let progress else {
                return "nil"
            }
            return "\(progress.completedUnitCount)/\(progress.totalUnitCount)"
        }

        func urlSession(
            _: URLSession,
            downloadTask: URLSessionDownloadTask,
            didWriteData _: Int64,
            totalBytesWritten: Int64,
            totalBytesExpectedToWrite: Int64
        ) {
            let responseStatus = (downloadTask.response as? HTTPURLResponse)?.statusCode
            let appliedOffset = responseStatus == 206 ? resumeOffset : 0
            if totalBytesExpectedToWrite > 0 {
                progress?.totalUnitCount = totalBytesExpectedToWrite + appliedOffset
            }
            progress?.completedUnitCount = totalBytesWritten + appliedOffset
        }

        func urlSession(
            _: URLSession,
            downloadTask: URLSessionDownloadTask,
            didFinishDownloadingTo location: URL
        ) {
            guard !didResume else { return }
            do {
                guard let response = downloadTask.response else {
                    throw URLError(.badServerResponse)
                }
                let copiedURL = try copyDownloadedFile(from: location)
                resumeOnce(.success((copiedURL, response)))
            } catch {
                resumeOnce(.failure(normalizeError(error)))
            }
        }

        func urlSession(
            _: URLSession,
            task: URLSessionTask,
            didCompleteWithError error: Error?
        ) {
            guard !didResume else { return }
            if let error {
                resumeOnce(.failure(normalizeError(error)))
            }
        }
    }
#endif
