#ifndef IO_H
#define IO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define io_read(base, offset) (*(volatile uint32_t *)((base) + (4*(offset))))
#define io_write(base, offset, data) (*(volatile uint32_t *)((base) +(4*(offset))) = data)
#define get_slot_addr(mmio_base, slot) ((mmio_base) + ((slot)*32*4))

#ifdef __cplusplus
}   
#endif

#endif
