//
//  Keychain.swift
//  ClipGPT
//
//  Created by tadeckar on 4/25/23.
//

import Security
import Foundation

struct KeychainService {
    static let serviceName = "ClipGPTAPIKey"
    
    static func savePassword(password: String) {
        guard let passwordData = password.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return }
    }
    
    static func getPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
            let passwordData = result as? Data,
            let password = String(data: passwordData, encoding: .utf8) else { return nil }
        
        return password
    }
}
