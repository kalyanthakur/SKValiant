//
//  LoginResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 30/01/26.
//

import Foundation

// MARK: - Login Response Model
struct LoginResponse: Codable {
    let message: String?
    let data: LoginUserData?
    let status: Int?
}


// MARK: - Login User Data Model
struct LoginUserData: Codable, Identifiable {
    let id: Int
    let isOTPVerified: Bool
    let isProfileCompleted: Bool
    let otp: Int?
    
    let name: String?
    let email: String?
    let contactNo: String?
    let profileImage: String?
    let token: String?
    
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case otp
        case name
        case email
        case token
        case profileImage
        case contactNo
        case createdAt
        case updatedAt
        case isOTPVerified
        case isProfileCompleted
    }
}

