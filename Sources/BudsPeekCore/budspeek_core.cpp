#include "budspeek_core.h"

#include <algorithm>
#include <array>
#include <limits>

namespace {
constexpr uint8_t kLegacyStart = 0xFE;
constexpr uint8_t kLegacyEnd = 0xEE;
constexpr uint8_t kStandardStart = 0xFD;
constexpr uint8_t kStandardEnd = 0xDD;
constexpr uint8_t kSmepStart = 0xFC;
constexpr uint8_t kSmepEnd = 0xCC;
constexpr size_t kFrameOverhead = 4; // start + size/header + end, excluding payload block
constexpr size_t kMessageBlockOverhead = 3; // id + CRC16

uint16_t crc16(const uint8_t *bytes, size_t size) {
    uint16_t crc = 0;
    for (size_t i = 0; i < size; ++i) {
        crc ^= static_cast<uint16_t>(bytes[i]) << 8;
        for (int bit = 0; bit < 8; ++bit) {
            crc = (crc & 0x8000) ? static_cast<uint16_t>((crc << 1) ^ 0x1021)
                                 : static_cast<uint16_t>(crc << 1);
        }
    }
    return crc;
}

bool valid_crc(const uint8_t *frame, size_t frame_size, size_t message_id_offset,
               size_t payload_size) {
    const size_t crc_offset = frame_size - 3;
    const uint16_t expected = static_cast<uint16_t>(frame[crc_offset]) |
                              (static_cast<uint16_t>(frame[crc_offset + 1]) << 8);
    return crc16(frame + message_id_offset, payload_size + 1) == expected;
}
} // namespace

extern "C" uint16_t bp_crc16_ccitt(const uint8_t *bytes, size_t size) {
    if (bytes == nullptr && size != 0) return 0;
    return crc16(bytes, size);
}

extern "C" size_t bp_encode_message(uint8_t message_id,
                                     const uint8_t *payload,
                                     size_t payload_size,
                                     uint8_t is_response,
                                     uint8_t is_fragment,
                                     uint8_t legacy,
                                     uint8_t *output,
                                     size_t output_capacity) {
    if ((payload == nullptr && payload_size != 0) || output == nullptr) return 0;
    if (payload_size > std::numeric_limits<size_t>::max() - kMessageBlockOverhead) return 0;
    const size_t block_size = payload_size + kMessageBlockOverhead;
    if ((legacy && block_size > 0xFF) || (!legacy && block_size > 0x3FF)) return 0;
    const size_t frame_size = block_size + kFrameOverhead;
    if (output_capacity < frame_size) return 0;

    size_t cursor = 0;
    if (legacy) {
        output[cursor++] = kLegacyStart;
        output[cursor++] = is_response ? 1 : 0;
        output[cursor++] = static_cast<uint8_t>(block_size);
    } else {
        uint16_t header = static_cast<uint16_t>(block_size & 0x3FF);
        if (is_response) header |= 0x1000;
        if (is_fragment) header |= 0x2000;
        output[cursor++] = kStandardStart;
        output[cursor++] = static_cast<uint8_t>(header & 0xFF);
        output[cursor++] = static_cast<uint8_t>(header >> 8);
    }

    const size_t message_id_offset = cursor;
    output[cursor++] = message_id;
    if (payload_size != 0) {
        std::copy(payload, payload + payload_size, output + cursor);
        cursor += payload_size;
    }
    const uint16_t crc = crc16(output + message_id_offset, payload_size + 1);
    output[cursor++] = static_cast<uint8_t>(crc & 0xFF);
    output[cursor++] = static_cast<uint8_t>(crc >> 8);
    output[cursor++] = legacy ? kLegacyEnd : kStandardEnd;
    return cursor;
}

extern "C" int bp_decode_message(const uint8_t *frame,
                                  size_t frame_size,
                                  uint8_t *message_id,
                                  uint8_t *is_response,
                                  uint8_t *is_fragment,
                                  uint8_t *payload_output,
                                  size_t payload_capacity,
                                  size_t *payload_size) {
    if (frame == nullptr || message_id == nullptr || is_response == nullptr ||
        is_fragment == nullptr || payload_size == nullptr || frame_size < 7) return 0;

    const uint8_t start = frame[0];
    const bool legacy = start == kLegacyStart;
    const bool standard = start == kStandardStart;
    const bool smep = start == kSmepStart;
    if (!legacy && !standard && !smep) return 0;
    if (frame[frame_size - 1] != (legacy ? kLegacyEnd : (smep ? kSmepEnd : kStandardEnd))) return 0;

    size_t message_id_offset = 0;
    size_t decoded_payload_size = 0;
    uint8_t response = 0;
    uint8_t fragment = 0;
    size_t declared_block_size = 0;

    if (legacy) {
        if (frame_size < 7) return 0;
        response = frame[1] == 1 ? 1 : 0;
        declared_block_size = frame[2];
        if (declared_block_size < kMessageBlockOverhead ||
            declared_block_size + kFrameOverhead != frame_size) return 0;
        message_id_offset = 3;
    } else {
        const uint16_t header = static_cast<uint16_t>(frame[1]) |
                                (static_cast<uint16_t>(frame[2]) << 8);
        declared_block_size = header & 0x3FF;
        if (declared_block_size < kMessageBlockOverhead ||
            declared_block_size + kFrameOverhead != frame_size) return 0;
        response = (header & 0x1000) ? 1 : 0;
        fragment = (header & 0x2000) ? 1 : 0;
        message_id_offset = 3;
    }

    decoded_payload_size = declared_block_size - kMessageBlockOverhead;
    if (decoded_payload_size > payload_capacity ||
        (decoded_payload_size != 0 && payload_output == nullptr)) return 0;
    if (!valid_crc(frame, frame_size, message_id_offset, decoded_payload_size)) return 0;

    *message_id = frame[message_id_offset];
    *is_response = response;
    *is_fragment = fragment;
    *payload_size = decoded_payload_size;
    if (decoded_payload_size != 0) {
        std::copy(frame + message_id_offset + 1,
                  frame + message_id_offset + 1 + decoded_payload_size,
                  payload_output);
    }
    return 1;
}
