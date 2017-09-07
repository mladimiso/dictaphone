/*
 * uart_debug.h
 *
 *  Created on: 28.08.2017.
 *      Author: kmilos
 */

#ifndef __SRC_UART_DEBUG_H__
#define __SRC_UART_DEBUG_H__


#include "xuartps.h"




void debug_UART_init(void);

void debug_UART_write_byte(unsigned long ulUARTData,
						unsigned char ucNumBytes
						);

void debug_UART_write_string(char *pcData);

unsigned char debug_UART_read_byte(unsigned long *ulUARTData);

void check_f_result(unsigned res, const char *text);

#endif /* __SRC_UART_DEBUG_H__ */
