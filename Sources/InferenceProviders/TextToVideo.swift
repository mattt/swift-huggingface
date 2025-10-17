import Foundation

/// Text-to-video generation task namespace.
public enum TextToVideo {

    /// A text-to-video generation response.
    ///
    /// This represents the response from a text-to-video generation request,
    /// containing the generated video data and metadata.
    public struct Response: Codable, Sendable {
        /// The generated video data.
        public let video: Data

        /// The MIME type of the generated video.
        public let mimeType: String?

        /// Additional metadata about the generation.
        public let metadata: [String: Value]?
    }
}

// MARK: -

extension InferenceClient {
    /// Generates a video from text using the Inference Providers API.
    ///
    /// - Parameters:
    ///   - model: The model to use for video generation.
    ///   - prompt: The text prompt for video generation.
    ///   - provider: The provider to use for video generation.
    ///   - negativePrompt: The negative prompt to avoid certain elements.
    ///   - width: The width of the generated video.
    ///   - height: The height of the generated video.
    ///   - numFrames: The number of frames in the generated video.
    ///   - frameRate: The frame rate of the generated video.
    ///   - numVideos: The number of videos to generate.
    ///   - guidanceScale: The guidance scale for generation.
    ///   - numInferenceSteps: The number of inference steps.
    ///   - seed: The seed for reproducible generation.
    ///   - safetyChecker: The safety checker setting.
    ///   - enhancePrompt: The enhance prompt setting.
    ///   - duration: The duration of the video in seconds.
    ///   - motionStrength: The motion strength for video generation.
    /// - Returns: A text-to-video generation result.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func textToVideo(
        model: String,
        prompt: String,
        provider: Provider? = nil,
        negativePrompt: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        numFrames: Int? = nil,
        frameRate: Int? = nil,
        numVideos: Int? = nil,
        guidanceScale: Double? = nil,
        numInferenceSteps: Int? = nil,
        seed: Int? = nil,
        safetyChecker: Bool? = nil,
        enhancePrompt: Bool? = nil,
        duration: Double? = nil,
        motionStrength: Double? = nil
    ) async throws -> TextToVideo.Response {
        var params: [String: Value] = [
            "model": .string(model),
            "prompt": .string(prompt),
        ]

        if let provider = provider {
            params["provider"] = .string(provider.identifier)
        }
        if let negativePrompt = negativePrompt {
            params["negative_prompt"] = .string(negativePrompt)
        }
        if let width = width {
            params["width"] = .int(width)
        }
        if let height = height {
            params["height"] = .int(height)
        }
        if let numFrames = numFrames {
            params["num_frames"] = .int(numFrames)
        }
        if let frameRate = frameRate {
            params["frame_rate"] = .int(frameRate)
        }
        if let numVideos = numVideos {
            params["num_videos"] = .int(numVideos)
        }
        if let guidanceScale = guidanceScale {
            params["guidance_scale"] = .double(guidanceScale)
        }
        if let numInferenceSteps = numInferenceSteps {
            params["num_inference_steps"] = .int(numInferenceSteps)
        }
        if let seed = seed {
            params["seed"] = .int(seed)
        }
        if let safetyChecker = safetyChecker {
            params["safety_checker"] = .bool(safetyChecker)
        }
        if let enhancePrompt = enhancePrompt {
            params["enhance_prompt"] = .bool(enhancePrompt)
        }
        if let duration = duration {
            params["duration"] = .double(duration)
        }
        if let motionStrength = motionStrength {
            params["motion_strength"] = .double(motionStrength)
        }

        return try await fetch(.post, "/v1/videos/generations", params: params)
    }
}

// MARK: - Codable

extension TextToVideo.Response {
    private enum CodingKeys: String, CodingKey {
        case video
        case mimeType = "mime_type"
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the base64-encoded video string and convert to Data
        let videoString = try container.decode(String.self, forKey: .video)
        guard let videoData = Data(base64Encoded: videoString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .video,
                in: container,
                debugDescription: "Invalid base64-encoded video data"
            )
        }

        self.video = videoData
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        self.metadata = try container.decodeIfPresent([String: Value].self, forKey: .metadata)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(video.base64EncodedString(), forKey: .video)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}
