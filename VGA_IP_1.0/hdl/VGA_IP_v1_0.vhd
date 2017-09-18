library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_IP_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface CTRL
		C_CTRL_DATA_WIDTH	: integer	:= 32;
		C_CTRL_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        oHsync         : out std_logic;
        oVsync         : out std_logic;
        oRED           : out std_logic_vector(4 downto 0);
        oGREEN         : out std_logic_vector(5 downto 0);
        oBLUE          : out std_logic_vector(4 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface CTRL
		ctrl_aclk	: in std_logic;
		ctrl_aresetn	: in std_logic;
		ctrl_awaddr	: in std_logic_vector(C_CTRL_ADDR_WIDTH-1 downto 0);
		ctrl_awprot	: in std_logic_vector(2 downto 0);
		ctrl_awvalid	: in std_logic;
		ctrl_awready	: out std_logic;
		ctrl_wdata	: in std_logic_vector(C_CTRL_DATA_WIDTH-1 downto 0);
		ctrl_wstrb	: in std_logic_vector((C_CTRL_DATA_WIDTH/8)-1 downto 0);
		ctrl_wvalid	: in std_logic;
		ctrl_wready	: out std_logic;
		ctrl_bresp	: out std_logic_vector(1 downto 0);
		ctrl_bvalid	: out std_logic;
		ctrl_bready	: in std_logic;
		ctrl_araddr	: in std_logic_vector(C_CTRL_ADDR_WIDTH-1 downto 0);
		ctrl_arprot	: in std_logic_vector(2 downto 0);
		ctrl_arvalid	: in std_logic;
		ctrl_arready	: out std_logic;
		ctrl_rdata	: out std_logic_vector(C_CTRL_DATA_WIDTH-1 downto 0);
		ctrl_rresp	: out std_logic_vector(1 downto 0);
		ctrl_rvalid	: out std_logic;
		ctrl_rready	: in std_logic
	);
end VGA_IP_v1_0;

architecture arch_imp of VGA_IP_v1_0 is

	-- component declaration
	component VGA_IP_v1_0_CTRL is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		
		oHsync         : out std_logic;
        oVsync         : out std_logic;
        oRED           : out std_logic_vector(4 downto 0);
        oGREEN         : out std_logic_vector(5 downto 0);
        oBLUE          : out std_logic_vector(4 downto 0)
		);
	end component VGA_IP_v1_0_CTRL;

begin

-- Instantiation of Axi Bus Interface CTRL
VGA_IP_v1_0_CTRL_inst : VGA_IP_v1_0_CTRL
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_CTRL_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_CTRL_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> ctrl_aclk,
		S_AXI_ARESETN	=> ctrl_aresetn,
		S_AXI_AWADDR	=> ctrl_awaddr,
		S_AXI_AWPROT	=> ctrl_awprot,
		S_AXI_AWVALID	=> ctrl_awvalid,
		S_AXI_AWREADY	=> ctrl_awready,
		S_AXI_WDATA	=> ctrl_wdata,
		S_AXI_WSTRB	=> ctrl_wstrb,
		S_AXI_WVALID	=> ctrl_wvalid,
		S_AXI_WREADY	=> ctrl_wready,
		S_AXI_BRESP	=> ctrl_bresp,
		S_AXI_BVALID	=> ctrl_bvalid,
		S_AXI_BREADY	=> ctrl_bready,
		S_AXI_ARADDR	=> ctrl_araddr,
		S_AXI_ARPROT	=> ctrl_arprot,
		S_AXI_ARVALID	=> ctrl_arvalid,
		S_AXI_ARREADY	=> ctrl_arready,
		S_AXI_RDATA	=> ctrl_rdata,
		S_AXI_RRESP	=> ctrl_rresp,
		S_AXI_RVALID	=> ctrl_rvalid,
		S_AXI_RREADY	=> ctrl_rready,
		
		oHsync         => oHsync,
        oVsync         => oVsync,
        oRED           => oRED,
        oGREEN         => oGREEN,
        oBLUE          => oBLUE
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
