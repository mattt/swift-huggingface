import Foundation

/// Text-to-image generation task namespace.
public enum TextToImage {

    /// A text-to-image generation response.
    ///
    /// This represents the response from a text-to-image generation request,
    /// containing the generated image data and metadata.
    public struct Response: Codable, Sendable {
        /// The generated image data.
        public let image: Data

        /// The MIME type of the generated image.
        public let mimeType: String?

        /// Additional metadata about the generation.
        public let metadata: [String: Value]?

    }

    /// A LoRA (Low-Rank Adaptation) configuration for image generation.
    public struct Lora: Codable, Hashable, Sendable {
        /// The name or ID of the LoRA.
        public let name: String

        /// The strength of the LoRA (0.0 to 1.0).
        public let strength: Double

        /// Creates a LoRA configuration.
        ///
        /// - Parameters:
        ///   - name: The name or ID of the LoRA.
        ///   - strength: The strength of the LoRA.
        public init(name: String, strength: Double) {
            self.name = name
            self.strength = strength
        }
    }

    /// A ControlNet configuration for image generation.
    public struct ControlNet: Codable, Hashable, Sendable {
        /// The name or ID of the ControlNet.
        public let name: String

        /// The strength of the ControlNet (0.0 to 1.0).
        public let strength: Double

        /// The control image data.
        public let controlImage: Data?

        /// Creates a ControlNet configuration.
        ///
        /// - Parameters:
        ///   - name: The name or ID of the ControlNet.
        ///   - strength: The strength of the ControlNet.
        ///   - controlImage: The control image data.
        public init(name: String, strength: Double, controlImage: Data? = nil) {
            self.name = name
            self.strength = strength
            self.controlImage = controlImage
        }
    }
}

// MARK: -

extension InferenceClient {
    /// Generates an image from text using the Inference Providers API.
    ///
    /// - Parameters:
    ///   - model: The model to use for image generation.
    ///   - prompt: The text prompt for image generation.
    ///   - provider: The provider to use for image generation.
    ///   - negativePrompt: The negative prompt to avoid certain elements.
    ///   - width: The width of the generated image.
    ///   - height: The height of the generated image.
    ///   - numImages: The number of images to generate.
    ///   - guidanceScale: The guidance scale for generation.
    ///   - numInferenceSteps: The number of inference steps.
    ///   - seed: The seed for reproducible generation.
    ///   - safetyChecker: The safety checker setting.
    ///   - enhancePrompt: The enhance prompt setting.
    ///   - multiLingual: The multi-lingual setting.
    ///   - panorama: The panorama setting.
    ///   - selfAttention: The self-attention setting.
    ///   - upscale: The upscale setting.
    ///   - embeddingsModel: The embeddings model to use.
    ///   - loras: The loras to apply.
    ///   - controlnet: The controlnet to use.
    /// - Returns: A text-to-image generation result.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func textToImage(
        model: String,
        prompt: String,
        provider: Provider? = nil,
        negativePrompt: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        numImages: Int? = nil,
        guidanceScale: Double? = nil,
        numInferenceSteps: Int? = nil,
        seed: Int? = nil,
        safetyChecker: Bool? = nil,
        enhancePrompt: Bool? = nil,
        multiLingual: Bool? = nil,
        panorama: Bool? = nil,
        selfAttention: Bool? = nil,
        upscale: Bool? = nil,
        embeddingsModel: String? = nil,
        loras: [TextToImage.Lora]? = nil,
        controlnet: TextToImage.ControlNet? = nil
    ) async throws -> TextToImage.Response {
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
        if let numImages = numImages {
            params["num_images"] = .int(numImages)
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
        if let multiLingual = multiLingual {
            params["multi_lingual"] = .bool(multiLingual)
        }
        if let panorama = panorama {
            params["panorama"] = .bool(panorama)
        }
        if let selfAttention = selfAttention {
            params["self_attention"] = .bool(selfAttention)
        }
        if let upscale = upscale {
            params["upscale"] = .bool(upscale)
        }
        if let embeddingsModel = embeddingsModel {
            params["embeddings_model"] = .string(embeddingsModel)
        }
        if let loras = loras {
            params["loras"] = try .init(loras)
        }
        if let controlnet = controlnet {
            params["controlnet"] = try .init(controlnet)
        }

        return try await fetch(.post, "/v1/images/generations", params: params)
    }
}

// MARK: - Codable

extension TextToImage.Response {
    private enum CodingKeys: String, CodingKey {
        case image
        case mimeType = "mime_type"
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the base64-encoded image string and convert to Data
        let imageString = try container.decode(String.self, forKey: .image)
        guard let imageData = Data(base64Encoded: imageString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .image,
                in: container,
                debugDescription: "Invalid base64-encoded image data"
            )
        }

        self.image = imageData
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        self.metadata = try container.decodeIfPresent([String: Value].self, forKey: .metadata)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(image.base64EncodedString(), forKey: .image)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}

extension TextToImage.ControlNet {
    private enum CodingKeys: String, CodingKey {
        case name
        case strength
        case controlImage = "control_image"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.strength = try container.decode(Double.self, forKey: .strength)

        // Decode the base64-encoded control image string and convert to Data
        if let controlImageString = try container.decodeIfPresent(String.self, forKey: .controlImage) {
            guard let controlImageData = Data(base64Encoded: controlImageString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .controlImage,
                    in: container,
                    debugDescription: "Invalid base64-encoded control image data"
                )
            }
            self.controlImage = controlImageData
        } else {
            self.controlImage = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(strength, forKey: .strength)
        try container.encodeIfPresent(controlImage?.base64EncodedString(), forKey: .controlImage)
    }
}
