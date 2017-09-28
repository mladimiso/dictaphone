---------------------------------------------------------------------------
-- File : TX.vhd
-- Author : Dario Djuric <Dario.Djuric@rt-rk.com>
-- Created : 8.10.2017
-- Discription: Transmitter is shifting out data on oPBDAT output on falling
--              edge of the iBCLK.
--              Data stream on oPBDAT comprises left and right channel audio
--              data that is time domain multiplexed.
---------------------------------------------------------------------------
--
-- $RCSfile: $
-- $Revision: $
-- $Author: $
-- $Date: $
-- $Source: $
--
-- Description: <description>
--
---------------------------------------------------------------------------
-- The following is Company Confidential Information.
-- Copyright (c) 2006
-- All rights reserved. This program is protectedas an
-- unpublished work under the Copyright Act of 1976 and the ComputerSoftware
-- Act of 1980. This program is also considered a trade secret. It is not to
-- be disclosed or used by parties who have not received written authorization
-- from Company, Inc.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity TX is
    Port ( 
           iCLK : in STD_LOGIC;
           iBCLK_TICK    : in STD_LOGIC;
           iRST : in STD_LOGIC;
           iLRC : in STD_LOGIC;
           iPB_SAMPLE_LC : in STD_LOGIC_VECTOR (31 downto 0);
           iPB_SAMPLE_RC : in STD_LOGIC_VECTOR (31 downto 0);
           oREADY   : out STD_LOGIC;
           oPBDAT : out STD_LOGIC
         );
end TX;

architecture Behavioral of TX is

    signal cnt: integer range 0 to 63;
    
    signal sLEFT: STD_LOGIC_VECTOR (31 downto 0);
    signal sRIGHT: STD_LOGIC_VECTOR (31 downto 0);
    
    signal sREADY: std_logic;
    signal sPBDAT: std_logic;

begin
    
    -- shifting out data on oPBDAT output on falling edge of the iBCLK
    process (iCLK)
    begin   
        if (iCLK'event and iCLK='1') then -- iBCLK='0'
            if (iRST='0') then
                cnt <= 0; 
                sLEFT  <= (others =>'0');
                sRIGHT <= (others =>'0');  
                sPBDAT <= '0';
            else
                if(iBCLK_TICK = '1')then
                    if (sREADY='1') then
                        sLEFT  <= iPB_SAMPLE_LC; 
                        sRIGHT <= iPB_SAMPLE_RC;
                        sPBDAT <= '0';
                    elsif (iLRC='1') then
                        sPBDAT <= sLEFT(31);
                        sLEFT  <= sLEFT(30 downto 0) & '0'; 
                    else                --right channel
                        sPBDAT <= sRIGHT(31);
                        sRIGHT <= sRIGHT(30 downto 0) & '0';
                    end if;
                    
                    if (cnt < 63) then
                        cnt <= cnt + 1;
                    else
                        cnt <= 0;
                    end if;
                end if;                 
 
             end if;      
       end if;
    end process;
    
    sREADY <= '1' when cnt = 0 else '0';
    
    oREADY <= sREADY and iBCLK_TICK;
    oPBDAT <= sPBDAT;
    
    

end Behavioral;
