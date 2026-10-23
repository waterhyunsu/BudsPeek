#ifndef BUDSPEEK_CORE_H
#define BUDSPEEK_CORE_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Encode one Samsung SPP frame. Returns the number of output bytes, or 0 on
 * invalid input / insufficient output capacity. `legacy` selects the older FE
 * framing; otherwise the standard FD framing is used. */
size_t bp_encode_message(uint8_t message_id,
                         const uint8_t *payload,
                         size_t payload_size,
                         uint8_t is_response,
                         uint8_t is_fragment,
                         uint8_t legacy,
                         uint8_t *output,
                         size_t output_capacity);

/* Decode one complete FE, FD, or FC frame. Returns 1 on success and 0 on
 * malformed frames, unknown framing, invalid CRC, or insufficient capacity. */
int bp_decode_message(const uint8_t *frame,
                      size_t frame_size,
                      uint8_t *message_id,
                      uint8_t *is_response,
                      uint8_t *is_fragment,
                      uint8_t *payload_output,
                      size_t payload_capacity,
                      size_t *payload_size);

uint16_t bp_crc16_ccitt(const uint8_t *bytes, size_t size);

#ifdef __cplusplus
} // extern "C"
#endif
#endif
