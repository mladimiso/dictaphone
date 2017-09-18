

/***************************** Include Files *******************************/
#include "VGA_IP.h"

/************************** Function Definitions ***************************/

const  char mat[38][2] = {
						{'0', 0x01},
						{'1', 0x02},
						{'2', 0x03},
						{'3', 0x04},
						{'4', 0x05},
						{'5', 0x06},
						{'6', 0x07},
						{'7', 0x08},
						{'8', 0x09},
						{'9', 0x0A},
						{'A', 0x0B},
						{'B', 0x0C},
						{'C', 0x0D},
						{'D', 0x0E},
						{'E', 0x0F},
						{'F', 0x10},
						{'G', 0x11},
						{'H', 0x12},
						{'I', 0x13},
						{'J', 0x14},
						{'K', 0x15},
						{'L', 0x16},
						{'M', 0x17},
						{'N', 0x18},
						{'O', 0x19},
						{'P', 0x1A},
						{'Q', 0x1B},
						{'R', 0x1C},
						{'S', 0x1D},
						{'T', 0x1E},
						{'U', 0x1F},
						{'V', 0x20},
						{'W', 0x21},
						{'X', 0x22},
						{'Y', 0x23},
						{'Z', 0x24},
						{' ', 0x00}
					   };

void find_character(const char c, u32 *code_char)
{
	int i;
	char c_local;
	if (0x60 < c && 0x7b > c)
	{
		c_local = c - 0x20;
	}
	else
	{
		c_local = c;
	}
	for(i = 0; i < 38; i++)
	{
		if(mat[i][0] == c_local)
		{
			*code_char = mat[i][1];
		}
	}
}

void VGA_write_character(u32 x, u32 y, char c)
{
	// x - column
	// y - row

	u32 character;
	u32 address;

	find_character(c, &character);

	address = x | (y << 7);

	VGA_IP_mWriteReg(XPAR_VGA_IP_0_CTRL_BASEADDR, VGA_IP_CTRL_SLV_REG0_OFFSET, character);  // data = char
	VGA_IP_mWriteReg(XPAR_VGA_IP_0_CTRL_BASEADDR, VGA_IP_CTRL_SLV_REG1_OFFSET, address);    // address
	VGA_IP_mWriteReg(XPAR_VGA_IP_0_CTRL_BASEADDR, VGA_IP_CTRL_SLV_REG2_OFFSET, 0x01);  		// WEN = '1'
	VGA_IP_mWriteReg(XPAR_VGA_IP_0_CTRL_BASEADDR, VGA_IP_CTRL_SLV_REG2_OFFSET, 0x00);  		// WEN = '0'
}

void VGA_write_string(u32 x, u32 y, const char *c, u32 num_char)
{
	int i = x;
	int j = y;
	int k = 0;
	//u32 character;

	for (j; j < 30 && k < num_char; j++)
	{
		for (i; i < 80 && k < num_char; i++)
		{
			//find_character(c[k++], &character);
			//k++;
			//xil_printf("%x\n", character);
			VGA_write_character(i, j, c[k++]);
		}
	}

}
