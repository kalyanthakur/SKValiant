//
//  Logger.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import os.log

/// Centralized logging utility with security and performance optimizations
class Logger {
    
    // MARK: - Log Levels
    enum LogLevel: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
        
        var prefix: String {
            switch self {
            case .debug: return "🔍 [DEBUG]"
            case .info: return "ℹ️ [INFO]"
            case .warning: return "⚠️ [WARNING]"
            case .error: return "❌ [ERROR]"
            }
        }
    }
    
    // MARK: - Configuration
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.khalsacommunityschool"
    private static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // Minimum log level (only log at or above this level in production)
    private static let minimumLogLevel: LogLevel = isDebugMode ? .debug : .error
    
    // MARK: - Sensitive Data Patterns
    private static let sensitivePatterns: [(pattern: String, replacement: String)] = [
        ("token[=:]\\s*[\"']?([^\"'\\s]+)", "token=***REDACTED***"),
        ("password[=:]\\s*[\"']?([^\"'\\s]+)", "password=***REDACTED***"),
        ("Token\\s+([^\\s]+)", "Token ***REDACTED***"),
        ("Authorization[=:]\\s*[\"']?([^\"'\\s]+)", "Authorization=***REDACTED***"),
        ("\"token\"\\s*:\\s*\"([^\"]+)\"", "\"token\":\"***REDACTED***\""),
        ("'token'\\s*:\\s*'([^']+)'", "'token':'***REDACTED***'")
    ]
    
    // MARK: - OSLog Categories
    private static let networkLog = OSLog(subsystem: subsystem, category: "Network")
    private static let viewModelLog = OSLog(subsystem: subsystem, category: "ViewModel")
    private static let appLog = OSLog(subsystem: subsystem, category: "App")
    private static let generalLog = OSLog(subsystem: subsystem, category: "General")
    
    // MARK: - Public Logging Methods
    
    /// Log debug information (only in debug builds)
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line, category: generalLog)
    }
    
    /// Log informational messages
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line, category: generalLog)
    }
    
    /// Log warnings
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line, category: generalLog)
    }
    
    /// Log errors
    static func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line, category: generalLog)
    }
    
    // MARK: - Category-Specific Logging
    
    /// Log network-related messages
    static func network(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, file: file, function: function, line: line, category: networkLog)
    }
    
    /// Log ViewModel-related messages
    static func viewModel(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, file: file, function: function, line: line, category: viewModelLog)
    }
    
    /// Log app-level messages
    static func app(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, file: file, function: function, line: line, category: appLog)
    }
    
    // MARK: - Private Implementation
    
    private static func log(_ message: String, level: LogLevel, file: String, function: String, line: Int, category: OSLog) {
        // Skip logging if below minimum level
        guard level.rawValue >= minimumLogLevel.rawValue else {
            return
        }
        
        // Sanitize sensitive data
        let sanitizedMessage = sanitize(message)
        
        // Format log message
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "\(level.prefix) [\(fileName):\(line)] \(function) - \(sanitizedMessage)"
        
        // Use OSLog for better performance and system integration
        os_log("%{public}@", log: category, type: level.osLogType, formattedMessage)
        
        // Also print in debug mode for Xcode console visibility
        if isDebugMode {
            print(formattedMessage)
        }
    }
    
    /// Sanitizes sensitive data from log messages
    private static func sanitize(_ message: String) -> String {
        var sanitized = message
        
        // Apply sensitive data patterns
        for (pattern, replacement) in sensitivePatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let range = NSRange(location: 0, length: sanitized.utf16.count)
                sanitized = regex.stringByReplacingMatches(
                    in: sanitized,
                    options: [],
                    range: range,
                    withTemplate: replacement
                )
            } catch {
                // Log regex compilation error but continue with sanitization
                // Use print instead of Logger to avoid recursion
                #if DEBUG
                print("⚠️ [WARNING] Failed to compile regex pattern for sanitization: \(pattern) - Error: \(error.localizedDescription)")
                #endif
            }
        }
        
        // Additional manual sanitization for common patterns
        sanitized = sanitized.replacingOccurrences(of: "Token ", with: "Token ***REDACTED*** ", options: .caseInsensitive)
        
        return sanitized
    }
    
    // MARK: - Convenience Methods
    
    /// Log URL (sanitized)
    static func logURL(_ url: String) {
        network("Request URL: \(url)", level: .debug)
    }
    
    /// Log parameters (sanitized)
    static func logParameters(_ parameters: [String: Any]) {
        let sanitized = sanitize("\(parameters)")
        network("Request Parameters: \(sanitized)", level: .debug)
    }
    
    /// Log response (sanitized, truncated for large responses)
    static func logResponse(_ response: String, isFromCache: Bool = false) {
        let prefix = isFromCache ? "Cached Response" : "Response"
        let truncated = response.count > 500 ? String(response.prefix(500)) + "..." : response
        let sanitized = sanitize(truncated)
        network("\(prefix): \(sanitized)", level: .debug)
    }
    
    /// Log decoding errors
    static func logDecodingError(_ error: Error, context: String = "") {
        let message = context.isEmpty ? "Decoding error" : "Decoding error in \(context)"
        viewModel("\(message): \(error.localizedDescription)", level: .error)
    }
}
