import Foundation

/// A provider for Hugging Face Inference Providers.
///
/// This enum represents the different inference providers available through the
/// Hugging Face Inference Providers API. Each provider offers different capabilities
/// and model support.
///
/// - SeeAlso: [Inference Providers Documentation](https://huggingface.co/docs/inference-providers/index)
public enum Provider: Hashable, Sendable {
    /// Automatically select the best available provider for the model.
    case auto

    // MARK: - Built-in Providers

    /// Cerebras provider for high-performance inference.
    case cerebras

    /// Cohere provider for language models and vision-language models.
    case cohere

    /// Fal AI provider for various AI tasks.
    case falAI

    /// Featherless AI provider for fast inference.
    case featherlessAI

    /// Fireworks AI provider for language and vision-language models.
    case fireworks

    /// Groq provider for ultra-fast inference.
    case groq

    /// Hugging Face Inference provider for comprehensive model support.
    case hfInference

    /// Hyperbolic provider for specialized inference.
    case hyperbolic

    /// Nebius provider for cloud-based inference.
    case nebius

    /// Novita provider for various AI tasks.
    case novita

    /// Nscale provider for scalable inference.
    case nscale

    /// Public AI provider for open models.
    case publicAI

    /// Replicate provider for model hosting and inference.
    case replicate

    /// SambaNova provider for enterprise-grade inference.
    case sambaNova

    /// Scaleway provider for European cloud inference.
    case scaleway

    /// Together AI provider for various AI tasks.
    case together

    /// Z.ai provider for specialized inference.
    case zai

    // MARK: - Custom Provider

    /// A custom provider with a specific name and optional base URL.
    ///
    /// - Parameters:
    ///   - name: The name of the custom provider.
    ///   - baseURL: An optional custom base URL for the provider.
    case custom(name: String, baseURL: URL? = nil)

    /// The identifier used in API requests for this provider.
    public var identifier: String {
        switch self {
        case .auto:
            return "auto"
        case .cerebras:
            return "cerebras"
        case .cohere:
            return "cohere"
        case .falAI:
            return "fal-ai"
        case .featherlessAI:
            return "featherless-ai"
        case .fireworks:
            return "fireworks-ai"
        case .groq:
            return "groq"
        case .hfInference:
            return "hf-inference"
        case .hyperbolic:
            return "hyperbolic"
        case .nebius:
            return "nebius"
        case .novita:
            return "novita"
        case .nscale:
            return "nscale"
        case .publicAI:
            return "public-ai"
        case .replicate:
            return "replicate"
        case .sambaNova:
            return "sambanova"
        case .scaleway:
            return "scaleway"
        case .together:
            return "together"
        case .zai:
            return "zai-org"
        case .custom(let name, _):
            return name
        }
    }

    /// The display name for this provider.
    public var displayName: String {
        switch self {
        case .auto:
            return "Auto"
        case .cerebras:
            return "Cerebras"
        case .cohere:
            return "Cohere"
        case .falAI:
            return "Fal AI"
        case .featherlessAI:
            return "Featherless AI"
        case .fireworks:
            return "Fireworks AI"
        case .groq:
            return "Groq"
        case .hfInference:
            return "Hugging Face Inference"
        case .hyperbolic:
            return "Hyperbolic"
        case .nebius:
            return "Nebius"
        case .novita:
            return "Novita"
        case .nscale:
            return "Nscale"
        case .publicAI:
            return "Public AI"
        case .replicate:
            return "Replicate"
        case .sambaNova:
            return "SambaNova"
        case .scaleway:
            return "Scaleway"
        case .together:
            return "Together AI"
        case .zai:
            return "Z.ai"
        case .custom(let name, _):
            return name
        }
    }

