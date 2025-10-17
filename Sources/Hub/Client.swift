import Foundation
import EventSource

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A Hugging Face Hub API client.
///
/// This client provides methods to interact with the Hugging Face Hub API,
/// allowing you to list and retrieve information about models, datasets, and spaces,
/// as well as manage repositories.
///
/// The client automatically detects authentication tokens from standard locations (in order of priority):
/// - `HF_TOKEN` environment variable
/// - `HUGGING_FACE_HUB_TOKEN` environment variable
/// - `HF_TOKEN_PATH` environment variable (path to token file)
/// - `HF_HOME/token` file
/// - `~/.cache/huggingface/token` file (standard HF CLI location)
/// - `~/.huggingface/token` file (fallback location)
///
/// The endpoint can be customized via the `HF_ENDPOINT` environment variable.
///
/// - SeeAlso: [Hub API Documentation](https://huggingface.co/docs/hub/api)
public final class Client: Sendable {
    /// The default host URL for the Hugging Face Hub API.
    public static let defaultHost = URL(string: "https://huggingface.co")!

    /// A default client instance with auto-detected host and bearer token.
    ///
    /// This client automatically detects the authentication token from environment variables
    /// or standard token file locations, and uses the endpoint specified by `HF_ENDPOINT`
    /// environment variable (defaults to https://huggingface.co).
    public static let `default` = Client()

    /// The host URL for requests made by the client.
    public let host: URL

    /// The value for the `User-Agent` header sent in requests, if any.
    public let userAgent: String?

    /// The Bearer token for authentication, if any.
    public let bearerToken: String?

    /// The underlying client session.
    private let session: URLSession

