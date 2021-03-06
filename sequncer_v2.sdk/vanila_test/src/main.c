#include <stdint.h>
#include "uart.h"
#include "timer.h"
#include "rto.h"
#define BUFFER_SIZE 256



void get_cmd(){
	uint32_t len;
	rto_time_t rto_time;
	uint32_t cmd;

	len = read_uint32();
	DEBUG("LEN:%d\n",len);
	for(uint32_t i=0; i<len; ++i){
		rto_time.lower = read_uint32();
		rto_time.upper = read_uint32();
		cmd = read_uint32();
		DEBUG("CMD %d %d %d\n", rto_time.upper, rto_time.lower, cmd);
		send_rto_cmd(rto_time, cmd);
	}
}

void interact(){
	char cmd;
	DEBUG("GOT INTERACTIVE\r\n");
	while(1){
		if((cmd = read_blocking()) == 'x')
			break;
		if(cmd == 'a'){
			DEBUG("%d\n", get_buffer_status());
			rto_time_t rto_time;
			rto_time = get_head_time();
			DEBUG("%d %d\n", rto_time.upper, rto_time.lower);
			DEBUG("%d\n", get_head_cmd());
		}
	}
}

int main(){
	DEBUG("%d\n", get_buffer_status());
	timer_init();
	while(1){
		pause();
		clear();
		DEBUG("%d\n", get_buffer_status());
		get_cmd();
		go();
		interact();
		DEBUG("DONE\r\n");
	}
}
