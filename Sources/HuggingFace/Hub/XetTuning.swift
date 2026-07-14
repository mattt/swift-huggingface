//
//  XetTuning.swift
//  swift-huggingface
//
//  Created by Taylor Lineman on 7/14/26.
//

import Foundation

/// An always available struct that allows teh user to tune parameters of the Xet downloader.
/// Setting any of the optional values will 
///
/// Compatible with Xet 0.2.3
public struct XetTuning: Sendable {
    /// Maximum number of xorb fetches running at once. Defaults to 128.
    public var maxConcurrentFetches: Int?

    /// Maximum number of chunk decode operations running at once.
    /// Defaults to the active processor count.
    public var maxConcurrentDecodes: Int?

    /// Maximum number of decoded buffers held in memory. Defaults to 16.
    public var maxInflightBuffers: Int?

    /// Maximum concurrent HTTP/1 connections per host. Defaults to 24.
    public var connectionsPerHost: Int?

    /// Number of prewarmed HTTP/1 connections per host. Defaults to 16.
    public var prewarmedConnections: Int?

    /// Number of HTTP clients in the pool. Defaults to 4.
    public var poolSize: Int?

    /// Connection timeout for HTTP requests, in seconds. Defaults to 60.
    public var connectTimeout: TimeInterval?

    /// Read timeout for HTTP requests, in seconds. Defaults to 120.
    public var readTimeout: TimeInterval?

    /// Whether to scale fetch concurrency based on connection pool size.
    /// Defaults to true.
    public var autoScaleFetchConcurrency: Bool?

    /// Whether to wait for network connectivity before failing.
    /// Defaults to true.
    public var waitsForConnectivity: Bool?

    /// Idle timeout for pooled connections, in seconds. Defaults to 120.
    public var idleTimeout: TimeInterval?

    /// Whether to enable multipath connections. Defaults to false.
    ///
    /// Some environments or network stacks may not support multipath and can
    /// surface "Operation unsupported" connection failures if enabled.
    ///
    /// In Apple's Sandbox, multipath results in the download hanging
    public var enableMultipath: Bool?

    /// Whether to allow insecure (non-HTTPS) connections.
    ///
    /// By default, the downloader requires HTTPS for all CAS and fetch URLs.
    /// Set this to `true` only for local development or testing with
    /// non-production servers.
    ///
    /// - Warning: Enabling insecure connections in production is a security risk.
    ///   Tokens and file contents may be transmitted in plaintext.
    public var allowsInsecureConnections: Bool?
    
    public init(maxConcurrentFetches: Int? = nil, maxConcurrentDecodes: Int? = nil, maxInflightBuffers: Int? = nil, connectionsPerHost: Int? = nil, prewarmedConnections: Int? = nil, poolSize: Int? = nil, connectTimeout: TimeInterval? = nil, readTimeout: TimeInterval? = nil, autoScaleFetchConcurrency: Bool? = nil, waitsForConnectivity: Bool? = nil, idleTimeout: TimeInterval? = nil, enableMultipath: Bool? = nil, allowsInsecureConnections: Bool? = nil) {
        self.maxConcurrentFetches = maxConcurrentFetches
        self.maxConcurrentDecodes = maxConcurrentDecodes
        self.maxInflightBuffers = maxInflightBuffers
        self.connectionsPerHost = connectionsPerHost
        self.prewarmedConnections = prewarmedConnections
        self.poolSize = poolSize
        self.connectTimeout = connectTimeout
        self.readTimeout = readTimeout
        self.autoScaleFetchConcurrency = autoScaleFetchConcurrency
        self.waitsForConnectivity = waitsForConnectivity
        self.idleTimeout = idleTimeout
        self.enableMultipath = enableMultipath
        self.allowsInsecureConnections = allowsInsecureConnections
    }
}

#if HUGGINGFACE_ENABLE_XET
import Xet

extension XetTuning {
    func toConfiguration() -> XetDownloader.Configuration {
        var config = XetDownloader.Configuration.default
        
        if let maxConcurrentFetches = self.maxConcurrentFetches {
            config.maxConcurrentFetches = maxConcurrentFetches
        }

        if let maxConcurrentDecodes = self.maxConcurrentDecodes {
            config.maxConcurrentDecodes = maxConcurrentDecodes
        }

        if let maxInflightBuffers = self.maxInflightBuffers {
            config.maxInflightBuffers = maxInflightBuffers
        }

        if let connectionsPerHost = self.connectionsPerHost {
            config.connectionsPerHost = connectionsPerHost
        }

        if let prewarmedConnections = self.prewarmedConnections {
            config.prewarmedConnections = prewarmedConnections
        }

        if let poolSize = self.poolSize {
            config.poolSize = poolSize
        }

        if let connectTimeout = self.connectTimeout {
            config.connectTimeout = connectTimeout
        }

        if let readTimeout = self.readTimeout {
            config.readTimeout = readTimeout
        }

        if let autoScaleFetchConcurrency = self.autoScaleFetchConcurrency {
            config.autoScaleFetchConcurrency = autoScaleFetchConcurrency
        }

        if let waitsForConnectivity = self.waitsForConnectivity {
            config.waitsForConnectivity = waitsForConnectivity
        }

        if let idleTimeout = self.idleTimeout {
            config.idleTimeout = idleTimeout
        }

        if let enableMultipath = self.enableMultipath {
            config.enableMultipath = enableMultipath
        }

        if let allowsInsecureConnections = self.allowsInsecureConnections {
            config.allowsInsecureConnections = allowsInsecureConnections
        }

        return config
    }
}


#endif

