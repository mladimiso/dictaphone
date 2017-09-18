----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2017 01:34:06 PM
-- Design Name: 
-- Module Name: Sync_counters - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.VGA_package.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sync_counters is
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
end Sync_counters;

architecture Behavioral of Sync_counters is

signal sHsync         : std_logic;
signal sVsync         : std_logic;
signal sHsync_count   : std_logic_vector(9 downto 0) := (others => '0');
signal sVsync_count   : std_logic_vector(9 downto 0) := (others => '0');
constant vga_res_time : vga_sync_types := vga_resolution(RES);
begin

    oRowCounter    <= sVsync_count;
    oColumnCounter <= sHsync_count;
    oHsync         <= sHsync;
    oVsync         <= sVsync;
    Horizontal_sync : process (iCLK)
                          begin
                              if(iCLK'event and iCLK = '1') then
                                  if(inRST = '0') then
                                      sHsync       <= '1';
                                  elsif(sHsync_count < vga_res_time.H_SYNC_START) then  -- 655(2007)
                                      sHsync <= '1';
                                  elsif(sHsync_count > vga_res_time.H_SYNC_START and sHsync_count <= vga_res_time.H_SYNC_END) then  -- 656 and 751 (2007 and 2051)
                                      sHsync <= '0';
                                  else -- do 799(2199)
                                      sHsync <= '1';
                                  end if;
                              end if; 
                      end process Horizontal_sync;

    Vertical_sync : process(iCLK)
                        begin
                            if(iCLK'event and iCLK = '1') then
                                if(inRST = '0') then
                                    sVsync  <= '1';
                                elsif(sVsync_count < vga_res_time.V_SYNC_START) then -- 489(1083)
                                    sVsync <= '1';
                                elsif(sVsync_count > vga_res_time.V_SYNC_START and sVsync_count <= vga_res_time.V_SYNC_END) then -- 490 and 491(1083 and 1088)
                                    sVsync <= '0';
                                else   -- do 520
                                    sVsync <= '1';
                                end if;
                            end if;
                    end process Vertical_sync;
    Horizontal_count : process(iCLK)
                           begin
                               if(iCLK'event and iCLK = '1') then
                                   if(inRST = '0') then
                                       sHsync_count <= (others => '0');
                                   elsif(sHsync_count < vga_res_time.H_SYNC_END_FRAME) then -- jos nismo na kraju kolone(799)(2199)
                                       sHsync_count <= std_logic_vector( unsigned(sHsync_count) + 1 );
                                   else  -- dosli smo do kraja i vracamo se na pocetak kolone(nezavisno od toga u kom smo redu) 
                                       sHsync_count <= (others => '0'); 
                                   end if;
                               end if;
                       end process Horizontal_count;

    Vertical_count : process(iCLK)
                         begin
                             if(iCLK'event and iCLK = '1') then
                                 if(inRST = '0') then
                                     sVsync_count <= (others => '0');
                                 elsif(sHsync_count = vga_res_time.H_SYNC_END_FRAME) then -- dosli smo do kraja kolone(799)(2199)
                                     if(sVsync_count < vga_res_time.V_SYNC_END_FRAME) then  -- jos nismo na kraju reda(520)(1124)
                                         sVsync_count <= std_logic_vector( unsigned(sVsync_count) + 1 );
                                     else   -- dosli smo do kraja i vracamo se na pocetak reda. Pocetak novog frame-a
                                         sVsync_count <= (others => '0');
                                     end if;
                                 end if;
                             end if; 
                     end process;

end Behavioral;
