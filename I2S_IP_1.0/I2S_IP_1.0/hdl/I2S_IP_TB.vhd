----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/05/2017 09:57:23 AM
-- Design Name: 
-- Module Name: I2S_IP_TB - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2S_IP_TB is
--  Port ( );
end I2S_IP_TB;

architecture Behavioral of I2S_IP_TB is
constant C_S_AXIS_TDATA_WIDTH    : integer :=32; 
constant C_M_AXIS_TDATA_WIDTH    : integer :=32; 
constant TDATA_WIDTH : integer := 32;
-- Component declaration for the Unit Under Test 
    component I2S_IP_v1_0 is
--	generic (
--		-- Users to add parameters here

--		-- User parameters ends
--		-- Do not modify the parameters beyond this line


--		-- Parameters of Axi Master Bus Interface M_AXIS
--		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
----		C_M_AXIS_START_COUNT	: integer	:= 32;

--		-- Parameters of Axi Slave Bus Interface S_AXIS
--		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
--	);
	port (
		-- Users to add ports here
		
		iCLK          : in std_logic;
		oMCLK         : out std_logic;
		iRSTN         : in STD_LOGIC;
		
		iRECDAT       : in  STD_LOGIC;		
		oBCLK         : out STD_LOGIC;
		oPBLRC        : out STD_LOGIC;
		oRECLRC       : out STD_LOGIC;
		oPBDAT        : out STD_LOGIC;
		onMUTE        : out STD_LOGIC;
		
		iAXIS_ACLK       : in std_logic;
        iAXIS_ARSTEN     : in std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line

        
		-- Ports of Axi Master Bus Interface M_AXIS
--		m_axis_aclk	: in std_logic;
--		m_axis_aresetn	: in std_logic;
		m_axis_tvalid	: out std_logic;
		m_axis_tdata	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		m_axis_tkeep	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m_axis_tlast	: out std_logic;
		m_axis_tready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXIS
--		s_axis_aclk	: in std_logic;
--		s_axis_aresetn	: in std_logic;
		s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		s_axis_tkeep	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s_axis_tlast	: in std_logic;
		s_axis_tvalid	: in std_logic
	);
    end component;

-- Constants
    
--    constant START_COUNT    : integer :=32; 
    
-- Inputs and Outputs    
    signal iCLK          : STD_LOGIC :='0';
    signal oMCLK         : STD_LOGIC :='0';
    signal iRSTN         : STD_LOGIC :='0';
    
           
    signal iRECDAT       : STD_LOGIC :='0';
    signal oBCLK         : STD_LOGIC :='0';
    signal oPBLRC        : STD_LOGIC :='0';
    signal oRECLRC       : STD_LOGIC :='0';
    signal oPBDAT        : STD_LOGIC :='0';
    signal onMUTE        : STD_LOGIC :='0';
            
    signal iAXIS_ACLK       : std_logic :='0';
    signal iAXIS_ARSTEN     : std_logic :='1';    
            
     -- Ports of Axi Master Bus Interface M_AXIS
    --        m_axis_aclk    : in std_logic;
    --        m_axis_aresetn    : in std_logic;
    signal m_axis_tvalid   : std_logic :='0';
    signal m_axis_tdata    : std_logic_vector(TDATA_WIDTH-1 downto 0) :=(others=>'0');
    signal m_axis_tkeep    : std_logic_vector((TDATA_WIDTH/8)-1 downto 0) :=(others=>'0');
    signal m_axis_tlast    : std_logic :='0';
    signal m_axis_tready   : std_logic :='0';
    
    -- Ports of Axi Slave Bus Interface S_AXIS
    --        s_axis_aclk    : in std_logic;
    --        s_axis_aresetn    : in std_logic;
    signal s_axis_tready   : std_logic :='0';
    signal s_axis_tdata    : std_logic_vector(TDATA_WIDTH-1 downto 0) :=(others=>'0');
    signal s_axis_tkeep    : std_logic_vector((TDATA_WIDTH/8)-1 downto 0) :=(others=>'0');
    signal s_axis_tlast    : std_logic :='0';
    signal s_axis_tvalid   : std_logic :='0';
    
