//
//  SessionModel.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-06-28.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import Foundation

enum AuthTypes: Int, Codable {
    case email
    case google
}

struct SessionModel: Codable {
    var authType: AuthTypes?
    var authToken: String?
    var email: String?
    var password: String?
    var familyName: String?
    var mongoID: String?
    var memberMongoID: String?
    var memberName: String?
    var memberDeviceToken: String?
    
    init(authType: AuthTypes? = nil,
         authToken: String? = nil,
         email: String? = nil,
         password: String? = nil,
         familyName: String? = nil,
         mongoID: String? = nil,
         memberMongoID: String? = nil,
         memberName: String? = nil,
         memberDeviceToken: String? = nil) {
        self.authType = authType
        self.authToken = authToken
        self.email = email
        self.password = password
        self.familyName = familyName
        self.mongoID = mongoID
        self.memberMongoID = memberMongoID
        self.memberName = memberName
        self.memberDeviceToken = memberDeviceToken
    }
    
    private enum CodingKeys: String, CodingKey {
        case authType
        case email
        case password
        case mongoID
        case memberMongoID
        case memberDeviceToken
    }
}
