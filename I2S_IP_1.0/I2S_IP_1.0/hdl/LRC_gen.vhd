---------------------------------------------------------------------------
-- File : LRC_gen.vhd
-- Author : Dario Djuric <Dario.Djuric@rt-rk.com>
-- Created : 8.11.2017
-- Description: Generates frame clock signal that separates left and right
--              channel data. oLRC is changing on falling edge of the iBCLK.
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


entity LRC_gen is
    Port ( 
           iCLK         : in STD_LOGIC;
           iBCLK_TICK   : in STD_LOGIC;
           iRST         : in STD_LOGIC;
           oLRC         : out STD_LOGIC
         );
end LRC_gen;

architecture Behavioral of LRC_gen is

     signal cnt: integer;
     signal sLRC: STD_LOGIC;
     
begin

    -- frame clock signal generator
    process (iCLK)
    begin
        if (iCLK'event and iCLK='1') then -- iBCLK='0'
            if (iRST='0') then
                cnt <= 0;
            else
                if(iBCLK_TICK = '1')then
                    if (cnt < 63) then
                        cnt <= cnt + 1;
                    else
                        cnt <= 0;               
                    end if;
                end if;
            end if;        
        end if;
    end process;
    
    sLRC <= '1' when cnt <32 else '0';
    oLRC <= sLRC;

end Behavioral;
