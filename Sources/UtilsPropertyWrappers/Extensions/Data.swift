import Foundation

extension Data {
    func jsonDecoded<D: Decodable>(_ type: D.Type, decoder: JSONDecoder = JSONDecoder()) throws -> D {
        try decoder.decode(type, from: self)
    }
}

extension Encodable {
    func jsonEncoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}
