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

#define SLV_REG(x) ((XPAR_AXI_PPM_0_BASEADDR) + (x * 4))

void print(char *str);

int main()
{
    init_platform();


    volatile char *LEDs = XPAR_LEDS_8BITS_BASEADDR;
    volatile char *SWs = XPAR_SWS_8BITS_BASEADDR;

    volatile int *slv_reg0 = SLV_REG(0);
    volatile int *slv_reg10 = SLV_REG(10);
    volatile int *slv_reg11 = SLV_REG(11);
    volatile int *slv_reg12 = SLV_REG(12);
    volatile int *slv_reg13 = SLV_REG(13);
    volatile int *slv_reg14 = SLV_REG(14);
    volatile int *slv_reg15 = SLV_REG(15);

    volatile int *slv_reg20 = SLV_REG(20);
	volatile int *slv_reg21 = SLV_REG(21);
	volatile int *slv_reg22 = SLV_REG(22);
	volatile int *slv_reg23 = SLV_REG(23);
	volatile int *slv_reg24 = SLV_REG(24);
	volatile int *slv_reg25 = SLV_REG(25);

	//1 == software, 0 == hardware
	*slv_reg0 = 0;

	/*
    //capture
    while(!(*SWs & 0x8)){
    	*LEDs = *SWs;
    	*slv_reg0 = 0;

    	printf("%d\n", *slv_reg10);
    	fflush(stdout);

    }
    */

	*slv_reg20 = 0x186a0;
	*slv_reg21 = 0x30;
	*slv_reg22 = 0x30;
	*slv_reg23 = 0x30;
	*slv_reg24 = 0x30;
	*slv_reg25 = 0x30;

    //generate
    while(!(*SWs & 0x8)){
    	*LEDs = *SWs;
    }

    print("Hello World\n\r");

    return 0;
}
