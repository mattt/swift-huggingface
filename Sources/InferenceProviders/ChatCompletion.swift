import Foundation

/// Chat completion task namespace.
public enum ChatCompletion {

    /// A message in a chat conversation.
    ///
    /// Messages are used in chat completion requests to provide context and instructions
    /// to language models. Each message has a role (system, user, assistant, or tool)
    /// and content.
    public struct Message: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        /// The role of a message sender in a chat conversation.
        public enum Role: String, Codable, Hashable, Sendable {
            /// System message providing instructions or context.
            case system = "system"

            /// User message from the human user.
            case user = "user"

            /// Assistant message from the AI model.
            case assistant = "assistant"

            /// Tool message containing tool execution results.
            case tool = "tool"
        }

        /// The content of a message.
        public enum Content: Hashable, Sendable {
            /// Text content as a string.
            case text(String)

            /// Mixed content including text and images.
            case mixed([Item])

            /// An item in mixed content (text or image).
            public enum Item: Hashable, Sendable {
                /// Text content item.
                case text(String)

                /// Image content item with URL and detail level.
                case image(url: String, detail: Detail = .auto)

                /// The detail level for image processing.
                public enum Detail: String, Hashable, Sendable {
                    /// Automatically determine the appropriate detail level.
                    case auto = "auto"

                    /// Low detail level for faster processing.
                    case low = "low"

                    /// High detail level for more accurate processing.
                    case high = "high"
                }
            }
        }

        /// A tool call made by the assistant.
        public struct ToolCall: Codable, Hashable, Sendable {
            /// The unique identifier for the tool call.
            public let id: String

            /// The type of tool call (always "function").
            public let type: String

            /// The function to be called.
            public let function: Function

            /// Creates a tool call.
            ///
            /// - Parameters:
            ///   - id: The unique identifier for the tool call.
            ///   - function: The function to be called.
            public init(id: String, function: Function) {
                self.id = id
                self.type = "function"
                self.function = function
            }
        }

        /// A function to be called by the assistant.
        public struct Function: Codable, Hashable, Sendable {
            /// The name of the function.
            public let name: String

            /// The arguments to pass to the function as a JSON string.
            public let arguments: String

            /// Creates a function call.
            ///
            /// - Parameters:
            ///   - name: The name of the function.
            ///   - arguments: The arguments to pass to the function as a JSON string.
            public init(name: String, arguments: String) {
                self.name = name
                self.arguments = arguments
            }
        }

        /// The role of the message sender.
        public let role: Role

        /// The content of the message.
        public let content: Content?

        /// Optional name for the message sender.
        public let name: String?

        /// Optional tool calls made by the assistant.
        public let toolCalls: [ToolCall]?

        /// Optional tool call ID for tool messages.
        public let toolCallId: String?

        /// Creates a new message.
        ///
        /// - Parameters:
        ///   - role: The role of the message sender.
        ///   - content: The content of the message.
        ///   - name: Optional name for the message sender.
        ///   - toolCalls: Optional tool calls made by the assistant.
        ///   - toolCallId: Optional tool call ID for tool messages.
        public init(
            role: Role,
            content: Content,
            name: String? = nil,
            toolCalls: [ToolCall]? = nil,
            toolCallId: String? = nil
        ) {
            self.role = role
            self.content = content
            self.name = name
            self.toolCalls = toolCalls
            self.toolCallId = toolCallId
        }

        /// Creates a new message with optional content.
        ///
        /// - Parameters:
        ///   - role: The role of the message sender.
        ///   - content: Optional content of the message.
        ///   - name: Optional name for the message sender.
        ///   - toolCalls: Optional tool calls made by the assistant.
        ///   - toolCallId: Optional tool call ID for tool messages.
        internal init(
            role: Role,
            content: Content? = nil,
            name: String? = nil,
            toolCalls: [ToolCall]? = nil,
            toolCallId: String? = nil
        ) {
            self.role = role
            self.content = content
            self.name = name
            self.toolCalls = toolCalls
            self.toolCallId = toolCallId
        }

        private enum CodingKeys: String, CodingKey {
            case role
            case content
            case name
            case toolCalls = "tool_calls"
            case toolCallId = "tool_call_id"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            role = try container.decode(Role.self, forKey: .role)

            if container.contains(.content) {
                if try container.decodeNil(forKey: .content) {
                    content = nil
                } else {
                    content = try container.decode(Content.self, forKey: .content)
                }
            } else {
                content = nil
            }

