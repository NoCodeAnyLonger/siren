//
//  CodableExtension.swift
//  siren
//
//  Created by danqin chu on 2024/3/29.
//  Copyright © 2024 danqin chu. All rights reserved.
//

import Foundation

extension Encodable {
    
    func toJSON() -> Dictionary<String, Any>? {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: jsonData) as? Dictionary<String, Any>
        } catch {
            print("Encode dict error:", error.localizedDescription, "object \(self)")
            return nil
        }
    }
    
}

extension Decodable {
    
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Self.self, from: data)
        return decoded
    }
    
    static func deserialize(from params: Dictionary<String, Any>) -> Self? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params)
            return try decode(data: jsonData)
        } catch {
            print("Decode error:", error.localizedDescription, "dict: \(params) -> \(type(of: Self.self))")
            return nil
        }
    }
    
    static func deserialize(from str: String) -> Self? {
        do {
            if let jsonData = str.data(using: .utf8) {
                return try decode(data: jsonData)
            } else {
                return nil
            }
        } catch {
            print("Decode error:", error.localizedDescription, "string: \(str) -> \(type(of: Self.self))")
            return nil
        }
    }
    
}


struct WhateverDecodable: Decodable {
}

extension Dictionary {
    
    static func initialize(from str: String) -> Dictionary<Key, Value>? {
        do {
            if let jsonData = str.data(using: .utf8) {
                let dict = try JSONSerialization.jsonObject(with: jsonData)
                return dict as? Dictionary<Key, Value>
            } else {
                return nil
            }
        } catch {
            print("Dictionary initialize error:", error.localizedDescription, "string: \(str)")
            return nil
        }
    }
    
    func optionalValueForKeys<T>(_ keys: [Key], defaultValue: T? = nil) -> T? {
        for k in keys {
            if let v = self[k] {
                return v as? T
            }
        }
        return defaultValue
    }
    
    func valueForKeys<T>(_ keys: [Key], defaultValue: T) -> T {
        for k in keys {
            if let v = self[k] as? T {
                return v
            }
        }
        return defaultValue
    }
    
}
