import Foundation

/// A message in a chat conversation.
///
/// Messages are used in chat completion requests to provide context and instructions
/// to language models. Each message has a role (system, user, assistant, or tool)
/// and content.
public struct Message: Codable, Hashable, Sendable {
    /// The role of a message sender in a chat conversation.
    public enum Role: String, Hashable, CaseIterable, Codable, Sendable {
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
}

// MARK: - Codable

extension Message.Content: Codable {
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

extension Message.Content.Item: Codable {
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

extension Message.Content.Item.Detail: Codable {
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
