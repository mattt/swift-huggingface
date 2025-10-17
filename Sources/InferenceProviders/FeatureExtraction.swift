import Foundation

/// Feature extraction task namespace.
public enum FeatureExtraction {

    /// A feature extraction response.
    ///
    /// This represents the response from a feature extraction request,
    /// containing the extracted embeddings or features.
    public struct Response: Codable, Sendable {
        /// The extracted embeddings as an array of floating-point numbers.
        public let embeddings: [[Double]]

        /// Additional metadata about the extraction.
        public let metadata: [String: Value]?
    }
}

// MARK: -

extension InferenceClient {
    /// Extracts features from text using the Inference Providers API.
    ///
    /// - Parameters:
    ///   - model: The model to use for feature extraction.
    ///   - inputs: The input text to extract features from.
    ///   - provider: The provider to use for feature extraction.
    ///   - normalize: The normalization setting for embeddings.
    ///   - truncate: The truncation setting.
    ///   - parameters: Additional parameters for the extraction.
    /// - Returns: A feature extraction result.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func featureExtraction(
        model: String,
        inputs: [String],
        provider: Provider? = nil,
        normalize: Bool? = nil,
        truncate: Bool? = nil,
        parameters: [String: Value]? = nil
    ) async throws -> FeatureExtraction.Response {
        var params: [String: Value] = [
            "model": .string(model),
            "inputs": try .init(inputs),
        ]

        if let provider = provider {
            params["provider"] = .string(provider.identifier)
        }
        if let normalize = normalize {
            params["normalize"] = .bool(normalize)
        }
        if let truncate = truncate {
            params["truncate"] = .bool(truncate)
        }
        if let parameters = parameters {
            params["parameters"] = .object(parameters)
        }

        return try await fetch(.post, "/v1/embeddings", params: params)
    }

    /// Convenience method for single text feature extraction.
    ///
    /// - Parameters:
    ///   - model: The model to use for feature extraction.
    ///   - input: The input text to extract features from.
    ///   - provider: The provider to use for feature extraction.
    ///   - normalize: The normalization setting for embeddings.
    ///   - truncate: The truncation setting.
    ///   - parameters: Additional parameters for the extraction.
    /// - Returns: A feature extraction result.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func featureExtraction(
        model: String,
        input: String,
        provider: Provider? = nil,
        normalize: Bool? = nil,
        truncate: Bool? = nil,
        parameters: [String: Value]? = nil
    ) async throws -> FeatureExtraction.Response {
        return try await featureExtraction(
            model: model,
            inputs: [input],
            provider: provider,
            normalize: normalize,
            truncate: truncate,
            parameters: parameters
        )
    }
}
