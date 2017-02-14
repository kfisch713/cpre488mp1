/*
 * Copyright (c) 2009-2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include <xparameters.h>
#include <limits.h>
#include <stdint.h>

#define ONE_MS 0x186a0

#define MS(x) (ONE_MS * x)

char *LEDs = (char *)XPAR_LEDS_8BITS_BASEADDR;
char *SWs = (char *)XPAR_SWS_8BITS_BASEADDR;
char *BTNs = (char *)XPAR_BTNS_5BITS_BASEADDR;

int * SLV_REG(unsigned int x){
	return ((int *)((XPAR_AXI_PPM_0_BASEADDR) + (x * 4)));
}

int LED(char x) {
	return ((*LEDs >> x) & 0x01);
}

int SW(unsigned int x) {
	return ((*SWs >> x) & 0x01);
}

int BTN(unsigned int x) {
	return ((*BTNs >> x) & 0x01);
}

void printStatus() {
	printf("Control mode : %d\nFrame Counter : %d\n", *SLV_REG(0), *SLV_REG(1));
	printf("%d, %d, %d, %d, %d, %d\n", *SLV_REG(10), *SLV_REG(11), *SLV_REG(12), *SLV_REG(13), *SLV_REG(14), *SLV_REG(15));
	printf("%d, %d, %d, %d, %d, %d\n", *SLV_REG(20), *SLV_REG(21), *SLV_REG(22), *SLV_REG(23), *SLV_REG(24), *SLV_REG(25));
}

int main()
{
	static float channel_0 = 0, channel_1 = 0, channel_2 = 0, channel_3 = 0, channel_4 = 0, channel_5 = 0;
    init_platform();

	printf("\033\143");
	printf("Welcome to quad sim -4.0\n");
	printf("\033\143");
    while (!(BTN(0))){
    	//1 == software, 0 == hardware
    	*SLV_REG(0) = SW(0);

    	// Software passthrough..doesn't work. So I'm supplying my own signal
		*SLV_REG(20) = MS(channel_0);
		*SLV_REG(21) = MS(channel_0);
		*SLV_REG(22) = MS(channel_0);
		*SLV_REG(23) = MS(channel_0);
		*SLV_REG(24) = MS(channel_0);
		*SLV_REG(25) = MS(channel_0);

		if (SW(1)) {
			printStatus();
		} else if (SW(2)) {
			printf("recording...\n");
		}

    }
    printf("BTNC press recognized...\n");
    return 0;
}
