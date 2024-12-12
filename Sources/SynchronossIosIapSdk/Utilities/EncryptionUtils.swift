import CryptoKit
import Foundation

struct EncryptionUtils {
    static func generateUUID(from userId: String) -> UUID {
        let data = Data(userId.utf8)
        let hash = SHA256.hash(data: data)
        let hashBytes = Array(hash)

        return UUID(uuid: (
            hashBytes[0], hashBytes[1], hashBytes[2], hashBytes[3],
            hashBytes[4], hashBytes[5], hashBytes[6], hashBytes[7],
            hashBytes[8], hashBytes[9], hashBytes[10], hashBytes[11],
            hashBytes[12], hashBytes[13], hashBytes[14], hashBytes[15]
        ))
    }
}