            name = try container.decodeIfPresent(String.self, forKey: .name)
            toolCalls = try container.decodeIfPresent([ToolCall].self, forKey: .toolCalls)
            toolCallId = try container.decodeIfPresent(String.self, forKey: .toolCallId)
        }

        public init(stringLiteral value: String) {
            self.init(role: .user, content: .text(value))
        }

        public static func system(_ text: String) -> Message {
            Message(role: .system, content: .text(text))
        }

        public static func user(_ text: String) -> Message {
            Message(role: .user, content: .text(text))
        }

        public static func assistant(_ text: String) -> Message {
            Message(role: .assistant, content: .text(text))
        }

        public static func tool(_ text: String, toolCallId: String) -> Message {
            Message(role: .tool, content: .text(text), toolCallId: toolCallId)
        }
    }

    /// Internal type for streaming delta messages
    private struct DeltaMessage: Codable {
        let role: Message.Role?
        let content: Message.Content?
        let toolCalls: [Message.ToolCall]?
        let toolCallId: String?

        private enum CodingKeys: String, CodingKey {
            case role
            case content
            case toolCalls = "tool_calls"
            case toolCallId = "tool_call_id"
        }
    }

    /// A chat completion response from the Inference Providers API.
    ///
    /// This represents the response from a chat completion request, containing
    /// the generated message, usage statistics, and metadata.
    public struct Response: Identifiable, Codable, Sendable {
        /// The unique identifier for the completion.
        public let id: String

        /// The object type (always "chat.completion").
        public let object: String

        /// The timestamp when the completion was created.
        public let created: Date

        /// The model used for the completion.
        public let model: String

        /// The choices generated by the model.
        public let choices: [Choice]

        /// Usage statistics for the completion.
        public let usage: Usage?

        /// The system fingerprint for the completion.
        public let systemFingerprint: String?

        private enum CodingKeys: String, CodingKey {
            case id
            case object
            case created
            case model
            case choices
            case usage
            case systemFingerprint = "system_fingerprint"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            object = try container.decode(String.self, forKey: .object)
            let timestamp = try container.decode(TimeInterval.self, forKey: .created)
            created = Date(timeIntervalSince1970: timestamp)
            model = try container.decode(String.self, forKey: .model)
            choices = try container.decode([Choice].self, forKey: .choices)
            usage = try container.decodeIfPresent(Usage.self, forKey: .usage)
            systemFingerprint = try container.decodeIfPresent(String.self, forKey: .systemFingerprint)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(object, forKey: .object)
            try container.encode(created.timeIntervalSince1970, forKey: .created)
            try container.encode(model, forKey: .model)
            try container.encode(choices, forKey: .choices)
            try container.encodeIfPresent(usage, forKey: .usage)
            try container.encodeIfPresent(systemFingerprint, forKey: .systemFingerprint)
        }
    }

    /// A choice in a chat completion response.
    public struct Choice: Codable, Hashable, Sendable {
        /// The index of the choice in the list of choices.
        public let index: Int

        /// The message generated by the model.
        public let message: ChatCompletion.Message

        /// The reason why the completion finished.
        public let finishReason: FinishReason?

        /// The log probabilities for the choice.
        public let logprobs: LogProbs?

        private enum CodingKeys: String, CodingKey {
            case index
            case message
            case delta
            case finishReason = "finish_reason"
            case logprobs
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            index = try container.decode(Int.self, forKey: .index)

            // Try to decode message first, if not present try delta (streaming responses)
            if let decodedMessage = try? container.decode(ChatCompletion.Message.self, forKey: .message) {
                message = decodedMessage
            } else if let delta = try? container.decode(DeltaMessage.self, forKey: .delta) {
                // Build a Message from a delta; default to assistant role for streaming
                message = ChatCompletion.Message(
                    role: delta.role ?? .assistant,
                    content: delta.content,
                    toolCalls: delta.toolCalls,
                    toolCallId: delta.toolCallId
                )
            } else {
                throw DecodingError.keyNotFound(
                    CodingKeys.message,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Neither 'message' nor 'delta' key found"
                    )
                )
            }

            finishReason = try container.decodeIfPresent(FinishReason.self, forKey: .finishReason)
            logprobs = try container.decodeIfPresent(LogProbs.self, forKey: .logprobs)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(index, forKey: .index)
            try container.encode(message, forKey: .message)
            try container.encodeIfPresent(finishReason, forKey: .finishReason)
            try container.encodeIfPresent(logprobs, forKey: .logprobs)
        }
    }

    /// The reason why a chat completion finished.
    public enum FinishReason: String, Codable, Hashable, Sendable {
        /// The model stopped generating because it reached a natural stopping point.
        case stop = "stop"

        /// The model stopped generating because it reached the maximum length.
        case length = "length"

        /// The model stopped generating because it encountered a function call.
        case functionCall = "function_call"

        /// The model stopped generating because it encountered a tool call.
        case toolCalls = "tool_calls"

        /// The model stopped generating because of content filtering.
        case contentFilter = "content_filter"

        /// The model stopped generating for an unknown reason.
        case null = "null"
    }

    /// Log probabilities for a choice.
    public struct LogProbs: Codable, Hashable, Sendable {
        /// The log probabilities for the content tokens.
        public let content: [LogProb]?

        private enum CodingKeys: String, CodingKey {
            case content
        }
    }

    /// A log probability for a token.
    public struct LogProb: Codable, Hashable, Sendable {
        /// The token text.
        public let token: String

        /// The log probability of the token.
        public let logprob: Double

        /// The bytes that make up the token.
        public let bytes: [Int]?

        /// The top log probabilities for this token position.
        public let topLogprobs: [TopLogProb]?

        private enum CodingKeys: String, CodingKey {
            case token
            case logprob
            case bytes
            case topLogprobs = "top_logprobs"
        }
    }

    /// A top log probability for a token.
    public struct TopLogProb: Codable, Hashable, Sendable {
        /// The token text.
        public let token: String

        /// The log probability of the token.
        public let logprob: Double

        /// The bytes that make up the token.
        public let bytes: [Int]?

        private enum CodingKeys: String, CodingKey {
            case token
            case logprob
            case bytes
        }
    }

    /// Usage statistics for a completion.
    public struct Usage: Codable, Hashable, Sendable {
        /// The number of tokens in the prompt.
        public let promptTokens: Int

        /// The number of tokens in the completion.
        public let completionTokens: Int

        /// The total number of tokens used.
        public let totalTokens: Int

        private enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }

    /// A tool available to the model.
    public struct Tool: Codable, Hashable, Sendable {
        /// The type of tool (always "function").
        public let type: String

        /// The function definition.
        public let function: FunctionDefinition

        /// Creates a tool.
        ///
        /// - Parameter function: The function definition.
        public init(function: FunctionDefinition) {
            self.type = "function"
            self.function = function
        }
    }

    /// A function definition for a tool.
    public struct FunctionDefinition: Codable, Hashable, Sendable {
        /// The name of the function.
        public let name: String

        /// The description of the function.
        public let description: String?

        /// The parameters schema for the function.
        public let parameters: [String: Value]?

        /// Creates a function definition.
        ///
        /// - Parameters:
        ///   - name: The name of the function.
        ///   - description: The description of the function.
        ///   - parameters: The parameters schema for the function.
        public init(
            name: String,
            description: String? = nil,
            parameters: [String: Value]? = nil
        ) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decodeIfPresent(String.self, forKey: .description)

            parameters = try container.decodeIfPresent([String: Value].self, forKey: .parameters)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(description, forKey: .description)

            try container.encodeIfPresent(parameters, forKey: .parameters)
        }

        private enum CodingKeys: String, CodingKey {
            case name
            case description
            case parameters
        }
    }

    /// The tool choice strategy for the model.
    public enum ToolChoice: RawRepresentable, Hashable, Sendable {
        /// No tools should be called.
        case none

        /// The model can choose whether to call tools.
        case auto

        /// A specific tool should be called.
        case required(String)

        public init(rawValue: String) {
            switch rawValue {
            case "none":
                self = .none
            case "auto":
                self = .auto
            default:
                self = .required(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .none:
                return "none"
            case .auto:
                return "auto"
            case .required(let name):
                return name
            }
        }
    }

    /// The response format for the completion.
    public enum ResponseFormat: String, CaseIterable, Hashable, Sendable {
        /// Standard text response.
        case text

        /// JSON object response.
        case jsonObject = "json_object"
    }
}