    /// The capabilities supported by this provider.
    public var capabilities: Set<Capability> {
        switch self {
        case .auto:
            return Set(Capability.allCases)
        case .cerebras:
            return [.chatCompletion]
        case .cohere:
            return [.chatCompletion, .chatCompletionVLM]
        case .falAI:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction]
        case .featherlessAI:
            return [.chatCompletion, .chatCompletionVLM]
        case .fireworks:
            return [.chatCompletion, .chatCompletionVLM]
        case .groq:
            return [.chatCompletion, .chatCompletionVLM]
        case .hfInference:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction, .textToImage, .textToVideo]
        case .hyperbolic:
            return [.chatCompletion, .chatCompletionVLM]
        case .nebius:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction, .textToImage]
        case .novita:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction]
        case .nscale:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction]
        case .publicAI:
            return [.chatCompletion]
        case .replicate:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction]
        case .sambaNova:
            return [.chatCompletion, .chatCompletionVLM]
        case .scaleway:
            return [.chatCompletion, .chatCompletionVLM]
        case .together:
            return [.chatCompletion, .chatCompletionVLM, .featureExtraction]
        case .zai:
            return [.chatCompletion, .chatCompletionVLM]
        case .custom:
            return Set(Capability.allCases)  // Assume custom providers support all capabilities
        }
    }
}

// MARK: - Capability

/// Represents the capabilities supported by inference providers.
public enum Capability: String, Hashable, CaseIterable, Codable, Sendable {
    /// Chat completion with language models.
    case chatCompletion = "chat_completion"

    /// Chat completion with vision-language models.
    case chatCompletionVLM = "chat_completion_vlm"

    /// Feature extraction and embeddings.
    case featureExtraction = "feature_extraction"

    /// Text-to-image generation.
    case textToImage = "text_to_image"

    /// Text-to-video generation.
    case textToVideo = "text_to_video"

    /// Speech-to-text transcription.
    case speechToText = "speech_to_text"

    /// Text-to-speech synthesis.
    case textToSpeech = "text_to_speech"

    /// Image-to-text generation.
    case imageToText = "image_to_text"

    /// Image classification.
    case imageClassification = "image_classification"

    /// Text classification.
    case textClassification = "text_classification"

    /// Summarization.
    case summarization = "summarization"

    /// Translation.
    case translation = "translation"

    /// Question answering.
    case questionAnswering = "question_answering"

    /// Zero-shot classification.
    case zeroShotClassification = "zero_shot_classification"

    /// Conversational AI.
    case conversational = "conversational"

    /// Fill mask tasks.
    case fillMask = "fill_mask"

    /// Token classification (NER).
    case tokenClassification = "token_classification"

    /// Table question answering.
    case tableQuestionAnswering = "table_question_answering"

    /// Text generation.
    case textGeneration = "text_generation"

    /// Multiple choice.
    case multipleChoice = "multiple_choice"

    /// Sentence similarity.
    case sentenceSimilarity = "sentence_similarity"

    /// Text-to-audio generation.
    case textToAudio = "text_to_audio"
}

// MARK: - Codable

extension Provider: Codable {
    public init(from decoder: Decoder) throws {
        // Try to decode as a string first (for built-in providers)
        if let container = try? decoder.singleValueContainer(),
            let identifier = try? container.decode(String.self)
        {
            switch identifier {
            case "auto":
                self = .auto
            case "cerebras":
                self = .cerebras
            case "cohere":
                self = .cohere
            case "fal-ai":
                self = .falAI
            case "featherless-ai":
                self = .featherlessAI
            case "fireworks-ai":
                self = .fireworks
            case "groq":
                self = .groq
            case "hf-inference":
                self = .hfInference
            case "hyperbolic":
                self = .hyperbolic
            case "nebius":
                self = .nebius
            case "novita":
                self = .novita
            case "nscale":
                self = .nscale
            case "public-ai":
                self = .publicAI
            case "replicate":
                self = .replicate
            case "sambanova":
                self = .sambaNova
            case "scaleway":
                self = .scaleway
            case "together":
                self = .together
            case "zai-org":
                self = .zai
            default:
                self = .custom(name: identifier)
            }
            return
        }

        // Try to decode as a dictionary (for custom providers with baseURL)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let baseURL = try container.decodeIfPresent(URL.self, forKey: .baseURL)
        self = .custom(name: name, baseURL: baseURL)
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .custom(let name, let baseURL):
            // For custom providers, encode as a dictionary to preserve baseURL
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(baseURL, forKey: .baseURL)
        default:
            // For built-in providers, encode as a simple string
            var container = encoder.singleValueContainer()
            try container.encode(identifier)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case baseURL
    }
}
