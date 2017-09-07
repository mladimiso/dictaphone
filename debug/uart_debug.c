/*
 * uart_debug.c
 *
 *  Created on: 28.08.2017.
 *      Author: kmilos
 */

#include <stdio.h>
#include <string.h>

#include "uart_debug.h"
#include "xparameters.h"
#include "xstatus.h"

XUartPs uart;
XUartPs_Config uart_config;

static char debug_buff[512];

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
	while (!(XUARTPS_SR_TXEMPTY & XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_SR_OFFSET)))
	{}
}

void debug_UART_write_string(char *pcData)
{
	int i;
	for (i = 0; '\0' != *(pcData + i); i++)
	{
		debug_UART_write_byte(*(pcData + i), 1);
	}
}


void check_f_result(unsigned res, const char *text)
{
	//char *text = p_text;
	switch (res)
	{
		case 0:
			memset(debug_buff, '\0', sizeof(debug_buff));
			sprintf(debug_buff, "%s Succeeded!\n\rError Code : %d\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			break;

		case 1:
			memset(debug_buff, '\0', sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d ", text, res);
			strcat( debug_buff,	"(A hard error occurred in the low level disk I/O layer)\n\r");
			debug_UART_write_string(debug_buff);
			break;

		case 2:
			memset(debug_buff, '\0', sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Assertion failed)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 3:
			memset(debug_buff, '\0', sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d ", text, res);
			strcat(debug_buff, "(The physical drive cannot work)");
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			//debug_UART_write_string(text);

			break;

		case 4:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Could not find the file)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 5:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Could not find the path)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 6:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The path name format is invalid)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 7:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Access denied due to prohibited access or directory full)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 8:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Access denied due to prohibited access)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 9:
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The file/directory object is invalid)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 10:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The physical drive is write protected)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 11:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The logical drive number is invalid)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 12:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The volume has no work area)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 13:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (There is no valid FAT volume)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
//			memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 14:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The f_mkfs() aborted due to any parameter error)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 15:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Could not get a grant to access the volume within defined period)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 16:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (The operation is rejected according to the file sharing policy)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
//			memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 17:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (LFN working buffer could not be allocated)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 18:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Number of open files > _FS_SHARE)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		case 19:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff, "%s Failed!\n\rError Code : %d (Given parameter is invalid)\n\r",
					text,
					res);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;

		default:
			memset(debug_buff, 0, sizeof(debug_buff));
			sprintf(debug_buff,  "%s Failed!\n\rError Code : %d (Error unknown!)\n\r",
					text,
					125);
			debug_UART_write_string(debug_buff);
			//memset(debug_buff, 0, sizeof(debug_buff));
			break;


	}

}