-- Clock period definition
    constant iCLK_period : time := 81.38 ns;    -- 12.288 MHz
    constant iAXIS_ACLK_period : time := 10 ns; -- 100 MHz
    
-- Signals                                                      L         R
    signal sRECDAT_1 : STD_LOGIC_VECTOR (63 downto 0) :=x"0000_F0AA_0000_9696";
    signal sRECDAT_2 : STD_LOGIC_VECTOR (63 downto 0) :=x"0000_8888_0000_1111";
    signal sRECDAT_3 : STD_LOGIC_VECTOR (63 downto 0) :=x"0000_1234_0000_5678";
    
--                                                         L    R
    signal s_tdata_1 : STD_LOGIC_VECTOR (31 downto 0) :=x"1234_5678";
    signal s_tdata_2 : STD_LOGIC_VECTOR (31 downto 0) :=x"1212_3434";
    signal s_tdata_3 : STD_LOGIC_VECTOR (31 downto 0) :=x"7418_5296";

begin

-- Instantiate the Unit Under Test
    uut:    I2S_IP_v1_0 
--            generic map (
    
--                C_M_AXIS_TDATA_WIDTH	=> TDATA_WIDTH,
----                C_M_AXIS_START_COUNT	=> START_COUNT,
--                C_S_AXIS_TDATA_WIDTH	=> TDATA_WIDTH
--            )
            port map (
                
                iCLK,
                oMCLK,
                iRSTN,
                
                iRECDAT,	
                oBCLK,
                oPBLRC,
                oRECLRC,
                oPBDAT,
                onMUTE,
                
                iAXIS_ACLK,
                iAXIS_ARSTEN,
        
                m_axis_tvalid,
                m_axis_tdata,
                m_axis_tkeep,
                m_axis_tlast,
                m_axis_tready,
        
                s_axis_tready,
                s_axis_tdata,
                s_axis_tkeep,
                s_axis_tlast,
                s_axis_tvalid
            );
                        
-- Clock process definition
    iCLK_process:   process
                    begin
                        iCLK <= '0';
                        wait for iCLK_period/2;
                        iCLK <= '1';
                        wait for iCLK_period/2;
                    end process;
                    
-- Clock process definition
    iAXIS_ACLK_process: process
                        begin
                            iAXIS_ACLK <= '0';
                            wait for iAXIS_ACLK_period/2;
                            iAXIS_ACLK <= '1';
                            wait for iAXIS_ACLK_period/2;
                        end process;
                    
-- Stimulus porocess
    stim_process:   process
                    begin
                        
                        -- reset FIFO_RX
                        iAXIS_ARSTEN <='0';
                        iRSTN <= '0';
                        wait for iAXIS_ACLK_period*100;
                        iRSTN <= '1';
                        iAXIS_ARSTEN <='1';
                        
                        -- fill FIFO_RX with data
                        REC_input_1:    for I in 0 to 63 loop
                                            iRECDAT <= sRECDAT_1(63-I);
                                            wait for iCLK_period*4;
                                        end loop REC_input_1;
                                        
                        REC_input_2:    for I in 0 to 63 loop
                                            iRECDAT <= sRECDAT_2(63-I);
                                            wait for iCLK_period*4;
                                        end loop REC_input_2;
                                        
                        REC_input_3:    for I in 0 to 63 loop
                                            iRECDAT <= sRECDAT_3(63-I);
                                            wait for iCLK_period*4;
                                        end loop REC_input_3;
                                                                                
                        wait for 5us;
                        
                        m_axis_tready <= '1';
                        
                        wait for iAXIS_ACLK_period*10;
                        
                        -- fill FIFO_TX with data
                        s_axis_tvalid <= '1';
                        s_axis_tdata <= s_tdata_1;
                        wait for iAXIS_ACLK_period;
                        s_axis_tdata <= s_tdata_2;
                        wait for iAXIS_ACLK_period;
                        s_axis_tdata <= s_tdata_3;
                        wait for iAXIS_ACLK_period;
                        s_axis_tvalid <= '0';
                         
                        
                        
--                        iPB_SAMPLE_LC <= x"855F";
--                        iPB_SAMPLE_RC <= x"E66F";                        
                    
                        wait;
                    end process;

end Behavioral;
