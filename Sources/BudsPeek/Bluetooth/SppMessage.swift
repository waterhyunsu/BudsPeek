import Foundation
import BudsPeekCore

struct SppMessage: Sendable {
    let messageId: MessageId
    let payload: Data
    let isResponse: Bool
    let isFragment: Bool

    init(
        messageId: MessageId,
        payload: Data = Data(),
        isResponse: Bool = false,
        isFragment: Bool = false
    ) {
        self.messageId = messageId
        self.payload = payload
        self.isResponse = isResponse
        self.isFragment = isFragment
    }

    func encode(legacy: Bool) -> Data {
        let capacity = payload.count + 7
        var output = [UInt8](repeating: 0, count: capacity)
        let count = payload.withUnsafeBytes { payloadBytes in
            output.withUnsafeMutableBufferPointer { outputBytes in
                bp_encode_message(
                    messageId.rawValue,
                    payloadBytes.bindMemory(to: UInt8.self).baseAddress,
                    payload.count,
                    isResponse ? 1 : 0,
                    isFragment ? 1 : 0,
                    legacy ? 1 : 0,
                    outputBytes.baseAddress,
                    outputBytes.count
                )
            }
        }
        guard count > 0 else { return Data() }
        return Data(output.prefix(Int(count)))
    }

    static func decode(_ data: Data) -> SppMessage? {
        guard data.count >= 7 else { return nil }
        var messageID: UInt8 = 0
        var response: UInt8 = 0
        var fragment: UInt8 = 0
        var payloadSize = 0
        var payload = [UInt8](repeating: 0, count: data.count)

        let decoded = data.withUnsafeBytes { frameBytes in
            payload.withUnsafeMutableBufferPointer { payloadBytes in
                bp_decode_message(
                    frameBytes.bindMemory(to: UInt8.self).baseAddress,
                    data.count,
                    &messageID,
                    &response,
                    &fragment,
                    payloadBytes.baseAddress,
                    payloadBytes.count,
                    &payloadSize
                )
            }
        }
        guard decoded == 1, let parsedID = MessageId(rawValue: messageID) else { return nil }
        return SppMessage(
            messageId: parsedID,
            payload: Data(payload.prefix(payloadSize)),
            isResponse: response != 0,
            isFragment: fragment != 0
        )
    }
}