// MARK: -

extension InferenceClient {
    /// Performs a chat completion request.
    ///
    /// - Parameters:
    ///   - model: The model to use for completion.
    ///   - messages: The messages in the conversation.
    ///   - provider: The provider to use for completion.
    ///   - temperature: The sampling temperature (0.0 to 2.0).
    ///   - topP: The top-p sampling parameter (0.0 to 1.0).
    ///   - maxTokens: The maximum number of tokens to generate.
    ///   - stream: Whether to stream the response.
    ///   - stop: The stop sequences for completion.
    ///   - presencePenalty: The presence penalty (-2.0 to 2.0).
    ///   - frequencyPenalty: The frequency penalty (-2.0 to 2.0).
    ///   - seed: The seed for reproducible generation.
    ///   - tools: The tools available to the model.
    ///   - toolChoice: The tool choice strategy.
    ///   - responseFormat: The response format.
    /// - Returns: A chat completion result.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func chatCompletion(
        model: String,
        messages: [ChatCompletion.Message],
        provider: Provider? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        maxTokens: Int? = nil,
        stream: Bool? = nil,
        stop: [String]? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        seed: Int? = nil,
        tools: [ChatCompletion.Tool]? = nil,
        toolChoice: ChatCompletion.ToolChoice? = nil,
        responseFormat: ChatCompletion.ResponseFormat? = nil
    ) async throws -> ChatCompletion.Response {
        var params: [String: Value] = [
            "model": .string(model),
            "messages": try .init(messages),
        ]

        if let provider = provider {
            params["provider"] = .string(provider.identifier)
        }
        if let temperature = temperature {
            params["temperature"] = .double(temperature)
        }
        if let topP = topP {
            params["top_p"] = .double(topP)
        }
        if let maxTokens = maxTokens {
            params["max_tokens"] = .int(maxTokens)
        }
        if let stream = stream {
            params["stream"] = .bool(stream)
        }
        if let stop = stop {
            params["stop"] = .array(stop.map { .string($0) })
        }
        if let presencePenalty = presencePenalty {
            params["presence_penalty"] = .double(presencePenalty)
        }
        if let frequencyPenalty = frequencyPenalty {
            params["frequency_penalty"] = .double(frequencyPenalty)
        }
        if let seed = seed {
            params["seed"] = .int(seed)
        }
        if let tools = tools {
            params["tools"] = try .init(tools)
        }
        if let toolChoice = toolChoice {
            params["tool_choice"] = try .init(toolChoice)
        }
        if let responseFormat = responseFormat {
            params["response_format"] = try .init(responseFormat)
        }

        return try await fetch(.post, "/v1/chat/completions", params: params)
    }

    /// Performs a streaming chat completion request.
    ///
    /// - Parameters:
    ///   - model: The model to use for completion.
    ///   - messages: The messages in the conversation.
    ///   - provider: The provider to use for completion.
    ///   - temperature: The sampling temperature (0.0 to 2.0).
    ///   - topP: The top-p sampling parameter (0.0 to 1.0).
    ///   - maxTokens: The maximum number of tokens to generate.
    ///   - stop: The stop sequences for completion.
    ///   - presencePenalty: The presence penalty (-2.0 to 2.0).
    ///   - frequencyPenalty: The frequency penalty (-2.0 to 2.0).
    ///   - seed: The seed for reproducible generation.
    ///   - tools: The tools available to the model.
    ///   - toolChoice: The tool choice strategy.
    ///   - responseFormat: The response format.
    /// - Returns: An async throwing stream of chat completion chunks.
    /// - Throws: An error if the request fails.
    public func chatCompletionStream(
        model: String,
        messages: [ChatCompletion.Message],
        provider: Provider? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        maxTokens: Int? = nil,
        stop: [String]? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        seed: Int? = nil,
        tools: [ChatCompletion.Tool]? = nil,
        toolChoice: ChatCompletion.ToolChoice? = nil,
        responseFormat: ChatCompletion.ResponseFormat? = nil
    ) -> AsyncThrowingStream<ChatCompletion.Response, Error> {
        var params: [String: Value] = [
            "stream": .bool(true),
            "model": .string(model),
            "messages": .init(messages: messages),
        ]

        if let provider = provider {
            params["provider"] = .string(provider.identifier)
        }
        if let temperature = temperature {
            params["temperature"] = .double(temperature)
        }
        if let topP = topP {
            params["top_p"] = .double(topP)
        }
        if let maxTokens = maxTokens {
            params["max_tokens"] = .int(maxTokens)
        }
        if let stop = stop {
            params["stop"] = .array(stop.map { .string($0) })
        }
        if let presencePenalty = presencePenalty {
            params["presence_penalty"] = .double(presencePenalty)
        }
        if let frequencyPenalty = frequencyPenalty {
            params["frequency_penalty"] = .double(frequencyPenalty)
        }
        if let seed = seed {
            params["seed"] = .int(seed)
        }
        if let tools = tools {
            params["tools"] = .array(tools.map { .init(tool: $0) })
        }
        if let toolChoice = toolChoice {
            params["tool_choice"] = .string(toolChoice.rawValue)
        }
        if let responseFormat = responseFormat {
            params["response_format"] = .object([
                "type": .string(responseFormat.rawValue)
            ])
        }

        return fetchStream(.post, "/v1/chat/completions", params: params)
    }
}

