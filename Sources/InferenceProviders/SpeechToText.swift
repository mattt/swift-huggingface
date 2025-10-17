import Foundation

/// Speech-to-text transcription task namespace.
public enum SpeechToText {

    /// A speech-to-text transcription response.
    ///
    /// This represents the response from a speech-to-text request,
    /// containing the transcribed text and metadata.
    public struct Response: Codable, Sendable {
        /// The transcribed text.
        public let text: String

        /// Additional metadata about the transcription.
        public let metadata: [String: Value]?
    }

    /// The task type for speech-to-text transcription.
    public enum TranscriptionTask: String, CaseIterable, Hashable, Codable, Sendable {
        /// Transcribe the audio (default).
        case transcribe = "transcribe"

        /// Translate the audio to English.
        case translate = "translate"
    }
}

// MARK: -

extension InferenceClient {
    /// Transcribes audio to text using the Inference Providers API.
    ///
    /// - Parameters:
    ///   - model: The model to use for transcription.
    ///   - audio: The audio data as a base64-encoded string.
    ///   - provider: The provider to use for transcription.
    ///   - language: The language of the audio (ISO 639-1 code).
    ///   - task: The task type for transcription.
    ///   - returnTimestamps: The return timestamps setting.
    ///   - chunkLength: The chunk length for processing.
    ///   - strideLength: The stride length for processing.
    ///   - parameters: Additional parameters for the transcription.
    /// - Returns: A speech-to-text transcription result.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func speechToText(
        model: String,
        audio: String,
        provider: Provider? = nil,
        language: String? = nil,
        task: SpeechToText.TranscriptionTask? = nil,
        returnTimestamps: Bool? = nil,
        chunkLength: Int? = nil,
        strideLength: Int? = nil,
        parameters: [String: Value]? = nil
    ) async throws -> SpeechToText.Response {
        var params: [String: Value] = [
            "model": .string(model),
            "audio": .string(audio),
        ]

        if let provider = provider {
            params["provider"] = .string(provider.identifier)
        }
        if let language = language {
            params["language"] = .string(language)
        }
        if let task = task {
            params["task"] = .string(task.rawValue)
        }
        if let returnTimestamps = returnTimestamps {
            params["return_timestamps"] = .bool(returnTimestamps)
        }
        if let chunkLength = chunkLength {
            params["chunk_length"] = .int(chunkLength)
        }
        if let strideLength = strideLength {
            params["stride_length"] = .int(strideLength)
        }
        if let parameters = parameters {
            params["parameters"] = .object(parameters)
        }

        return try await fetch(.post, "/v1/audio/transcriptions", params: params)
    }
}
