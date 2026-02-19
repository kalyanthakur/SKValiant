//
//  DateFormatterManager.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation

/// Centralized DateFormatter manager that caches formatters by format string for performance.
/// DateFormatter creation is expensive, so caching significantly improves performance.
/// Thread-safe implementation using a serial queue.
class DateFormatterManager {
    
    static let shared = DateFormatterManager()
    
    // Thread-safe cache using serial queue
    private let queue = DispatchQueue(label: "com.iOS.Valiant.dateformatter", qos: .utility)
    private var formatterCache: [String: DateFormatter] = [:]
    
    private init() {
        // Private initializer for singleton pattern
    }
    
    /// Gets a cached DateFormatter for the specified format, creating one if it doesn't exist.
    /// - Parameter format: The date format string (e.g., "yyyy-MM-dd")
    /// - Returns: A DateFormatter configured with the specified format and current timezone
    func formatter(for format: String) -> DateFormatter {
        return queue.sync {
            if let cachedFormatter = formatterCache[format] {
                return cachedFormatter
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale.current
            
            formatterCache[format] = formatter
            return formatter
        }
    }
    
    /// Clears the formatter cache. Useful for memory management or when locale/timezone changes.
    func clearCache() {
        queue.async {
            self.formatterCache.removeAll()
        }
    }
    
    /// Pre-warms the cache with commonly used formats for better performance.
    func prewarmCache() {
        let commonFormats = [
            "yyyy-MM-dd",
            "yyyy-MM-dd hh:mm:ss",
            "dd-MM-yyyy hh:mm:ss",
            "MMM",
            "MMM yyyy",
            "dd",
            "EEEE",
            "yyyy",
            "MM"
        ]
        
        queue.async {
            for format in commonFormats {
                if self.formatterCache[format] == nil {
                    let formatter = DateFormatter()
                    formatter.dateFormat = format
                    formatter.timeZone = TimeZone.current
                    formatter.locale = Locale.current
                    self.formatterCache[format] = formatter
                }
            }
        }
    }
}
