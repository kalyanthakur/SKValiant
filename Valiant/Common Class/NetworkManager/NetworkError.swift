//
//  NetworkError.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation

/// Custom error type for network operations with better error handling
enum NetworkError: LocalizedError {
    case invalidURL(String)
    case noInternetConnection
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case httpError(Int, String?)
    case tokenExpired
    case unknown(Error?)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .noInternetConnection:
            return "The Internet connection appears to be offline."
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .httpError(let code, let message):
            return message ?? "HTTP error with status code: \(code)"
        case .tokenExpired:
            return "User Token Expired"
        case .unknown(let error):
            return error?.localizedDescription ?? "An unknown error occurred"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidURL:
            return "The provided URL string is not valid"
        case .noInternetConnection:
            return "Device is not connected to the internet"
        case .noData:
            return "Server response contained no data"
        case .decodingError:
            return "Response data could not be decoded"
        case .encodingError:
            return "Request parameters could not be encoded"
        case .httpError(let code, _):
            return "HTTP request failed with status code: \(code)"
        case .tokenExpired:
            return "Authentication token has expired"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}