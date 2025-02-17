//
//  Login.swift
//  test3
//
//  Created by Диана on 17.02.2025.
//

import Vapor

struct UserLoginDTO: Content {
    let email: String
    let password: String
}
