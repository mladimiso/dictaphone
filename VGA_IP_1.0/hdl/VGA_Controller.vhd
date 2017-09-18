----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2017 01:30:41 PM
-- Design Name: 
-- Module Name: VGA_Controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.VGA_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_Controller is
  Generic(
            RES            : resolution := vga_640x480 
          );
  Port    (
            iCLK           : in  std_logic;
            inRST          : in  std_logic;
            inVGA_DATA     : in  std_logic_vector(5 downto 0);
            inVGA_ADDR     : in  std_logic_vector(11 downto 0);
            inVGA_CTRL     : in  std_logic_vector(3 downto 0);
            oHsync         : out std_logic;
            oVsync         : out std_logic;
            oRED           : out std_logic_vector(4 downto 0);
            oGREEN         : out std_logic_vector(5 downto 0);
            oBLUE          : out std_logic_vector(4 downto 0) 
          );
end VGA_Controller;

architecture Behavioral of VGA_Controller is

signal sDATA          : std_logic_vector(5 downto 0);
signal sADDR          : std_logic_vector(11 downto 0);
signal sCTRL          : std_logic_vector(3 downto 0);
signal sROW           : std_logic_vector(9 downto 0);
signal sCOLUMN        : std_logic_vector(9 downto 0); 

-- kasnjenja
signal sHsync_delay   : std_logic;
signal sHsync_delay_1 : std_logic;
signal sHsync_delay_2 : std_logic;
signal sVsync_delay   : std_logic;
signal sVsync_delay_1 : std_logic;
signal sVsync_delay_2 : std_logic;
 
 
component Sync_counters is
  Generic(
          RES            : resolution := vga_640x480
        );
  Port (
          iCLK           : in std_logic;
          inRST          : in std_logic;
          oHsync         : out std_logic;
          oVsync         : out std_logic;
          oRowCounter    : out std_logic_vector(9 downto 0);
          oColumnCounter : out std_logic_vector(9 downto 0) 
        );
end component Sync_counters;


component Pixel_Generator is
  Port (
          iCLK        : in  std_logic;
          inRST       : in  std_logic;
          inDATA      : in  std_logic_vector(5 downto 0);
          inADDR      : in  std_logic_vector(11 downto 0);
          inCTRL      : in  std_logic_vector(3 downto 0);
          inROW       : in  std_logic_vector(9 downto 0);
          inCOLUMN    : in  std_logic_vector(9 downto 0);
          oRED        : out std_logic_vector(4 downto 0);
          oGREEN      : out std_logic_vector(5 downto 0);
          oBLUE       : out std_logic_vector(4 downto 0)   
        );
end component Pixel_Generator;

begin

    sDATA <= inVGA_DATA;
    sADDR <= inVGA_ADDR;
    sCTRL <= inVGA_CTRL;

    U1: Sync_counters 
    generic map (
                  RES => RES
                 )
    port map(
                                 iCLK           => iCLK,
                                 inRST          => inRST,
                                 oHsync         => sHsync_delay,
                                 oVsync         => sVsync_delay,
                                 oRowCounter    => sROW,
                                 oColumnCounter => sCOLUMN
                               );

    U2: Pixel_Generator port map(
                                  iCLK        => iCLK,
                                  inRST       => inRST,
                                  inDATA      => sDATA,
                                  inADDR      => sADDR,
                                  inCTRL      => sCTRL,
                                  inROW       => sROW,
                                  inCOLUMN    => sCOLUMN,
                                  oRED        => oRED,
                                  oGREEN      => oGREEN,
                                  oBLUE       => oBLUE
                                 );    
    
    delay : process (iCLK)
            begin
               if(iCLK'event and iCLK = '1') then
                  sHsync_delay_1 <=  sHsync_delay;
                  sHsync_delay_2 <=  sHsync_delay_1;
                  sVsync_delay_1 <=  sVsync_delay;
                  sVsync_delay_2 <=  sVsync_delay_1;
               end if;
            end process;
            
    oHsync <= sHsync_delay_2;
    oVsync <= sVsync_delay_2;                 
end Behavioral;
