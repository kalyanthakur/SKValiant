//
//  NetworkManagerProtocol.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation

/// Protocol for network operations - enables dependency injection and testing
protocol NetworkManagerProtocol {
    func executeServiceWithURL(
        urlString: String,
        postParameters: [String: Any]?,
        callback: @escaping (_ response: JSON?, _ error: NSError?) -> Void
    )
    
    func sendMultipartPostData(
        _ urlString: String,
        withParam paramDict: [String: Any],
        callback: @escaping (_ status: Bool, _ taskError: Error?) -> Void
    )
    
    func postRequestWithMultipPart(
        _ urlString: String,
        withParam paramDict: [String: Any],
        callback: @escaping (_ json: NSDictionary?, _ taskError: Error?) -> Void
    )
    
    func invalidateCache(for urlString: String)
    func clearAllCache()
}

/// Extension to make NetworkManager conform to NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {
    // NetworkManager already implements all required methods
    // This extension makes it conform to the protocol
}