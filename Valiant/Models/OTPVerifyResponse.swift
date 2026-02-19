//
//  OTPVerifyResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 04/02/26.
//


struct OTPVerifyResponse: Codable {
    let token: String?
    let message: String?
    let status: Int?
    let data: UserData?
}


struct UserData: Codable, Identifiable {
    let contactNo: String?
    let createdAt: String?
    let deviceToken: String?
    let dob: String?
    let email: String?
    let gender: String?
    let id: Int?
    let isDeleted: Int?
    let isOTPVerified: Int?
    let isProfileCompleted: Int?
    let name: String?
    let otp: Int?
    let profileImage: String?
    let token: String?
    let updatedAt: String?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        contactNo = try c.decodeIfPresent(String.self, forKey: .contactNo)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        deviceToken = try c.decodeIfPresent(String.self, forKey: .deviceToken)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        
        // Handle isOTPVerified - can be String, Int, or Bool
        if let stringValue = try? c.decodeIfPresent(String.self, forKey: .isOTPVerified) {
            isOTPVerified = Int(stringValue)
        } else if let intValue = try? c.decodeIfPresent(Int.self, forKey: .isOTPVerified) {
            isOTPVerified = intValue
        } else if let boolValue = try? c.decodeIfPresent(Bool.self, forKey: .isOTPVerified) {
            isOTPVerified = boolValue ? 1 : 0
        } else {
            isOTPVerified = nil
        }
        
        // Handle isProfileCompleted - can be Bool or Int
        // Handle isOTPVerified - can be String, Int, or Bool
        if let stringValue = try? c.decodeIfPresent(String.self, forKey: .isOTPVerified) {
            isDeleted = Int(stringValue)
        } else if let boolValue = try? c.decodeIfPresent(Bool.self, forKey: .isDeleted) {
            isDeleted = boolValue ? 1 : 0
        } else if let intValue = try? c.decodeIfPresent(Int.self, forKey: .isDeleted) {
            isDeleted = intValue
        } else {
            isDeleted = nil
        }
        
        // Handle isProfileCompleted - can be Bool or Int
        if let boolValue = try? c.decodeIfPresent(Bool.self, forKey: .isProfileCompleted) {
            isProfileCompleted = boolValue ? 1 : 0
        } else if let intValue = try? c.decodeIfPresent(Int.self, forKey: .isProfileCompleted) {
            isProfileCompleted = intValue
        } else {
            isProfileCompleted = nil
        }
        
        name = try c.decodeIfPresent(String.self, forKey: .name)
        
        // Handle otp - can be String or Int
        if let stringValue = try? c.decodeIfPresent(String.self, forKey: .otp) {
            otp = Int(stringValue)
        } else if let intValue = try? c.decodeIfPresent(Int.self, forKey: .otp) {
            otp = intValue
        } else {
            otp = nil
        }
        
        profileImage = try c.decodeIfPresent(String.self, forKey: .profileImage)
        token = try c.decodeIfPresent(String.self, forKey: .token)
        updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)

        let rawDob = try c.decodeIfPresent(String.self, forKey: .dob)
        dob = rawDob == "<null>" ? nil : rawDob

        let rawGender = try c.decodeIfPresent(String.self, forKey: .gender)
        gender = rawGender == "<null>" ? nil : rawGender
    }
}

