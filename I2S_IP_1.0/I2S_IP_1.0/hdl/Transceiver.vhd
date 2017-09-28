---------------------------------------------------------------------------
-- File : I2S.vhd
-- Author : Dario Djuric <Dario.Djuric@rt-rk.com>
-- Created : 8.10.2017
-- Description: Digital audio communication protocol
--              RIGHT-JUSTIFIED MODE
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
use IEEE.STD_LOGIC_unsigned.ALL;

entity Transceiver is
    Port ( 
            iRST        : in STD_LOGIC;
            iCLK        : in STD_LOGIC;     --12.288 MHz                                   
            iBCLK_TICK   : in STD_LOGIC;
                               
            oBCLK       : out STD_LOGIC;                                -- I2S serial clock
            
            oPBLRC           : out STD_LOGIC;                           -- I2S playback channel clock
            oPBDAT           : out STD_LOGIC;                           -- I2S playback data
            iPB_SAMPLE_LC    : in  STD_LOGIC_VECTOR (15 downto 0);
            iPB_SAMPLE_RC    : in  STD_LOGIC_VECTOR (15 downto 0);
            oPB_READY        : out STD_LOGIC;
           
            iRECDAT              : in STD_LOGIC;                        -- I2S record data
            oRECLRC              : out STD_LOGIC;                       -- I2S record channel clock
            oREC_SAMPLE_LC       : out STD_LOGIC_VECTOR (15 downto 0);
            oREC_SAMPLE_RC       : out STD_LOGIC_VECTOR (15 downto 0);
            oREC_SAMPLE_READY    : out STD_LOGIC                      
         );
end Transceiver;

architecture Behavioral of Transceiver is

    -- Component declaration for the LR_CLK (clk sig. that separates L and R channel)
    component LRC_gen is
    Port ( 
            iCLK : in STD_LOGIC;
            iBCLK_TICK : in STD_LOGIC;
            iRST  : in STD_LOGIC;
            oLRC : out STD_LOGIC
         );
    end component;
    
    signal sLRC: STD_LOGIC;

    -- Component declaration for the Receiver 
    component RX is
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
    end component;
    
    signal sREC_SAMPLE_LC: STD_LOGIC_VECTOR (31 downto 0);
    signal sREC_SAMPLE_RC: STD_LOGIC_VECTOR (31 downto 0);
        
    -- Component declaration for the Transmitter 
    component TX is
    Port ( 
            iCLK           : in STD_LOGIC;
            iBCLK_TICK       : in STD_LOGIC;
            iRST            : in STD_LOGIC;
            iLRC            : in STD_LOGIC;
            iPB_SAMPLE_LC   : in STD_LOGIC_VECTOR (31 downto 0);
            iPB_SAMPLE_RC   : in STD_LOGIC_VECTOR (31 downto 0);
            oREADY          : out STD_LOGIC;
            oPBDAT          : out STD_LOGIC
         );
    end component;
    
    signal sPB_SAMPLE_LC : STD_LOGIC_VECTOR (31 downto 0);
    signal sPB_SAMPLE_RC : STD_LOGIC_VECTOR (31 downto 0);
    
    
    signal sBCLK_DLY1P : STD_LOGIC;
    signal sBCLK_DLY2P : STD_LOGIC;
    signal sLRC_1P_DLY : STD_LOGIC;
    signal sLRC_2P_DLY : STD_LOGIC;
    
    signal count    : std_logic_vector(1 downto 0):= "00";

begin

    -------------------------------------------
    -- 3.072MHz 50% duty cycle signal generator
    process (iCLK)
    begin
        if (iCLK'event and iCLK='1') then
                count <= count + 1;      
        end if;
    end process;
 
    oBCLK <= count(1);
    -------------------------------------------
                   
    -- Instantiate the LR_CLK
    LR_CLK: LRC_gen Port map ( 
                                iCLK   => iCLK,
                                iBCLK_TICK => iBCLK_TICK,
                                iRST    => iRST,
                                oLRC    => sLRC
                             );
    oRECLRC <= sLRC;
    
    -- Delay sLRC 
    LR_CLK_1P_DLY:  process (iCLK)
                    begin
                        if (iCLK'event and iCLK='1') then -- iBCLK='0'
                            if (iRST='0') then
                                sLRC_1P_DLY <= '0';
                                sLRC_2P_DLY <= '0'; 
                            else
                                if (iBCLK_TICK='1') then    --?? UBACITI TICK
                                    sLRC_1P_DLY <= sLRC;        -- 1 period delay
                                    sLRC_2P_DLY <= sLRC_1P_DLY; -- 2 period delay
                                end if;                               
                            end if;              
                        end if;
                    end process;
                    
    oPBLRC <= sLRC_2P_DLY; --perform transmit synchronization

    -- Instantiate the Receiver
    receiver:   RX Port Map (
                                iRST            => iRST,
                                iCLK            => iCLK,
                                iBCLK_TICK      => iBCLK_TICK,
                                iLRC            => sLRC,
                                iRECDAT         => iRECDAT,
                                oREC_SAMPLE_LC  => sREC_SAMPLE_LC,
                                oREC_SAMPLE_RC  => sREC_SAMPLE_RC,
                                oSAMPLE_READY   => oREC_SAMPLE_READY
                             );
    -- Right-Justified                         
    oREC_SAMPLE_LC <= sREC_SAMPLE_LC(15 downto 0);
    oREC_SAMPLE_RC <= sREC_SAMPLE_RC(15 downto 0);
    
    -- Instantiate the Transmitter                         
    transmitter:    TX Port Map (
                                    iCLK            => iCLK,
                                    iBCLK_TICK      => iBCLK_TICK,
                                    iRST            => iRST,
                                    iLRC            => sLRC_1P_DLY,
                                    iPB_SAMPLE_LC   => sPB_SAMPLE_LC,
                                    iPB_SAMPLE_RC   => sPB_SAMPLE_RC,
                                    oREADY          => oPB_READY,
                                    oPBDAT          => oPBDAT
                                );
    -- Right-Justified                           
    sPB_SAMPLE_LC <= x"0000" & iPB_SAMPLE_LC;
    sPB_SAMPLE_RC <= x"0000" & iPB_SAMPLE_RC;
    

end Behavioral;
