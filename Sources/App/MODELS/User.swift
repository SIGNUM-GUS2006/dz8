//
//  User.swift
//  test3
//
//  Created by Диана on 27.01.2025.
//

import Vapor
import Fluent
import JWT

final class User: Model, Content, Authenticatable {
    static let schema = "users" // Название таблицы в базе данных

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    init() {}

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}
