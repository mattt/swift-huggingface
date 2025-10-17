import Foundation
import Testing

@testable import InferenceProviders

#if swift(>=6.1)

    /// Tests for the Chat Completion API
    @Suite("Chat Completion Tests", .serialized)
    struct ChatCompletionTests {
        /// Helper to create a URL session with mock protocol handlers
        func createMockClient() -> InferenceClient {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [MockURLProtocol.self]
            let session = URLSession(configuration: configuration)
            return InferenceClient(
                session: session,
                host: URL(string: "https://router.huggingface.co")!,
                userAgent: "TestClient/1.0"
            )
        }

        @Test("Basic chat completion request", .mockURLSession)
        func testBasicChatCompletion() async throws {
            let mockResponse = """
                {
                    "id": "chatcmpl-123",
                    "object": "chat.completion",
                    "created": 1677652288,
                    "model": "gpt-3.5-turbo",
                    "choices": [
                        {
                            "index": 0,
                            "message": {
                                "role": "assistant",
                                "content": "Hello! How can I help you today?"
                            },
                            "finish_reason": "stop"
                        }
                    ],
                    "usage": {
                        "prompt_tokens": 9,
                        "completion_tokens": 12,
                        "total_tokens": 21
                    },
                    "system_fingerprint": "fp_44709d6fcb"
                }
                """

            await MockURLProtocol.setHandler { request in
                #expect(request.url?.path == "/v1/chat/completions")
                #expect(request.httpMethod == "POST")

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!

                return (response, Data(mockResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(role: .user, content: .text("Hello, world!"))
            ]

            let result = try await client.chatCompletion(
                model: "gpt-3.5-turbo",
                messages: messages
            )

            #expect(result.id == "chatcmpl-123")
            #expect(result.object == "chat.completion")
            #expect(result.model == "gpt-3.5-turbo")
            #expect(result.choices.count == 1)
            #expect(result.choices[0].message.content == .text("Hello! How can I help you today?"))
            #expect(result.choices[0].finishReason == ChatCompletion.FinishReason.stop)
            #expect(result.usage?.promptTokens == 9)
            #expect(result.usage?.completionTokens == 12)
            #expect(result.usage?.totalTokens == 21)
        }

        @Test("Chat completion with all parameters", .mockURLSession)
        func testChatCompletionWithAllParameters() async throws {
            let mockResponse = """
                {
                    "id": "chatcmpl-456",
                    "object": "chat.completion",
                    "created": 1677652288,
                    "model": "gpt-4",
                    "choices": [
                        {
                            "index": 0,
                            "message": {
                                "role": "assistant",
                                "content": "This is a creative response."
                            },
                            "finish_reason": "stop",
                            "logprobs": {
                                "content": [
                                    {
                                        "token": "This",
                                        "logprob": -0.1,
                                        "bytes": [84, 104, 105, 115],
                                        "top_logprobs": [
                                            {
                                                "token": "This",
                                                "logprob": -0.1,
                                                "bytes": [84, 104, 105, 115]
                                            }
                                        ]
                                    }
                                ]
                            }
                        }
                    ],
                    "usage": {
                        "prompt_tokens": 15,
                        "completion_tokens": 8,
                        "total_tokens": 23
                    }
                }
                """

            await MockURLProtocol.setHandler { request in
                #expect(request.url?.path == "/v1/chat/completions")
                #expect(request.httpMethod == "POST")

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!

                return (response, Data(mockResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(role: .system, content: .text("You are a helpful assistant.")),
                ChatCompletion.Message(role: .user, content: .text("Write a creative story.")),
            ]

            let tools = [
                ChatCompletion.Tool(
                    function: ChatCompletion.FunctionDefinition(
                        name: "get_weather",
                        description: "Get the current weather",
                        parameters: [
                            "type": .string("object"),
                            "properties": [
                                "location": .string("string")
                            ],
                        ]
                    )
                )
            ]

            let result = try await client.chatCompletion(
                model: "gpt-4",
                messages: messages,
                provider: .custom(name: "openai"),
                temperature: 0.7,
                topP: 0.9,
                maxTokens: 100,
                stream: false,
                stop: ["END", "STOP"],
                presencePenalty: 0.1,
                frequencyPenalty: 0.2,
                seed: 42,
                tools: tools,
                toolChoice: .auto,
                responseFormat: .text
            )

            #expect(result.id == "chatcmpl-456")
            #expect(result.model == "gpt-4")
            #expect(result.choices[0].logprobs?.content?.count == 1)
        }

        @Test("Chat completion with mixed content messages", .mockURLSession)
        func testChatCompletionWithMixedContent() async throws {
            let mockResponse = """
                {
                    "id": "chatcmpl-789",
                    "object": "chat.completion",
                    "created": 1677652288,
                    "model": "gpt-4-vision",
                    "choices": [
                        {
                            "index": 0,
                            "message": {
                                "role": "assistant",
                                "content": "I can see the image you shared."
                            },
                            "finish_reason": "stop"
                        }
                    ],
                    "usage": {
                        "prompt_tokens": 25,
                        "completion_tokens": 10,
                        "total_tokens": 35
                    }
                }
                """

            await MockURLProtocol.setHandler { request in
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!

                return (response, Data(mockResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(
                    role: .user,
                    content: .mixed([
                        .text("What do you see in this image?"),
                        .image(url: "https://example.com/image.jpg", detail: .high),
                    ])
                )
            ]

            let result = try await client.chatCompletion(
                model: "gpt-4-vision",
                messages: messages
            )

            #expect(result.id == "chatcmpl-789")
            #expect(result.model == "gpt-4-vision")
        }

        @Test("Chat completion with tool calls", .mockURLSession)
        func testChatCompletionWithToolCalls() async throws {
            let mockResponse = """
                {
                    "id": "chatcmpl-tool",
                    "object": "chat.completion",
                    "created": 1677652288,
                    "model": "gpt-4",
                    "choices": [
                        {
                            "index": 0,
                            "message": {
                                "role": "assistant",
                                "content": null,
                                "tool_calls": [
                                    {
                                        "id": "call_123",
                                        "type": "function",
                                        "function": {
                                            "name": "get_weather",
                                            "arguments": "{\\"location\\": \\"New York\\"}"
                                        }
                                    }
                                ]
                            },
                            "finish_reason": "tool_calls"
                        }
                    ],
                    "usage": {
                        "prompt_tokens": 20,
                        "completion_tokens": 15,
                        "total_tokens": 35
                    }
                }
                """

            await MockURLProtocol.setHandler { request in
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!

                return (response, Data(mockResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(role: .user, content: .text("What's the weather in New York?"))
            ]

            let result = try await client.chatCompletion(
                model: "gpt-4",
                messages: messages
            )

            #expect(result.choices[0].message.toolCalls?.count == 1)
            #expect(result.choices[0].message.toolCalls?[0].id == "call_123")
            #expect(result.choices[0].message.toolCalls?[0].function.name == "get_weather")
            #expect(result.choices[0].finishReason == ChatCompletion.FinishReason.toolCalls)
        }

        @Test("Chat completion with JSON response format", .mockURLSession)
        func testChatCompletionWithJSONResponseFormat() async throws {
            let mockResponse = """
                {
                    "id": "chatcmpl-json",
                    "object": "chat.completion",
                    "created": 1677652288,
                    "model": "gpt-4",
                    "choices": [
                        {
                            "index": 0,
                            "message": {
                                "role": "assistant",
                                "content": "{\\"name\\": \\"John\\", \\"age\\": 30}"
                            },
                            "finish_reason": "stop"
                        }
                    ],
                    "usage": {
                        "prompt_tokens": 10,
                        "completion_tokens": 8,
                        "total_tokens": 18
                    }
                }
                """

            await MockURLProtocol.setHandler { request in
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!

                return (response, Data(mockResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(role: .user, content: .text("Return a JSON object with name and age."))
            ]

            let result = try await client.chatCompletion(
                model: "gpt-4",
                messages: messages,
                responseFormat: .jsonObject
            )

            #expect(result.id == "chatcmpl-json")
            #expect(result.choices[0].message.content == .text("{\"name\": \"John\", \"age\": 30}"))
        }

        @Test("Chat completion streaming", .mockURLSession)
        func testChatCompletionStreaming() async throws {
            let mockStreamResponse = """
                data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1677652288, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"role": "assistant", "content": "Hello"}, "finish_reason": null}]}

                data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1677652288, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"content": " there"}, "finish_reason": null}]}

                data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1677652288, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"content": "!"}, "finish_reason": "stop"}]}

                data: [DONE]
                """

            await MockURLProtocol.setHandler { request in
                #expect(request.url?.path == "/v1/chat/completions")
                #expect(request.httpMethod == "POST")

                // Parse the request body to verify the parameters
                if let httpBody = request.httpBody,
                    let json = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any]
                {
                    #expect(json["stream"] as? Bool == true)
                }

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "text/plain"]
                )!

                return (response, Data(mockStreamResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(role: .user, content: .text("Say hello"))
            ]

            let stream = client.chatCompletionStream(
                model: "gpt-3.5-turbo",
                messages: messages
            )

            var chunks: [ChatCompletion.Response] = []
            for try await chunk in stream {
                chunks.append(chunk)
            }

            #expect(chunks.count == 3)
            #expect(chunks[0].id == "chatcmpl-stream")
            #expect(chunks[0].choices[0].message.content == .text("Hello"))
            #expect(chunks[1].choices[0].message.content == .text(" there"))
            #expect(chunks[2].choices[0].message.content == .text("!"))
            #expect(chunks[2].choices[0].finishReason == .stop)
        }

        @Test("Chat completion handles error response", .mockURLSession)
        func testChatCompletionHandlesError() async throws {
            let errorResponse = """
                {
                    "error": "Rate limit exceeded"
                }
                """

            await MockURLProtocol.setHandler { request in
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 429,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!

                return (response, Data(errorResponse.utf8))
            }

            let client = createMockClient()
            let messages = [
                ChatCompletion.Message(role: .user, content: .text("Hello"))
            ]

            await #expect(throws: InferenceClient.ClientError.self) {
                _ = try await client.chatCompletion(
                    model: "gpt-3.5-turbo",
                    messages: messages
                )
            }
        }
    }

#endif  // swift(>=6.1)