    /// A shared JSON decoder with consistent configuration.
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return decoder
    }()

    /// Creates a client with auto-detected host and bearer token.
    ///
    /// This initializer automatically detects the authentication token from standard locations
    /// and uses the endpoint specified by the `HF_ENDPOINT` environment variable.
    ///
    /// - Parameters:
    ///   - session: The underlying client session. Defaults to `URLSession(configuration: .default)`.
    ///   - userAgent: The value for the `User-Agent` header sent in requests, if any. Defaults to `nil`.
    public convenience init(
        session: URLSession = URLSession(configuration: .default),
        userAgent: String? = nil
    ) {
        self.init(
            session: session,
            host: Self.detectHost(),
            userAgent: userAgent,
            bearerToken: Self.detectToken()
        )
    }

    /// Creates a client with the specified session, host, user agent, and authentication token.
    ///
    /// - Parameters:
    ///   - session: The underlying client session. Defaults to `URLSession(configuration: .default)`.
    ///   - host: The host URL to use for requests.
    ///   - userAgent: The value for the `User-Agent` header sent in requests, if any. Defaults to `nil`.
    ///   - bearerToken: The Bearer token for authentication, if any. Defaults to `nil`.
    public init(
        session: URLSession = URLSession(configuration: .default),
        host: URL,
        userAgent: String? = nil,
        bearerToken: String? = nil
    ) {
        var host = host
        if !host.path.hasSuffix("/") {
            host = host.appendingPathComponent("")
        }

        self.host = host
        self.userAgent = userAgent
        self.bearerToken = bearerToken
        self.session = session
    }

    // MARK: - Auto-detection

    /// Detects the Hugging Face Hub endpoint from environment variables.
    ///
    /// Checks the `HF_ENDPOINT` environment variable, defaulting to https://huggingface.co.
    ///
    /// - Returns: The detected or default endpoint URL.
    private static func detectHost() -> URL {
        if let endpoint = ProcessInfo.processInfo.environment["HF_ENDPOINT"],
            let url = URL(string: endpoint)
        {
            return url
        }
        return defaultHost
    }

    /// Detects the Hugging Face authentication token from standard locations.
    ///
    /// This method checks multiple sources in priority order:
    /// 1. `HF_TOKEN` environment variable
    /// 2. `HUGGING_FACE_HUB_TOKEN` environment variable
    /// 3. File at path specified by `HF_TOKEN_PATH` environment variable
    /// 4. File at `$HF_HOME/token`
    /// 5. File at `~/.cache/huggingface/token` (standard HF CLI location)
    /// 6. File at `~/.huggingface/token` (fallback location)
    ///
    /// - Returns: The detected token, or `nil` if no token is found.
    private static func detectToken() -> String? {
        let tokenSources: [() -> String?] = [
            { ProcessInfo.processInfo.environment["HF_TOKEN"] },
            { ProcessInfo.processInfo.environment["HUGGING_FACE_HUB_TOKEN"] },
            {
                if let tokenPath = ProcessInfo.processInfo.environment["HF_TOKEN_PATH"] {
                    return Self.readTokenFromPath(tokenPath)
                }
                return nil
            },
            {
                if let hfHome = ProcessInfo.processInfo.environment["HF_HOME"] {
                    let expandedPath = NSString(string: hfHome).expandingTildeInPath
                    return Self.readTokenFromPath("\(expandedPath)/token")
                }
                return nil
            },
            { Self.readTokenFromPath("~/.cache/huggingface/token") },
            { Self.readTokenFromPath("~/.huggingface/token") },
        ]

        return tokenSources
            .lazy
            .compactMap { $0() }
            .first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Reads a token from the specified file path.
    ///
    /// - Parameter path: The file path (may include tilde for home directory).
    /// - Returns: The token string, or `nil` if the file doesn't exist or can't be read.
    private static func readTokenFromPath(_ path: String) -> String? {
        let expandedPath = NSString(string: path).expandingTildeInPath
        return try? String(contentsOfFile: expandedPath, encoding: .utf8)
    }

    /// Represents errors that can occur during API operations.
    public enum ClientError: Swift.Error, CustomStringConvertible {
        /// An error encountered while constructing the request.
        case requestError(String)

        /// An error returned by the Hub HTTP API.
        case responseError(response: HTTPURLResponse, detail: String)

        /// An error encountered while decoding the response.
        case decodingError(response: HTTPURLResponse, detail: String)

        /// An unexpected error.
        case unexpectedError(String)

        // MARK: CustomStringConvertible

        public var description: String {
            switch self {
            case .requestError(let detail):
                return "Request error: \(detail)"
            case .responseError(let response, let detail):
                return "Response error (Status \(response.statusCode)): \(detail)"
            case .decodingError(let response, let detail):
                return "Decoding error (Status \(response.statusCode)): \(detail)"
            case .unexpectedError(let detail):
                return "Unexpected error: \(detail)"
            }
        }
    }

    private struct ClientErrorResponse: Decodable {
        let error: String
    }

    enum Method: String, Hashable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    func fetch<T: Decodable>(
        _ method: Method,
        _ path: String,
        params: [String: Value]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let request = try createRequest(method, path, params: params, headers: headers)
        let (data, response) = try await session.data(for: request)
        let httpResponse = try validateResponse(response, data: data)

        if T.self == Bool.self {
            // If T is Bool, we return true for successful response
            return true as! T
        } else if data.isEmpty {
            throw ClientError.responseError(response: httpResponse, detail: "Empty response body")
        } else {
            do {
                return try jsonDecoder.decode(T.self, from: data)
            } catch {
                throw ClientError.decodingError(
                    response: httpResponse,
                    detail: "ClientError decoding response: \(error.localizedDescription)"
                )
            }
        }
    }

    func fetchPaginated<T: Decodable>(
        _ method: Method,
        _ path: String,
        params: [String: Value]? = nil,
        headers: [String: String]? = nil
    ) async throws -> PaginatedResponse<T> {
        let request = try createRequest(method, path, params: params, headers: headers)
        let (data, response) = try await session.data(for: request)
        let httpResponse = try validateResponse(response, data: data)

        do {
            let items = try jsonDecoder.decode([T].self, from: data)
            let nextURL = httpResponse.nextPageURL()
            return PaginatedResponse(items: items, nextURL: nextURL)
        } catch {
            throw ClientError.decodingError(
                response: httpResponse,
                detail: "ClientError decoding response: \(error.localizedDescription)"
            )
        }
    }

    func fetchStream<T: Decodable & Sendable>(
        _ method: Method,
        _ path: String,
        params: [String: Value]? = nil,
        headers: [String: String]? = nil
    ) -> AsyncThrowingStream<T, Swift.Error> {
        AsyncThrowingStream { @Sendable continuation in
            let task = Task {
                do {
                    let request = try createRequest(method, path, params: params, headers: headers)
                    let (bytes, response) = try await session.bytes(for: request)
                    let httpResponse = try validateResponse(response)

                    guard (200 ..< 300).contains(httpResponse.statusCode) else {
                        var errorData = Data()
                        for try await byte in bytes {
                            errorData.append(byte)
                        }
                        // validateResponse will throw the appropriate error
                        _ = try validateResponse(response, data: errorData)
                        return  // This line will never be reached, but satisfies the compiler
                    }

                    for try await event in bytes.events {
                        // Check for [DONE] signal
                        if event.data.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                            continuation.finish()
                            return
                        }

                        guard let jsonData = event.data.data(using: .utf8) else {
                            continue
                        }

                        do {
                            let decoded = try jsonDecoder.decode(T.self, from: jsonData)
                            continuation.yield(decoded)
                        } catch {
                            // Log decoding errors but don't fail the stream
                            // This allows the stream to continue even if individual chunks fail
                            print("Warning: Failed to decode streaming response chunk: \(error)")
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func fetchData(
        _ method: Method,
        _ path: String,
        params: [String: Value]? = nil,
        headers: [String: String]? = nil
    ) async throws -> Data {
        let request = try createRequest(method, path, params: params, headers: headers)
        let (data, response) = try await session.data(for: request)
        let _ = try validateResponse(response, data: data)

        return data
    }

    private func createRequest(
        _ method: Method,
        _ path: String,
        params: [String: Value]? = nil,
        headers: [String: String]? = nil
    ) throws -> URLRequest {
        var urlComponents = URLComponents(url: host, resolvingAgainstBaseURL: true)
        urlComponents?.path = path

        var httpBody: Data? = nil
        switch method {
        case .get:
            if let params {
                var queryItems: [URLQueryItem] = []
                for (key, value) in params {
                    queryItems.append(URLQueryItem(name: key, value: value.description))
                }
                urlComponents?.queryItems = queryItems
            }
        case .post, .put, .delete, .patch:
            if let params {
                let encoder = JSONEncoder()
                // Special-case: allow sending a top-level JSON value (e.g., array)
                // by passing a single empty-string key.
                // This is used for endpoints that require an array body instead of an object.
                if params.count == 1, let sole = params.first, sole.key == "" {
                    httpBody = try encoder.encode(sole.value)
                } else {
                    httpBody = try encoder.encode(params)
                }
            }
        }

        guard let url = urlComponents?.url else {
            throw ClientError.requestError(
                #"Unable to construct URL with host "\#(host)" and path "\#(path)""#
            )
        }
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let userAgent {
            request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        if let bearerToken {
            request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        if let httpBody {
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Add custom headers
        if let headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }

    private func validateResponse(_ response: URLResponse, data: Data? = nil) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.unexpectedError("Invalid response from server: \(response)")
        }

        // If we have data and it's an error status, parse and throw the error
        if let data = data, !(200 ..< 300).contains(httpResponse.statusCode) {
            if let errorDetail = try? jsonDecoder.decode(ClientErrorResponse.self, from: data) {
                throw ClientError.responseError(response: httpResponse, detail: errorDetail.error)
            }

            if let string = String(data: data, encoding: .utf8) {
                throw ClientError.responseError(response: httpResponse, detail: string)
            }

            throw ClientError.responseError(response: httpResponse, detail: "Invalid response")
        }

        return httpResponse
    }
}
