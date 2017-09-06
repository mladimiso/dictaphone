/*
 * uart_debug.c
 *
 *  Created on: 28.08.2017.
 *      Author: kmilos
 */


#include "uart_debug.h"
#include "xparameters.h"
#include "xstatus.h"

XUartPs uart;
XUartPs_Config uart_config;

void debug_UART_init(void)
{
	uart_config.InputClockHz = XPAR_PS7_UART_1_UART_CLK_FREQ_HZ;
	uart_config.ModemPinsConnected = XPAR_PS7_UART_1_HAS_MODEM;
	XUartPs_CfgInitialize(&uart, &uart_config, XPAR_PS7_UART_1_BASEADDR);

}

unsigned char debug_UART_read_byte(unsigned long *ulUARTData)
{

	if (XUartPs_IsReceiveData(XPAR_PS7_UART_1_BASEADDR))
	{
		//while(!(XUARTPS_SR_RXEMPTY & XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_SR_OFFSET)))
		//{
			*ulUARTData = XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET);
			//XUartPs_WriteReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET, ulUARTData);
		//}
		return 1;
	}
	return 0;
}

void debug_UART_write_byte(unsigned long ulUARTData,
						unsigned char ucNumBytes
						)
{
	int i = ucNumBytes - 1;

	for (i; i >= 0; i--)
	{
		XUartPs_WriteReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET, (ulUARTData >> (8 * i)));
	}

}

void debug_UART_write_string(char *pcData)
{
	int i;
	for (i = 0; '\0' != *(pcData + i); i++)
	{
		debug_UART_write_byte(*(pcData + i), 1);
	}

}

