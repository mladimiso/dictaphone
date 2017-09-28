---------------------------------------------------------------------------
-- File : RX.vhd
-- Author : Dario Djuric <Dario.Djuric@rt-rk.com>
-- Created : 8.10.2017
-- Description: Receiver is capturing data on iRECDAT input 
--              on the rising edge of the iBCLK. Data stream on iRECDAT 
--              comprises left and right channel audio data that is time 
--              domain multiplexed.
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


entity RX is
    Port (
            iRST            : in STD_LOGIC;
            iCLK            : in STD_LOGIC;
            iBCLK_TICK      : in STD_LOGIC;
            iLRC            : in STD_LOGIC;
            iRECDAT         : in STD_LOGIC;
            oREC_SAMPLE_LC  : out STD_LOGIC_VECTOR (31 downto 0);
            oREC_SAMPLE_RC  : out STD_LOGIC_VECTOR (31 downto 0);
            oSAMPLE_READY   : out STD_LOGIC
         );
end RX;

architecture Behavioral of RX is

      signal sSAMPLE_READY: STD_LOGIC;

      signal sLEFT: STD_LOGIC_VECTOR (31 downto 0);
      signal sRIGHT: STD_LOGIC_VECTOR (31 downto 0);
      signal cnt: integer;


begin

    -- capturing data on iRECDAT input on the rising edge of the iBCLK
    process (iCLK)
    begin
        if (iCLK'event and iCLK='1') then
            if (iRST='0') then
                cnt <= 0;
                sSAMPLE_READY<='0';
                sLEFT <= (others =>'0');
                sRIGHT <= (others =>'0');
            else
                if (iBCLK_TICK='1') then -- 3.072MHz tick
                    if (iLRC='1') then  --left channel
                        sLEFT <= sLEFT(30 downto 0) & iRECDAT;
                    else                --right channel
                        sRIGHT <= sRIGHT(30 downto 0) & iRECDAT;
                    end if;
                    
                    cnt <= cnt + 1;
                    if (cnt=63) then
                        cnt <= 0;
                        sSAMPLE_READY <= '1';
                    else
                        sSAMPLE_READY <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    oREC_SAMPLE_LC <= sLEFT;
    oREC_SAMPLE_RC <= sRIGHT;
    oSAMPLE_READY <= sSAMPLE_READY and iBCLK_TICK;-- ubaciti TICK ??? and TICK

end Behavioral;
