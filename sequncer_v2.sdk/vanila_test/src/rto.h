#ifndef RTO_H
#define RTO_H

#include "timer.h"

#ifdef __cplusplus
extern "C"{
#endif

const int rto_base = get_slot_addr(BRIDGE_BASE, S4_RTO);
enum {
	timer_lower_reg = 0,
	timer_upper_reg = 1,
	cmd_and_send_reg = 2, // If written, write buffer
	buffer_status_reg = 3, // {30'b0, full, empty}
	timer_upper_buffer_reg = 4,
	timer_lower_buffer_reg = 5,
	cmd_buffer_reg = 6,
	dout_reg = 7,
	rto_flush_reg = 8
};

void send_rto_cmd(rto_time_t rto_time, uint32_t cmd){
	io_write(rto_base, timer_lower_reg, rto_time.lower);
	io_write(rto_base, timer_upper_reg, rto_time.upper);
	io_write(rto_base, cmd_and_send_reg ,cmd);
}

uint32_t get_buffer_status(){
	return io_read(rto_base, buffer_status_reg);
}

rto_time_t get_head_time(){
	rto_time_t rto_time;
	rto_time.upper = io_read(rto_base, timer_upper_buffer_reg);
	rto_time.lower = io_read(rto_base, timer_lower_buffer_reg);
	return rto_time;
}

uint32_t get_head_cmd(){
	return io_read(rto_base, cmd_buffer_reg);
}

uint32_t get_dout(){
	return io_read(rto_base, dout_reg);
}

void flush_rto(){
	io_write(rto_base, rto_flush_reg, 0);
}



#ifdef __cplusplus
extern }
#endif

#endif
