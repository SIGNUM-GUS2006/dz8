//
//  Create.swift
//  test3
//
//  Created by Диана on 17.02.2025.
//

import Vapor

struct UserCreateDTO: Content {
    let name: String
    let email: String
    let password: String
}
