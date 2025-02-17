//
//  UserController.swift
//  test3
//
//  Created by Диана on 27.01.2025.
//
// UserController.swift
// UserController.swift
import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    // MARK: - Route Configuration
    func boot(routes: RoutesBuilder) throws {
        print("🔥 boot(routes:) is executing!")
        
        // Public endpoints
       
        routes.post("auth", "signup", use: createUser)
        routes.post("auth", "signin", use: login)
        
        // Protected endpoints
    
        let protectedGroup = routes.grouped(UserAuthenticator())
        protectedGroup.get("check", use: checkToken)
        protectedGroup.get("user", use: getUser)
        protectedGroup.delete("drop", use: deleteUser)
    }
    
    // MARK: - User Registration
    @Sendable
    func createUser(req: Request) async throws -> UserResponseDTO {
    
        let input = try req.content.decode(UserCreateDTO.self)
        
        print("Received data: \(input)") // Логируем полученные данные
        
        guard try await User.query(on: req.db)
            .filter(\.$email == input.email)
            .first() == nil else {
            print("Email already registered") // Логируем ситуацию с существующим email
            throw Abort(.conflict, reason: "Email already registered")
        }
        
        let hashedPassword = try Bcrypt.hash(input.password)
        
        let user = User(
            name: input.name,
            email: input.email,
            passwordHash: hashedPassword
        )
        
        try await user.save(on: req.db)
        print("User saved: \(user)") // Логируем успешное сохранение пользователя
        
        return UserResponseDTO(
            id: user.id,
            name: user.name,
            email: user.email
        )
    }
    
    // MARK: - User Login
    @Sendable
    func login(req: Request) async throws -> TokenResponseDTO {
        let credentials = try req.content.decode(UserLoginDTO.self)
        
        // Find user by email
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == credentials.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        // Verify password
        guard try Bcrypt.verify(credentials.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        // Generate JWT
        let payload = UserPayload(
            userId: try user.requireID(),
            exp: .init(value: .init(timeIntervalSinceNow: 3600)) 
        )
        let token = try req.jwt.sign(payload)
        
        return TokenResponseDTO(token: token)
    }
    
    // MARK: - Token Validation
    @Sendable
    func checkToken(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        return .ok
    }
    
    // MARK: - Get User Data
    @Sendable
    func getUser(req: Request) async throws -> UserResponseDTO {
        let user = try req.auth.require(User.self)
        
        guard let user = try await User.find(user.id, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        return UserResponseDTO(
            id: user.id,
            name: user.name,
            email: user.email
        )
    }
    
    // MARK: - Delete User
    @Sendable
    func deleteUser(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        guard let user = try await User.find(user.id, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        try await user.delete(on: req.db)
        return .noContent
    }
}