// MARK: - Private Value Extensions

private extension Value {
    init(messages: [ChatCompletion.Message]) {
        self = .array(messages.map { .init(message: $0) })
    }

    init(message: ChatCompletion.Message) {
        var object: [String: Value] = [
            "role": .string(message.role.rawValue)
        ]

        if let content = message.content {
            object["content"] = .init(content: content)
        }

        if let name = message.name {
            object["name"] = .string(name)
        }

        if let toolCalls = message.toolCalls {
            object["tool_calls"] = .array(toolCalls.map { .init(toolCall: $0) })
        }

        if let toolCallId = message.toolCallId {
            object["tool_call_id"] = .string(toolCallId)
        }

        self = .object(object)
    }

    init(content: ChatCompletion.Message.Content) {
        switch content {
        case .text(let text):
            self = .string(text)
        case .mixed(let items):
            self = .array(items.map { .init(item: $0) })
        }
    }

    init(item: ChatCompletion.Message.Content.Item) {
        switch item {
        case .text(let text):
            self = .string(text)
        case .image(let url, let detail):
            self = .object([
                "type": .string("image_url"),
                "image_url": .object([
                    "url": .string(url),
                    "detail": .string(detail.rawValue),
                ]),
            ])
        }
    }

    init(toolCall: ChatCompletion.Message.ToolCall) {
        self = .object([
            "id": .string(toolCall.id),
            "type": .string(toolCall.type),
            "function": .object([
                "name": .string(toolCall.function.name),
                "arguments": .string(toolCall.function.arguments),
            ]),
        ])
    }

