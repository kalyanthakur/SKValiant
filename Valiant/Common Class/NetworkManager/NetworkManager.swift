//
//  NetworkManager.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import UIKit

class NetworkManager: NSObject {
    
    static let sharedInstance = NetworkManager()
    private var jsonStrings:String?
    private let cacheManager = ResponseCacheManager.shared
    
    // Shared URLSession with caching enabled
    private lazy var cachedSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        // Enable URL cache
        configuration.urlCache = ResponseCacheManager.shared.cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }()
    
    func executeServiceWithURL(
        urlString: String,
        postParameters: [String: Any]?,
        callback: @escaping (_ response: JSON?, _ error: NSError?) -> Void
    ) {
        Logger.logURL(urlString)

        // Prepare request body
        var jsonString: String?
        if let postParameters {
            do {
                Logger.logParameters(postParameters)
                let jsonData = try JSONSerialization.data(withJSONObject: postParameters, options: .prettyPrinted)
                jsonString = String(data: jsonData, encoding: .utf8)
            } catch {
                Logger.error("Failed to serialize request parameters", error: error)
            }
        }

        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            Logger.network("Invalid URL: \(urlString)", level: .error)
            return
        }

        var request = URLRequest(url: url)
        let httpMethod =   (urlString == WEBURL.getSpogHomeData || urlString == WEBURL.spogAlerts || urlString == WEBURL.getSpogEvents || urlString == WEBURL.getSpogPresidentsMessages || urlString == WEBURL.deleteAccount || urlString == WEBURL.getBookmarkList) ? "POST" : (postParameters == nil ? "GET" : "POST")
        request.httpMethod = httpMethod

        // Set cache policy based on endpoint
        request.cachePolicy = cacheManager.cachePolicy(for: urlString, httpMethod: httpMethod)
        
        // Set cache headers
        cacheManager.setCacheHeaders(for: &request, urlString: urlString)

        // Set Content-Type for POST requests (even if body is empty)
        if httpMethod == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let token = appUserDefaults.userData?.token {
            Logger.network("Adding authentication token to request", level: .debug)
            request.setValue(token, forHTTPHeaderField: "token")
        }

        if let jsonString {
            request.httpBody = jsonString.data(using: .utf8)
        } else if httpMethod == "POST" {
            // For POST requests with no body, send empty JSON object
            request.httpBody = "{}".data(using: .utf8)
        }
        
        // Check cache first for GET requests
        if httpMethod == "GET" && cacheManager.shouldCache(urlString: urlString) {
            if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                // Use cached response immediately
                DispatchQueue.main.async {
                    self.handleResponse(data: cachedResponse.data, callback: callback, isFromCache: true)
                }
                
                // Still fetch fresh data in background for next time (stale-while-revalidate pattern)
                // Use a silent callback that doesn't notify the caller
                if Reachability.isConnectedToNetwork() {
                    fetchFreshDataSilently(request: request)
                }
                return
            }
        }
        
        // Check for Internet before making network request
        guard Reachability.isConnectedToNetwork() else {
            // Try to use cached data if available
            if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                DispatchQueue.main.async {
                    LoadingIndicatorView.hide()
                    self.handleResponse(data: cachedResponse.data, callback: callback, isFromCache: true)
                }
                return
            }
            
            LoadingIndicatorView.hide()
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "The Internet connection appears to be offline.")
            return
        }

        // Perform request
        fetchFreshData(request: request, callback: callback)
    }
    
    /// Fetches fresh data silently in background (for stale-while-revalidate)
    private func fetchFreshDataSilently(request: URLRequest) {
        let dataTask = cachedSession.dataTask(with: request) { taskData, taskResponse, _ in
                // Silently update cache, don't call callback
            if let _ = taskData,
               let _ = taskResponse as? HTTPURLResponse,
               self.cacheManager.shouldCache(urlString: request.url?.absoluteString ?? "") {
                // Cache will be automatically updated by URLSession
                Logger.network("Background cache refresh completed for: \(request.url?.absoluteString ?? "")", level: .debug)
            }
        }
        dataTask.resume()
    }
    
    /// Fetches fresh data from network
    private func fetchFreshData(request: URLRequest, callback: @escaping (_ response: JSON?, _ error: NSError?) -> Void) {
        let dataTask = cachedSession.dataTask(with: request) { [weak self] taskData, taskResponse, taskError in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Handle network error first
                if let error = taskError as NSError? {
                    // If network error and we have cache, try to use it
                    if let cachedResponse = self.cacheManager.getCachedResponse(for: request) {
                        self.handleResponse(data: cachedResponse.data, callback: callback, isFromCache: true)
                        return
                    }
                    callback(nil, error)
                    return
                }

                // Parse response
                guard let taskData = taskData else {
                    // Try cache if available
                    if let cachedResponse = self.cacheManager.getCachedResponse(for: request) {
                        self.handleResponse(data: cachedResponse.data, callback: callback, isFromCache: true)
                        return
                    }
                    callback(nil, NSError(domain: "NoData", code: -1, userInfo: nil))
                    return
                }

                // Cache the response if it's cacheable
                // URLSession automatically caches responses based on cache policy and headers
                // No need to manually store here as URLSession handles it

                self.handleResponse(data: taskData, callback: callback, isFromCache: false)
            }
        }

        dataTask.resume()
    }
    
    /// Handles response data (from cache or network)
    private func handleResponse(data: Data, callback: @escaping (_ response: JSON?, _ error: NSError?) -> Void, isFromCache: Bool) {
        do {
            let stringResponse = String(data: data, encoding: .utf8) ?? ""
            Logger.logResponse(stringResponse, isFromCache: isFromCache)

            if let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSDictionary {
                Logger.network("Parsed JSON dictionary response", level: .debug)

                // Check for unauthorized/token expiration - check both message and status code
                let status = dict["status"] as? Int
                let message = dict["message"] as? String
                let isUnauthorized = (status == 401) || 
                                    (message?.lowercased().contains("unauthorized") == true) ||
                                    (message?.lowercased().contains("token expired") == true)
                
                if isUnauthorized {
                    // Handle token expiration → navigate to Login
                    Logger.network("User token expired or unauthorized", level: .warning)
                    
                    // Clear user data
                    appUserDefaults.userData = nil
                    
                    // Navigate to login screen from anywhere
                    DispatchQueue.main.async {
                        // Hide loading indicator first
                        LoadingIndicatorView.hide()
                        NavigationCoordinator.shared.navigateToLoginUIKit()
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: message ?? "Session expired. Please login again.")
                    }
                    
                    // Don't call callback - navigation handles the flow
                    return

                } else {
                    callback(JSON(dict), nil)
                }

            } else if let arr = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSArray {
                Logger.network("Parsed JSON array response", level: .debug)
                callback(JSON(arr), nil)
            }

        } catch let parseError as NSError {
            Logger.error("JSON parse error", error: parseError)
            callback(nil, parseError)
        }
    }
    
    /// Invalidates cache for a specific endpoint
    func invalidateCache(for urlString: String) {
        cacheManager.invalidateCache(for: urlString)
    }
    
    /// Clears all cached responses
    func clearAllCache() {
        cacheManager.clearAllCache()
    }
    
    // MARK: - Async/Await Methods
    
    /// Modern async/await version of executeServiceWithURL
    /// - Parameters:
    ///   - urlString: The URL string for the request
    ///   - postParameters: Optional POST parameters
    /// - Returns: JSON response object
    /// - Throws: NetworkError for various failure scenarios
    func executeServiceWithURL(
        urlString: String,
        postParameters: [String: Any]? = nil
    ) async throws -> JSON {
        Logger.logURL(urlString)
        
        // Prepare request body
        var jsonString: String?
        if let postParameters {
            do {
                Logger.logParameters(postParameters)
                let jsonData = try JSONSerialization.data(withJSONObject: postParameters, options: .prettyPrinted)
                jsonString = String(data: jsonData, encoding: .utf8)
            } catch {
                Logger.error("Failed to serialize request parameters", error: error)
                throw NetworkError.encodingError(error)
            }
        }
        
        // Validate and encode URL
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            Logger.network("Invalid URL: \(urlString)", level: .error)
            throw NetworkError.invalidURL(urlString)
        }
        
        var request = URLRequest(url: url)
        let httpMethod = (urlString == WEBURL.spogAlerts || urlString == WEBURL.getSpogEvents || urlString == WEBURL.getSpogPresidentsMessages || urlString == WEBURL.deleteAccount || urlString == WEBURL.getBookmarkList) ? "POST" : (postParameters == nil ? "GET" : "POST")
        request.httpMethod = httpMethod
        
        // Set cache policy based on endpoint
        request.cachePolicy = cacheManager.cachePolicy(for: urlString, httpMethod: httpMethod)
        
        // Set cache headers
        cacheManager.setCacheHeaders(for: &request, urlString: urlString)
        
        // Set Content-Type for POST requests (even if body is empty)
        if httpMethod == "POST" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Add authentication token if available
        if let token = appUserDefaults.userData?.token {
            Logger.network("Adding authentication token to request", level: .debug)
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        if let jsonString {
            request.httpBody = jsonString.data(using: .utf8)
        } else if httpMethod == "POST" {
            // For POST requests with no body, send empty JSON object
            request.httpBody = "{}".data(using: .utf8)
        }
        
        // Check cache first for GET requests
        if httpMethod == "GET" && cacheManager.shouldCache(urlString: urlString) {
            if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                // Use cached response immediately
                Logger.network("Using cached response for: \(urlString)", level: .debug)
                let json = try handleResponseData(cachedResponse.data, isFromCache: true)
                
                // Still fetch fresh data in background for next time (stale-while-revalidate pattern)
                if Reachability.isConnectedToNetwork() {
                    Task.detached { [weak self] in
                        await self?.fetchFreshDataSilentlyAsync(request: request)
                    }
                }
                
                return json
            }
        }
        
        // Check for Internet before making network request
        guard Reachability.isConnectedToNetwork() else {
            // Try to use cached data if available
            if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                Logger.network("No internet, using cached response for: \(urlString)", level: .debug)
                return try handleResponseData(cachedResponse.data, isFromCache: true)
            }
            
            throw NetworkError.noInternetConnection
        }
        
        // Perform request
        return try await fetchFreshDataAsync(request: request)
    }
    
    /// Fetches fresh data silently in background (for stale-while-revalidate)
    private func fetchFreshDataSilentlyAsync(request: URLRequest) async {
        do {
            let (_, response) = try await cachedSession.data(for: request)
            if let _ = response as? HTTPURLResponse,
               cacheManager.shouldCache(urlString: request.url?.absoluteString ?? "") {
                Logger.network("Background cache refresh completed for: \(request.url?.absoluteString ?? "")", level: .debug)
            }
        } catch {
            // Silently fail - this is background refresh
            Logger.network("Background cache refresh failed: \(error.localizedDescription)", level: .debug)
        }
    }
    
    /// Fetches fresh data from network using async/await
    private func fetchFreshDataAsync(request: URLRequest) async throws -> JSON {
        do {
            let (data, response) = try await cachedSession.data(for: request)
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try cache if available on error
                    if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                        Logger.network("HTTP error, using cached response", level: .debug)
                        return try handleResponseData(cachedResponse.data, isFromCache: true)
                    }
                    throw NetworkError.httpError(httpResponse.statusCode, nil)
                }
            }
            
            return try handleResponseData(data, isFromCache: false)
            
        } catch let error as NetworkError {
            // If network error and we have cache, try to use it
            if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                Logger.network("Network error, using cached response", level: .debug)
                return try handleResponseData(cachedResponse.data, isFromCache: true)
            }
            throw error
        } catch {
            // If network error and we have cache, try to use it
            if let cachedResponse = cacheManager.getCachedResponse(for: request) {
                Logger.network("Network error, using cached response", level: .debug)
                return try handleResponseData(cachedResponse.data, isFromCache: true)
            }
            throw NetworkError.unknown(error)
        }
    }
    
    /// Handles response data (from cache or network) - async version
    private func handleResponseData(_ data: Data, isFromCache: Bool) throws -> JSON {
        let stringResponse = String(data: data, encoding: .utf8) ?? ""
        Logger.logResponse(stringResponse, isFromCache: isFromCache)
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSDictionary {
                Logger.network("Parsed JSON dictionary response", level: .debug)
                
                // Check for token expiration
                if let message = dict["message"] as? String, message == "Unauthorized" {
                    Logger.network("User token expired", level: .warning)
                    
                    // Clear user data
                    appUserDefaults.userData = nil
                    
                    // Navigate to login screen from anywhere
                    DispatchQueue.main.async {
                        // Hide loading indicator first
                        LoadingIndicatorView.hide()
                        NavigationCoordinator.shared.navigateToLoginUIKit()
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: message)
                    }
                    
                    throw NetworkError.tokenExpired
                }
                
                return JSON(dict)
                
            } else if let arr = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSArray {
                Logger.network("Parsed JSON array response", level: .debug)
                return JSON(arr)
            } else {
                throw NetworkError.decodingError(NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response is neither array nor dictionary"]))
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            Logger.error("JSON parse error", error: error)
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Modern async/await version of sendMultipartPostData
    func sendMultipartPostData(_ urlString: String, withParam paramDict: [String: Any]) async throws -> Bool {
        // Check for Internet
        guard Reachability.isConnectedToNetwork() else {
            throw NetworkError.noInternetConnection
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for (key, value) in paramDict {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(key)\""
            body += "\r\n\r\n\(value)\r\n"
        }
        body += "--\(boundary)--\r\n"
        
        guard let postData = body.data(using: .utf8) else {
            throw NetworkError.encodingError(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"]))
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        // Add authentication token if available
        if let token = appUserDefaults.userData?.token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        Logger.logURL(urlString)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let result = String(data: data, encoding: .utf8) else {
                throw NetworkError.decodingError(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
            }
            
            if result == "success" || result == "1" {
                return true
            } else {
                throw NetworkError.httpError(-1, "Server returned: \(result)")
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    /// Modern async/await version of postRequestWithMultipPart
    func postRequestWithMultipPart(_ urlString: String, withParam paramDict: [String: Any]) async throws -> NSDictionary {
        // Check for Internet
        guard Reachability.isConnectedToNetwork() else {
            throw NetworkError.noInternetConnection
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for (key, value) in paramDict {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(key)\""
            body += "\r\n\r\n\(value)\r\n"
        }
        body += "--\(boundary)--\r\n"
        
        guard let postData = body.data(using: .utf8) else {
            throw NetworkError.encodingError(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"]))
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        // Add authentication token if available
        if let token = appUserDefaults.userData?.token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        Logger.logURL(urlString)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Try parsing as array
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSArray {
                let dict = NSMutableDictionary()
                dict.setValue(json, forKey: "response")
                return dict
            }
            
            // Try parsing as dictionary
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSDictionary {
                // Check for token expiration
                if let message = json["message"] as? String, message == "Unauthorized" {
                    // Clear user data
//                    appUserDefaults.userData = nil
//                    appUserDefaults.studentData = nil
                    
                    // Navigate to login screen from anywhere
                    DispatchQueue.main.async {
                        // Hide loading indicator first
                        LoadingIndicatorView.hide()
                        NavigationCoordinator.shared.navigateToLoginUIKit()
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: message)
                    }
                    
                    throw NetworkError.tokenExpired
                }
                
                return json
            }
            
            // If neither array nor dictionary, return error
            throw NetworkError.decodingError(NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response is neither array nor dictionary"]))
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    
    func sendMultipartPostData(_ urlString:String, withParam paramDict:[String: Any],callback:@escaping (_ status:Bool,_ taskError:Error?)->Void)
    {
        // Check for Internet
        guard Reachability.isConnectedToNetwork() else {
            LoadingIndicatorView.hide()
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "The Internet connection appears to be offline.")
            callback(false, NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]))
            return
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            LoadingIndicatorView.hide()
            let error = NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            callback(false, error)
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for (key, value) in paramDict {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(key)\""
            body += "\r\n\r\n\(value)\r\n"
        }
        body += "--\(boundary)--\r\n"
        
        guard let postData = body.data(using: .utf8) else {
            LoadingIndicatorView.hide()
            let error = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])
            callback(false, error)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30 // Reasonable timeout instead of infinity
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        // Add authentication token if available
        if let token = appUserDefaults.userData?.token {
            request.setValue(token, forHTTPHeaderField: "token")
        }

        // Perform async request without blocking
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                LoadingIndicatorView.hide()
                
                if let error = error {
                    callback(false, error)
                    return
                }
                
                guard let data = data else {
                    let noDataError = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])
                    callback(false, noDataError)
                    return
                }
                
                guard let result = String(data: data, encoding: .utf8) else {
                    let decodeError = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"])
                    callback(false, decodeError)
                    return
                }
                
                if result == "success" || result == "1" {
                    callback(true, nil)
                } else {
                    let error = NSError(domain: "ServerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server returned: \(result)"])
                    callback(false, error)
                }
            }
        }

        task.resume()
    }
    
    func postRequestWithMultipPart(_ urlString:String, withParam paramDict:[String: Any],callback:@escaping (_ json:NSDictionary?,_ taskError:Error?)->Void)
    {
        // Check for Internet
        guard Reachability.isConnectedToNetwork() else {
            LoadingIndicatorView.hide()
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "The Internet connection appears to be offline.")
            let error = NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."])
            callback(nil, error)
            return
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            LoadingIndicatorView.hide()
            let error = NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            callback(nil, error)
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for (key, value) in paramDict {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(key)\""
            body += "\r\n\r\n\(value)\r\n"
        }
        body += "--\(boundary)--\r\n"
        
        guard let postData = body.data(using: .utf8) else {
            LoadingIndicatorView.hide()
            let error = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])
            callback(nil, error)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30 // Reasonable timeout instead of infinity
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        // Add authentication token if available
        if let token = appUserDefaults.userData?.token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        Logger.logURL(urlString)
        
        // Perform async request without blocking
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                LoadingIndicatorView.hide()
                
                // Handle network error
                if let error = error {
                    callback(nil, error)
                    return
                }
                
                // Handle missing data
                guard let taskD = data else {
                    let noDataError = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])
                    callback(nil, noDataError)
                    return
                }
                
                do {
                    // Try parsing as array
                    if let json = try JSONSerialization.jsonObject(with: taskD, options: .mutableLeaves) as? NSArray {
                        let dict = NSMutableDictionary()
                        dict.setValue(json, forKey: "response")
                        callback(dict, nil)
                        return
                    }
                    
                    // Try parsing as dictionary
                    if let json = try JSONSerialization.jsonObject(with: taskD, options: .mutableLeaves) as? NSDictionary {
                        // Check for token expiration
                        if let message = json["message"] as? String, message == "Unauthorized" {
                            // Clear user data
//                            appUserDefaults.userData = nil
//                            appUserDefaults.studentData = nil
                            
                            // Navigate to login screen from anywhere
                            // Hide loading indicator first
                            LoadingIndicatorView.hide()
                            NavigationCoordinator.shared.navigateToLoginUIKit()
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: message)
                            callback(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: message]))
                        } else {
                            callback(json, nil)
                        }
                        return
                    }
                    
                    // If neither array nor dictionary, return error
                    let parseError = NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response is neither array nor dictionary"])
                    callback(nil, parseError)
                    
                } catch let error as NSError {
                    Logger.error("Multipart request error", error: error)
                    callback(nil, error)
                }
            }
        }

        task.resume()
    }
    
    // MARK: - Multipart Upload with File Support
    
    /// Uploads multipart form data with file support (for images, documents, etc.)
    /// - Parameters:
    ///   - urlString: The URL string for the request
    ///   - parameters: Dictionary of text parameters (String keys and String values)
    ///   - imageData: Optional image data to upload
    ///   - imageKey: The field name for the image (default: "profileImage")
    ///   - callback: Completion handler with JSON response and error
    func uploadMultipartWithFile(
        urlString: String,
        parameters: [String: String],
        imageData: Data?,
        imageKey: String = "profileImage",
        callback: @escaping (_ json: NSDictionary?, _ taskError: Error?) -> Void
    ) {
        // Check for Internet
        guard Reachability.isConnectedToNetwork() else {
            LoadingIndicatorView.hide()
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "The Internet connection appears to be offline.")
            let error = NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."])
            callback(nil, error)
            return
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            LoadingIndicatorView.hide()
            let error = NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            callback(nil, error)
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Add text parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image file if provided
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body
        
        // Add authentication token if available
        if let token = appUserDefaults.userData?.token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        Logger.logURL(urlString)
        
        // Perform async request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                LoadingIndicatorView.hide()
                
                // Handle network error
                if let error = error {
                    callback(nil, error)
                    return
                }
                
                // Handle missing data
                guard let taskData = data else {
                    let noDataError = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])
                    callback(nil, noDataError)
                    return
                }
                
                do {
                    // Try parsing as array
                    if let json = try JSONSerialization.jsonObject(with: taskData, options: .mutableLeaves) as? NSArray {
                        let dict = NSMutableDictionary()
                        dict.setValue(json, forKey: "response")
                        callback(dict, nil)
                        return
                    }
                    
                    // Try parsing as dictionary
                    if let json = try JSONSerialization.jsonObject(with: taskData, options: .mutableLeaves) as? NSDictionary {
                        // Check for token expiration
                        if let message = json["message"] as? String, message == "Unauthorized" {
                            LoadingIndicatorView.hide()
                            NavigationCoordinator.shared.navigateToLoginUIKit()
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: message)
                            callback(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: message]))
                        } else {
                            callback(json, nil)
                        }
                        return
                    }
                    
                    // If neither array nor dictionary, return error
                    let parseError = NSError(domain: "ParseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response is neither array nor dictionary"])
                    callback(nil, parseError)
                    
                } catch let error as NSError {
                    Logger.error("Multipart upload error", error: error)
                    callback(nil, error)
                }
            }
        }
        
        task.resume()
    }

}
