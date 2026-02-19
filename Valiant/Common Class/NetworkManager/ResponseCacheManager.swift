//
//  ResponseCacheManager.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation

/// Manages response caching for API calls
class ResponseCacheManager {
    static let shared = ResponseCacheManager()
    
    let cache: URLCache
    private let memoryCapacity: Int = 10 * 1024 * 1024 // 10 MB memory cache
    private let diskCapacity: Int = 50 * 1024 * 1024   // 50 MB disk cache
    
    // Cache duration in seconds for different endpoint types
    private let cacheDurations: [String: TimeInterval] = [
        "announcements": 300,      // 5 minutes
        "events": 600,              // 10 minutes
        "forms": 1800,             // 30 minutes
        "schedule": 3600,          // 1 hour
        "notifications": 60,        // 1 minute (frequent updates)
        "query_history": 300,      // 5 minutes
        "profile": 1800,           // 30 minutes
        "attendance": 600,          // 10 minutes
        "performance": 1800        // 30 minutes
    ]
    
    // Endpoints that should never be cached (sensitive operations)
    private let nonCacheableEndpoints: [String] = [
        "sendOTP",
        "verifyOTP",
        "report_query",
        "markNotificationRead",
        "updateProfile",
        "update_device_token"
    ]
    
    private init() {
        // Configure URLCache
        cache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "khalsa_api_cache"
        )
        
        // Set as shared cache
        URLCache.shared = cache
    }
    
    /// Determines if an endpoint should be cached
    func shouldCache(urlString: String) -> Bool {
        // Don't cache POST requests by default (except specific GET-like POSTs)
        // Don't cache sensitive endpoints
        for endpoint in nonCacheableEndpoints {
            if urlString.contains(endpoint) {
                return false
            }
        }
        
        // Cache GET requests and specific POST endpoints that are safe to cache
        return urlString.contains("get") || 
               urlString.contains("show") || 
               urlString.contains("fetch")  // Schedule is safe to cache
    }
    
    /// Gets cache duration for a specific endpoint
    func getCacheDuration(for urlString: String) -> TimeInterval {
        for (key, duration) in cacheDurations {
            if urlString.contains(key) {
                return duration
            }
        }
        // Default cache duration: 5 minutes
        return 300
    }
    
    /// Creates a cache policy for a request
    func cachePolicy(for urlString: String, httpMethod: String) -> URLRequest.CachePolicy {
        if !shouldCache(urlString: urlString) {
            return .reloadIgnoringLocalCacheData
        }
        
        // For cacheable GET requests, use cache with network fallback
        if httpMethod == "GET" {
            return .returnCacheDataElseLoad
        }
        
        // For POST requests that are safe to cache
        return .returnCacheDataElseLoad
    }
    
    /// Invalidates cache for a specific URL
    func invalidateCache(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        cache.removeCachedResponse(for: URLRequest(url: url))
    }
    
    /// Invalidates cache for all URLs containing a specific endpoint pattern
    func invalidateCacheForEndpoint(_ endpoint: String) {
        // Since URLCache doesn't provide enumeration, we invalidate by known URL patterns
        // This should be called with the base URL pattern
        if let baseURL = URL(string: WEBURL.baseURL + endpoint) {
            cache.removeCachedResponse(for: URLRequest(url: baseURL))
        }
    }
    
    /// Invalidates related caches after data modification
    /// For example, after updating profile, invalidate profile and related caches
    func invalidateRelatedCaches(for operation: String) {
        switch operation {
        case "updateProfile":
            invalidateCacheForEndpoint("myProfile")
            invalidateCacheForEndpoint("profile")
        case "reportQuery":
            invalidateCacheForEndpoint("get_report_query")
            invalidateCacheForEndpoint("query_history")
        case "markNotificationRead":
            invalidateCacheForEndpoint("notification_list")
            invalidateCacheForEndpoint("notifications")
        default:
            break
        }
    }
    
    /// Clears all cached responses
    func clearAllCache() {
        cache.removeAllCachedResponses()
    }
    
    /// Gets cached response if available and not expired
    func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard let cachedResponse = cache.cachedResponse(for: request) else {
            return nil
        }
        
        // Check if cache is expired based on cache-control headers or our custom logic
        if let httpResponse = cachedResponse.response as? HTTPURLResponse,
           let _ = httpResponse.value(forHTTPHeaderField: "Cache-Control") {
            // Parse cache-control header if present
            // For now, we'll rely on URLSession's built-in cache validation
        }
        
        return cachedResponse
    }
    
    /// Sets custom cache headers for a request
    func setCacheHeaders(for request: inout URLRequest, urlString: String) {
        if shouldCache(urlString: urlString) {
            let cacheDuration = getCacheDuration(for: urlString)
            // Set cache-control header
            request.setValue("max-age=\(Int(cacheDuration))", forHTTPHeaderField: "Cache-Control")
        } else {
            // Prevent caching for sensitive endpoints
            request.setValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
            request.setValue("0", forHTTPHeaderField: "Expires")
        }
    }
}