    init(tool: ChatCompletion.Tool) {
        self = .object([
            "type": .string(tool.type),
            "function": .object(
                {
                    var object: [String: Value] = [
                        "name": .string(tool.function.name)
                    ]
                    if let description = tool.function.description {
                        object["description"] = .string(description)
                    }
                    if let parameters = tool.function.parameters {
                        object["parameters"] = .object(parameters)
                    }
                    return object
                }()
            ),
        ])
    }
}

// MARK: - Codable

extension ChatCompletion.Message.Content: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let items = try? container.decode([Item].self) {
            self = .mixed(items)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Content must be either a string or an array of content items"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .text(let text):
            try container.encode(text)
        case .mixed(let items):
            try container.encode(items)
        }
    }
}

extension ChatCompletion.Message.Content.Item: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else {
            // Try to decode as image content object
            let imageContainer = try decoder.container(keyedBy: ImageCodingKeys.self)
            let type = try imageContainer.decode(String.self, forKey: .type)
            guard type == "image_url" else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid image content type: \(type)"
                )
            }

            let imageUrlContainer = try imageContainer.nestedContainer(
                keyedBy: ImageUrlCodingKeys.self,
                forKey: .imageUrl
            )
            let url = try imageUrlContainer.decode(String.self, forKey: .url)
            let detail = try imageUrlContainer.decodeIfPresent(Detail.self, forKey: .detail) ?? .auto

            self = .image(url: url, detail: detail)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .text(let text):
            try container.encode(text)
        case .image(let url, let detail):
            var imageContainer = encoder.container(keyedBy: ImageCodingKeys.self)
            try imageContainer.encode("image_url", forKey: .type)

            var imageUrlContainer = imageContainer.nestedContainer(keyedBy: ImageUrlCodingKeys.self, forKey: .imageUrl)
            try imageUrlContainer.encode(url, forKey: .url)
            try imageUrlContainer.encode(detail, forKey: .detail)
        }
    }

    private enum ImageCodingKeys: String, CodingKey {
        case type
        case imageUrl = "image_url"
    }

    private enum ImageUrlCodingKeys: String, CodingKey {
        case url
        case detail
    }
}

extension ChatCompletion.Message.Content.Item.Detail: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let detail = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid detail value: \(rawValue)"
            )
        }
        self = detail
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension ChatCompletion.ToolChoice: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self = Self(rawValue: string)
        } else if let object = try? container.decode([String: String].self),
            let name = object["name"]
        {
            self = .required(name)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid tool choice format"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .none, .auto:
            try container.encode(rawValue)
        case .required(let name):
            try container.encode(["name": name])
        }
    }
}

extension ChatCompletion.ResponseFormat: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .text
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
