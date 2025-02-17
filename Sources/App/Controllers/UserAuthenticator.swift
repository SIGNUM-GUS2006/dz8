//
//  UserAuthenticator.swift
//  test3
//
//  Created by Диана on 17.02.2025.
//

import Vapor
import JWT

struct UserAuthenticator: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Получаем токен из заголовков запроса
        guard let token = try? req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Missing or invalid token")
        }

        // Декодируем и верифицируем токен
        let payload: UserPayload = try req.jwt.verify(token, as: UserPayload.self)

        // Ищем пользователя по ID из payload
        guard let user = try await User.find(payload.userId, on: req.db) else {
            throw Abort(.unauthorized, reason: "User not found")
        }

        // Логиним пользователя
        req.auth.login(user)
        
        // Передаем выполнение следующему обработчику
        return try await next.respond(to: req)
    }
}

struct UserPayload: JWTPayload {
    var userId: UUID
    var exp: ExpirationClaim

    // Метод верификации срока действия токена
    func verify(using signer: JWTSigner) throws {
        // Проверка срока действия токена (если необходимо)
        try exp.verifyNotExpired()
    }
}
