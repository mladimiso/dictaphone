library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity I2S_IP_v1_0 is
	generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		iCLK          : in std_logic;     -- 12.288 MHz
		oMCLK         : out std_logic;
		iRSTN         : in STD_LOGIC;
		
		iRECDAT       : in STD_LOGIC;		
		oBCLK         : out STD_LOGIC;
		oPBLRC        : out STD_LOGIC;
		oRECLRC       : out STD_LOGIC;
		oPBDAT        : out STD_LOGIC;
		onMUTE        : out STD_LOGIC;
		
		iAXIS_ACLK       : in std_logic;
        iAXIS_ARSTEN     : in std_logic;

		-- Ports of Axi Master Bus Interface M_AXIS
		m_axis_tvalid	: out std_logic;
		m_axis_tdata	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		m_axis_tkeep	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m_axis_tlast	: out std_logic;
		m_axis_tready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXIS
		s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		s_axis_tkeep	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s_axis_tlast	: in std_logic;
		s_axis_tvalid	: in std_logic
	);
end I2S_IP_v1_0;

architecture arch_imp of I2S_IP_v1_0 is
     
	-- component declaration

	COMPONENT fifo_generator_RX
      PORT (
        rst     : IN STD_LOGIC;
        wr_clk  : IN STD_LOGIC;
        rd_clk  : IN STD_LOGIC;
        din     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en   : IN STD_LOGIC;
        rd_en   : IN STD_LOGIC;
        dout    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        full    : OUT STD_LOGIC;
        empty   : OUT STD_LOGIC
      );
    END COMPONENT;
    
    signal sRX_rst          :  STD_LOGIC;
    signal sRX_rd_en        :  STD_LOGIC;
    signal sREC_SAMPLE_FIFO :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sRX_full         :  STD_LOGIC;
    signal sRX_empty        :  STD_LOGIC;
    signal sRX_valid        :  STD_LOGIC;
    
    
    COMPONENT fifo_generator_TX
      PORT (
        rst     : IN STD_LOGIC;
        wr_clk  : IN STD_LOGIC;
        rd_clk  : IN STD_LOGIC;
        din     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en   : IN STD_LOGIC;
        rd_en   : IN STD_LOGIC;
        dout    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        full    : OUT STD_LOGIC;
        empty   : OUT STD_LOGIC
      );
    END COMPONENT;
    
    signal sTX_rst          :  STD_LOGIC;
    signal sPB_SAMPLE_L_R   :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sTX_wr_en        :  STD_LOGIC;
    signal sTX_full         :  STD_LOGIC;
    signal sTX_empty        :  STD_LOGIC;
    signal sTX_valid        :  STD_LOGIC;
    
    component Transceiver is
        Port ( 
                iRST : in STD_LOGIC;
                iCLK : in STD_LOGIC;
                iBCLK_TICK   : in STD_LOGIC;
                                       
                oBCLK : out STD_LOGIC;                                      -- I2S serial clock
               
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
    end component;
    
    signal sPB_SAMPLE_LC    : STD_LOGIC_VECTOR (15 downto 0);
    signal sPB_SAMPLE_RC    : STD_LOGIC_VECTOR (15 downto 0);
    signal sPB_READY        : STD_LOGIC;
    
    signal sREC_SAMPLE_L_R      : STD_LOGIC_VECTOR (31 downto 0);
    signal sREC_SAMPLE_LC       : STD_LOGIC_VECTOR (15 downto 0);
    signal sREC_SAMPLE_RC       : STD_LOGIC_VECTOR (15 downto 0);
    signal sREC_SAMPLE_READY    : STD_LOGIC;
    
    signal sPB_SAMPLE_FIFO      : STD_LOGIC_VECTOR (31 downto 0);
    
    signal tlast    : STD_LOGIC;
    signal cnt      : integer;
    
    signal sRD_EN_RX : std_logic;
    signal sWR_EN_TX : std_logic;
    
    signal count    : std_logic_vector(1 downto 0):= "00";
    signal sBCLK_TICK : std_logic;
    
    signal sBCLK : std_logic;
    signal sPBLRC : std_logic;
    signal sPBDAT : std_logic;
    
begin

    oMCLK <= iCLK;
    onMUTE <= '1';
    
    sRX_rst <= not iAXIS_ARSTEN;
    sTX_rst <= not iAXIS_ARSTEN;

    -- 3.072MHz tick signal generator
    process (iCLK)
    begin
        if (iCLK'event and iCLK='1') then
                count <= count + 1;      
        end if;
    end process;
    
	sBCLK_TICK <= '1' when count = 3 else '0';
	
	
-- Instantiation of Transceiver
RX_TX :     Transceiver 
            Port Map    ( 
                            iRST       => iRSTN,
                            iCLK       => iCLK, --12.288MHz
                            iBCLK_TICK  => sBCLK_TICK,           
                            oBCLK      => sBCLK,
                                  
                            oPBLRC          => sPBLRC,
                            oPBDAT          => sPBDAT,
                            iPB_SAMPLE_LC   => sPB_SAMPLE_LC,
                            iPB_SAMPLE_RC   => sPB_SAMPLE_RC,
                            oPB_READY       => sPB_READY,
                                   
                            iRECDAT             => iRECDAT,
                            oRECLRC             => oRECLRC,
                            oREC_SAMPLE_LC      => sREC_SAMPLE_LC,
                            oREC_SAMPLE_RC      => sREC_SAMPLE_RC,
                            oREC_SAMPLE_READY   => sREC_SAMPLE_READY                      
                        );
    
    process(iCLK)
    begin
        if(iCLK'event and iCLK = '1')then
            if(iRSTN = '0')then
                oBCLK  <= '0';
                oPBLRC <= '0';
                oPBDAT <= '0';
            else
                oBCLK  <= sBCLK;
                oPBLRC <= sPBLRC;
                oPBDAT <= sPBDAT;                
            end if;
        end if;
    end process;   
                            
    sREC_SAMPLE_L_R <= sREC_SAMPLE_LC & sREC_SAMPLE_RC; -- Merge record L and R channel
	
-- Instantiation of FIFO_RX
FIFO_RX :   fifo_generator_RX
            PORT MAP (
                        rst     => sRX_rst,
                        wr_clk  => iCLK,
                        rd_clk  => iAXIS_ACLK,
                        
                        din     => sREC_SAMPLE_L_R,
                        wr_en   => sREC_SAMPLE_READY,
                        full    => sRX_full,
                                                    
                        rd_en   => sRD_EN_RX,
                        dout    => m_axis_tdata,
                        empty   => sRX_empty
                     );
					 
    sRD_EN_RX <= (not sRX_empty) and m_axis_tready;
    m_axis_tvalid <= not sRX_empty;
    m_axis_tkeep <= "1111";
    
    -- m_axis_tlast signal generator
    TLAST_gen   :   process (iAXIS_ACLK)
                    begin
                        if (iAXIS_ACLK'event and iAXIS_ACLK='1') then
                            if (sRX_rst='1') then
                                cnt <= 0;
                            else
                                if (sRX_empty = '0' and m_axis_tready = '1') then
                                    if (cnt < 127) then
                                        cnt <= cnt + 1;
                                    else
                                        cnt <= 0;
                                    end if;
                                end if;
                            end if;
                        end if;                
                    end process;
                
    m_axis_tlast <= tlast;  
    tlast <= '1' when cnt = 127 else '0';
	
-- Instantiation of FIFO_TX      
FIFO_TX :   fifo_generator_TX
            PORT MAP (
                        rst     => sTX_rst,
                        wr_clk  => iAXIS_ACLK,
                        rd_clk  => iCLK,
                        
                        din     => s_axis_tdata,
                        wr_en   => sWR_EN_TX,
                        full    => sTX_full,
                        
                        rd_en   => sPB_READY,
                        dout    => sPB_SAMPLE_FIFO,
                        empty   => sTX_empty
                     );
    
	sWR_EN_TX <= s_axis_tvalid and (not sTX_full);
    s_axis_tready <= not sTX_full;                    
    sPB_SAMPLE_LC <= sPB_SAMPLE_FIFO (31 downto 16) when (sTX_empty='0') else (others=>'0');
    sPB_SAMPLE_RC <= sPB_SAMPLE_FIFO (15 downto 0) when (sTX_empty='0') else (others=>'0');
    

end arch_imp;
