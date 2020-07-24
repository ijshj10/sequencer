#include "io_rw.h"
#include "io_map.h"

#include <stdio.h>

#ifdef _cplusplus
extern "C"{
#endif
#ifndef UART_H
#define UART_H

static const uint32_t uart_base = get_slot_addr(BRIDGE_BASE, S1_UART);
static enum{
	rd_data_reg=0,
	dvsr_reg=1,
	wr_data_reg=2,
	rx_rd_data_reg=3
};

static enum{
	tx_full_field = 0x00000200,
	rx_empty_field = 0x00000100,
	data_field = 0x000000ff
};

int rx_empty(){
	uint32_t rd_word;

	rd_word = io_read(uart_base, rd_data_reg);
	return (rd_word & rx_empty_field);
}

int tx_full(){
	uint32_t rd_word;

	rd_word = io_read(uart_base, rd_data_reg);
	return (rd_word & tx_full_field);
}

int write_byte(uint8_t c){
	if(tx_full())
		return -1;
	io_write(uart_base, wr_data_reg, c);
	return 0;
}

int read_byte(){
	if(rx_empty())
		return -1;
	int data =  io_read(uart_base, rd_data_reg)&data_field;
	io_write(uart_base, rx_rd_data_reg, 0);
	return data;
}

int read_blocking(){
	char c;
	while((c =read_byte()) == -1);
	return c;
}

void uart_print(char *p){
	while(*p)
		write_byte(*(p++));
}

static uint8_t buffer[8];

uint32_t read_uint32(){
	for(int i=0; i<4; i++)
		buffer[i] = read_blocking();
	return *(uint32_t *)buffer;
}

uint64_t read_uint64(){
	for(int i=0; i<8; i++)
		buffer[i] = read_blocking();
	return *(uint64_t *)buffer;
}

#define DEBUG_ON
#ifdef DEBUG_ON
char print_buffer[256];
#define DEBUG(...) sprintf(print_buffer, __VA_ARGS__); uart_print(print_buffer)
#else
#define DEBUG(fmt, ...) (void)
#endif


#endif
#ifdef _cplusplus
}
#endif
