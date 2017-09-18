library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package VGA_package is
 type resolution is (vga_640x480, vga_1920x1080);
 
 
 type vga_sync_types is record
                                 H_SYNC_START      : integer;
                                 H_SYNC_END        : integer;
                                 H_SYNC_END_FRAME  : integer;
                                 V_SYNC_START      : integer;
                                 V_SYNC_END        : integer;
                                 V_SYNC_END_FRAME  : integer;
 end record vga_sync_types;
 
 
function vga_resolution(constant res : resolution) return vga_sync_types;
 
end VGA_package;


package body VGA_package is
    function vga_resolution(constant res: resolution) return vga_sync_types is
        variable vga_types : vga_sync_types;
            begin
                case res is
                    when vga_640x480   =>
                        vga_types.H_SYNC_START     := 655;
                        vga_types.H_SYNC_END       := 751;
                        vga_types.H_SYNC_END_FRAME := 799;
                        vga_types.V_SYNC_START     := 489;
                        vga_types.V_SYNC_END       := 491;
                        vga_types.V_SYNC_END_FRAME := 520; 
                    when vga_1920x1080 =>
                        vga_types.H_SYNC_START     := 2007;
                        vga_types.H_SYNC_END       := 2051;
                        vga_types.H_SYNC_END_FRAME := 2199;
                        vga_types.V_SYNC_START     := 1083;
                        vga_types.V_SYNC_END       := 1088;
                        vga_types.V_SYNC_END_FRAME := 1124;
                end case;
                return vga_types;
            end;
end VGA_package;

