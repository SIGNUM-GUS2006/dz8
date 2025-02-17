//
//  Response.swift
//  test3
//
//  Created by Диана on 17.02.2025.
//
import Vapor

struct UserResponseDTO: Content {
    let id: UUID?
    let name: String
    let email: String
}
