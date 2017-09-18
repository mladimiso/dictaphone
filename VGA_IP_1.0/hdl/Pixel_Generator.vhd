----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2017 01:34:44 PM
-- Design Name: 
-- Module Name: Pixel_Generator - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Pixel_Generator is
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
end Pixel_Generator;

architecture Behavioral of Pixel_Generator is

-- dio za ispis na VGA
signal sROW             : std_logic_vector(9 downto 0);  -- red(linija) za ispisivanje piksela
signal sCOLUMN          : std_logic_vector(9 downto 0);  -- kolona za ispisivanje piksela
signal sMUX_DATA        : std_logic_vector(7 downto 0);  -- izlaz mux-a koji sluzi za ispisvanje karaktera(govori koji je piksel razlicit od nule) 
signal sPIXEL           : std_logic;                     -- sluzi za omogucenje boja(RED, GREEN, BLUE) koje treba da ima piksel

-- dio za memoriju
signal sADDRESS         : std_logic_vector(5 downto 0);  -- izlaz RAM bloka koji ide u ROM i govori koji karakter se ispisuje, visi dio adrese
signal sRAM_OUT_ADDRESS : std_logic_vector(11 downto 0); -- adresa porta B RAM memorije 
signal sCHAR_ADDRESS    : std_logic_vector(9 downto 0);  -- nizi dio adrese karaktera u ROM-u

-- kasnjenja 
signal sCOLUMN_1D       : std_logic_vector(9 downto 0);
signal sCOLUMN_2D       : std_logic_vector(9 downto 0);

component ROM IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component ROM;

component RAM IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
  );
END component RAM;

begin
    
sROW             <= inROW;
sCOLUMN          <= inCOLUMN;
sRAM_OUT_ADDRESS <= sROW(8 downto 4) & sCOLUMN(9 downto 3);
sCHAR_ADDRESS    <= sADDRESS & sROW(3 downto 0); 
    
    delay :process(iCLK)
           begin
             if(iCLK'event and iCLK = '1') then
                sCOLUMN_1D <= sCOLUMN;
                sCOLUMN_2D <= sCOLUMN_1D;
             end if;
           end process;
    
    UP1: ROM port map
                     (
                      clka  => iCLK,
                      ena   => inCTRL(0),
                      addra => sCHAR_ADDRESS,
                      douta => sMUX_DATA
                      );
                      
    UP2 : RAM port map
                      (
                       clka  => iCLK,
                       ena   => inCTRL(3),
                       wea   => inCTRL(2),
                       addra => inADDR,
                       dina  => inDATA,
                       clkb  => iCLK,
                       enb   => inCTRL(1),
                       addrb => sRAM_OUT_ADDRESS,
                       doutb => sADDRESS
                       );
                       
    
                    
with sCOLUMN_2D(2 downto 0) select
    sPIXEL <= sMUX_DATA(7) when "000",
              sMUX_DATA(6) when "001",
              sMUX_DATA(5) when "010",
              sMUX_DATA(4) when "011",
              sMUX_DATA(3) when "100",
              sMUX_DATA(2) when "101",
              sMUX_DATA(1) when "110",
              sMUX_DATA(0) when "111";
                   
                   
    oRED(0)   <= sPIXEL when (inCOLUMN < 640 and inROW <= 480) else '0';   
    oRED(1)   <= sPIXEL when (inCOLUMN < 640 and inROW <= 480) else '0';   
    oRED(2)   <= sPIXEL when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oRED(3)   <= sPIXEL when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oRED(4)   <= sPIXEL when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oBLUE(0)  <= '0' when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oBLUE(1)  <= '0' when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oBLUE(2)  <= '0' when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oBLUE(3)  <= '0' when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oBLUE(4)  <= '0' when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oGREEN(0) <= sPIXEL  when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oGREEN(1) <= sPIXEL  when (inCOLUMN < 640 and inROW <= 480) else '0';  
    oGREEN(2) <= sPIXEL  when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oGREEN(3) <= sPIXEL  when (inCOLUMN < 640 and inROW <= 480) else '0';
    oGREEN(4) <= sPIXEL  when (inCOLUMN < 640 and inROW <= 480) else '0'; 
    oGREEN(5) <= sPIXEL  when (inCOLUMN < 640 and inROW <= 480) else '0';

end Behavioral;
