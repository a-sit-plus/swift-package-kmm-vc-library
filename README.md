# KMM VC Library Swift Package

This [Kotlin Mulitplatform](https://kotlinlang.org/docs/multiplatform.html) library implements the [W3C VC Data Model](https://w3c.github.io/vc-data-model/) to support several use cases of verifiable credentials, verifiable presentations, and validation thereof. This library may be shared between Wallet Apps, Verifier Apps and a Backend Service issuing credentials.

This repository is a Swift Package (see [documentation](https://developer.apple.com/documentation/swift_packages)) to wrap the [kmm-vc-library](https://github.com/a-sit-plus/kmm-vc-library). 

The [Package.swift](Package.swift) contains a remote binary target, which is the framework zipped attached to a Github release, in the form of <https://github.com/a-sit-plus/kmm-vc-library/releases/download/1.7.2/VcLibKMM-release.xcframework.zip>.

We'll recommend a few extensions in Swift to make using Kotlin code easier:

```Swift
import VcLibKMM

// to avoid nameclash with CyptoKit.Digest when importing both
// CryptoKit, and VcLibKMM (in other files)
public typealias VcLibKMMDigest = Digest

extension Data {
    public var kotlinByteArray : KotlinByteArray {
        let bytes = self.bytes
        let kotlinByteArray = KotlinByteArray(size: Int32(self.count))
        for index in 0..<bytes.count {
            kotlinByteArray.set(index: Int32(index), value: bytes[index])
        }
        return kotlinByteArray
    }
    
    var bytes: [Int8] {
        return self.map { Int8(bitPattern: $0)}
    }
}

extension Int8 {
    var kotlinByte : KotlinByte {
        return KotlinByte(value: self)
    }
}

extension KotlinByteArray {
    public var data : Data {
        var bytes = [UInt8]()
        for index in 0..<self.size {
            bytes.append(UInt8(bitPattern: self.get(index: index)))
        }
        return Data(bytes)
    }
}

extension Date {
    var kotlinInstant : Instant {
        return Instant.companion.fromEpochMilliseconds(epochMilliseconds: Int64(self.timeIntervalSince1970) * 1000)
    }
}

func KmmResultFailure<T>(_ error: KotlinThrowable) -> KmmResult<T> where T: AnyObject {
    return KmmResult<T>.companion.failure(error: error) as! KmmResult<T>
}

func KmmResultSuccess<T>(_ value: T) -> KmmResult<T> where T: AnyObject {
    return KmmResult<T>.companion.success(value: value) as! KmmResult<T>
}
```

The `DefaultCryptoService` for iOS should not be used in production as it does not implement encryption, decryption, key agreement and message digests correctly.

A more correct implementation in Swift, using [Apple CryptoKit](https://developer.apple.com/documentation/cryptokit/) would be:

```Swift
import Foundation
import CryptoKit

// KeyChainService.loadPrivateKey() provides a SecureEnclave.P256.Signing.PrivateKey?

public class VcLibCryptoServiceCryptoKit: CryptoService {
    
    public var jwsAlgorithm: JwsAlgorithm
    public var keyId: String
    public var certificateChain: [Data]
    private let jsonWebKey: JsonWebKey
    private let keyChainService: KeyChainService
    
    public init?(keyChainService: KeyChainService) {
        guard let privateKey = keyChainService.loadPrivateKey() else {
            return nil
        }
        self.keyChainService = keyChainService
        self.jsonWebKey = JsonWebKey.companion.fromAnsiX963Bytes(type: .ec, curve: .secp256R1, it: privateKey.publicKey.x963Representation.kotlinByteArray)!
        self.keyId = jsonWebKey.keyId!
        self.jwsAlgorithm = .es256
        self.certificateChain = []
    }
    
    public func decrypt(key: KotlinByteArray, iv: KotlinByteArray, aad: KotlinByteArray, input: KotlinByteArray, authTag: KotlinByteArray, algorithm: JweEncryption) async throws -> KmmResult<KotlinByteArray> {
        switch algorithm {
        case .a256gcm:
            let key = SymmetricKey(data: key.data)
            guard let nonce = try? AES.GCM.Nonce(data: iv.data),
                  let sealedBox = try? AES.GCM.SealedBox(nonce: nonce, ciphertext: input.data, tag: authTag.data),
                  let decryptedData = try? AES.GCM.open(sealedBox, using: key, authenticating: aad.data) else {
                return KmmResultFailure(KotlinThrowable(message: "Error in AES.GCM.open"))
            }
            return KmmResultSuccess(decryptedData.kotlinByteArray)
        default:
            return KmmResultFailure(KotlinThrowable(message: "Algorithm unknown \(algorithm)"))
        }
    }
    
    public func encrypt(key: KotlinByteArray, iv: KotlinByteArray, aad: KotlinByteArray, input: KotlinByteArray, algorithm: JweEncryption) -> KmmResult<AuthenticatedCiphertext> {
        switch algorithm {
        case .a256gcm:
            let key = SymmetricKey(data: key.data)
            guard let nonce = try? AES.GCM.Nonce(data: iv.data),
                  let encryptedData = try? AES.GCM.seal(input.data, using: key, nonce: nonce, authenticating: aad.data) else {
                return KmmResultFailure(KotlinThrowable(message: "Error in AES.GCM.seal"))
            }
            let ac = AuthenticatedCiphertext(ciphertext: encryptedData.ciphertext.kotlinByteArray, authtag: encryptedData.tag.kotlinByteArray)
            return KmmResultSuccess(ac)
        default:
            return KmmResultFailure(KotlinThrowable(message: "Algorithm unknown \(algorithm)"))
        }
    }
    
    public func generateEphemeralKeyPair(ecCurve: EcCurve) -> KmmResult<EphemeralKeyHolder> {
        switch ecCurve {
        case .secp256R1:
            return KmmResultSuccess(VcLibEphemeralKeyHolder())
        default:
            return KmmResultFailure(KotlinThrowable(message: "ecCurve unknown \(ecCurve)"))
        }
    }
    
    public func messageDigest(input: KotlinByteArray, digest: VcLibDigest) -> KmmResult<KotlinByteArray> {
        switch digest {
        case .sha256:
            let digest = SHA256.hash(data: input.data)
            let data = Data(digest.compactMap { $0 })
            return KmmResultSuccess(data.kotlinByteArray)
        default:
            return KmmResultFailure(KotlinThrowable(message: "Digest unknown \(digest)"))
        }
    }
    
    public func performKeyAgreement(ephemeralKey: EphemeralKeyHolder, recipientKey: JsonWebKey, algorithm: JweAlgorithm) -> KmmResult<KotlinByteArray> {
        switch algorithm {
        case .ecdhEs:
            let recipientKeyBytes = recipientKey.toAnsiX963ByteArray()
            if let throwable = recipientKeyBytes.exceptionOrNull() {
                return KmmResultFailure(throwable)
            }
            guard let recipientKeyBytesValue = recipientKeyBytes.getOrNull(),
                  let recipientKey = try? P256.KeyAgreement.PublicKey(x963Representation: recipientKeyBytesValue.data),
                  let ephemeralKey = ephemeralKey as? VcLibEphemeralKeyHolder,
                  let sharedSecret = try? ephemeralKey.privateKey.sharedSecretFromKeyAgreement(with: recipientKey) else {
                return KmmResultFailure(KotlinThrowable(message: "Error in KeyAgreement"))
            }
            let data = sharedSecret.withUnsafeBytes {
                return Data(Array($0))
            }
            return KmmResultSuccess(data.kotlinByteArray)
        default:
            return KmmResultFailure(KotlinThrowable(message: "Algorithm unknown \(algorithm)"))
        }
    }
    
    public func performKeyAgreement(ephemeralKey: JsonWebKey, algorithm: JweAlgorithm) -> KmmResult<KotlinByteArray> {
        switch algorithm {
        case .ecdhEs:
            guard let privateKey = keyChainService.loadPrivateKey() else {
                return KmmResultFailure(KotlinThrowable(message: "Could not load private key"))
            }
            let ephemeralKeyBytes = ephemeralKey.toAnsiX963ByteArray()
            if let throwable = ephemeralKeyBytes.exceptionOrNull() {
                return KmmResultFailure(throwable)
            }
            guard let recipientKeyBytesValue = ephemeralKeyBytes.getOrNull(),
                  let recipientKey = try? P256.KeyAgreement.PublicKey(x963Representation: recipientKeyBytesValue.data),
                  let privateAgreementKey = try? SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: privateKey.dataRepresentation),
                  let sharedSecret = try? privateAgreementKey.sharedSecretFromKeyAgreement(with: recipientKey) else {
                return KmmResultFailure(KotlinThrowable(message: "Error in KeyAgreement"))
            }
            let data = sharedSecret.withUnsafeBytes {
                return Data(Array($0))
            }
            return KmmResultSuccess(data.kotlinByteArray)
        default:
            return KmmResultFailure(KotlinThrowable(message: "Algorithm unknown \(algorithm)"))
        }
    }
    
    public func sign(input: KotlinByteArray) async throws -> KmmResult<KotlinByteArray> {
        guard let privateKey = keyChainService.loadPrivateKey() else {
            return KmmResultFailure(KotlinThrowable(message: "Could not load private key"))
        }
        guard let signature = try? privateKey.signature(for: input.data) else {
            return KmmResultFailure(KotlinThrowable(message: "Signature error"))
        }
        return KmmResultSuccess(signature.derRepresentation.kotlinByteArray)
    }
    
    public func toJsonWebKey() -> JsonWebKey {
        return jsonWebKey
    }
    
}

public class VcLibVerifierCryptoService : VerifierCryptoService {
    
    public func verify(input: KotlinByteArray, signature: KotlinByteArray, algorithm: JwsAlgorithm, publicKey: JsonWebKey) -> KmmResult<KotlinBoolean> {
        if algorithm != .es256 {
            return KmmResultFailure(KotlinThrowable(message: "Can not verify algorithm \(algorithm.name)"))
        }
        let ansiX963Result = publicKey.toAnsiX963ByteArray()
        if let throwable = ansiX963Result.exceptionOrNull() {
            return KmmResultFailure(throwable)
        }
        guard let publicKeyBytes = ansiX963Result.getOrNull(),
            let cryptoKitPublicKey = try? P256.Signing.PublicKey(x963Representation: publicKeyBytes.data) else {
            return KmmResultFailure(KotlinThrowable(message: "Can not create CryptoKit key")) 
        }
        if let cryptoKitSignature = try? P256.Signing.ECDSASignature(derRepresentation: signature.data) {
            let valid = cryptoKitPublicKey.isValidSignature(cryptoKitSignature, for: input.data)
            return KmmResultSuccess(KotlinBoolean(value: valid))
        } else if let cryptoKitSignature = try? P256.Signing.ECDSASignature(rawRepresentation: signature.data) {
            let valid = cryptoKitPublicKey.isValidSignature(cryptoKitSignature, for: input.data)
            return KmmResultSuccess(KotlinBoolean(value: valid))
        } else {
            return KmmResultFailure(KotlinThrowable(message: "Can not read signature"))
        }
    }
    
    public func extractPublicKeyFromX509Cert(it: KotlinByteArray) -> JsonWebKey? {
        guard let certificate = SecCertificateCreateWithData(nil, it.data as CFData),
              let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data else {
            return nil
        }
        return JsonWebKey.companion.fromAnsiX963Bytes(type: .ec, curve: .secp256R1, it: publicKeyData.kotlinByteArray)
    }
    
}

public class VcLibEphemeralKeyHolder : EphemeralKeyHolder {
    
    let privateKey: P256.KeyAgreement.PrivateKey
    let publicKey: P256.KeyAgreement.PublicKey
    let jsonWebKey: JsonWebKey
    
    public init() {
        self.privateKey = P256.KeyAgreement.PrivateKey()
        self.publicKey = privateKey.publicKey
        self.jsonWebKey = JsonWebKey.companion.fromAnsiX963Bytes(type: .ec, curve: .secp256R1, it: publicKey.x963Representation.kotlinByteArray)!
    }
    
    public func toPublicJsonWebKey() -> JsonWebKey {
        return jsonWebKey
    }
    
}
```

