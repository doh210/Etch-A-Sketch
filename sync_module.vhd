-------------------------------------------------------------------------------
-- Company:     ENGS 31/COSC 56, 16X
-- Engineer:    David Oh and Yima Asom
-- 
-- Create Date: 08/15/2016 09:57:52 PM
-- Design Name: 
-- Module Name: sync_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Etch-a-sketch Sync Module
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sync_module is
    Port ( clk : in STD_LOGIC;
           y_pixel : out STD_LOGIC_VECTOR (8 downto 0);
           x_pixel : out STD_LOGIC_VECTOR (9 downto 0);
           h_s : out STD_LOGIC;
           v_s : out STD_LOGIC
           );
end sync_module;

architecture Behavioral of sync_module is

    -- Video Parameters
    constant h_res:integer:=640;        --Horizontal Resolution
    constant h_fporch:integer:=16;      --Horizontal Front Porch
    constant h_bporch:integer:=48;      --Horizontal Back Porch
    constant h_pulsewidth:integer:=96;  --Horizontal retrace
    constant v_res:integer:=480;        --Vertical Resolution
    constant v_fporch:integer:=10;      --Vertical Front Porch
    constant v_bporch:integer:=29;      --Vertical Back Porch
    constant v_pulsewidth:integer:=2;   --Vertical Retrace
    
    -- Counters for sync signals
    signal counter_h,counter_h_next: integer range 0 to 799;
    signal counter_v,counter_v_next: integer range 0 to 520;
    
    -- Counter to divide clk by 4
    signal counter_4: unsigned(1 downto 0):="00";
    
    -- Terminal count signals
    signal h_end, v_end:std_logic:='0';
    
    -- Buffered output sync signals
    signal hs_buffer,hs_buffer_next:std_logic:='0';
    signal vs_buffer,vs_buffer_next:std_logic:='0';
    
    -- Pixel counterx
    signal x_counter, x_counter_next:integer range 0 to 639;
    signal y_counter, y_counter_next:integer range 0 to 479;
    
    --video_on_off
    signal video:std_logic;
  
begin

    --clk register
    process(clk)
    begin
        if rising_edge(clk) then
            counter_h<=counter_h_next;
            counter_v<=counter_v_next;
            x_counter<=x_counter_next;
            y_counter<=y_counter_next;
            hs_buffer<=hs_buffer_next;
            vs_buffer<=vs_buffer_next;
            -- Divide the current clock by 4 to get 25 MHz
            counter_4 <= counter_4 + 1;
       end if;

    end process;
    
    
--video on/off
video <= '1' when 
(counter_v >= v_pulsewidth + v_bporch) and 
(counter_v < v_pulsewidth + v_bporch + v_res) and
(counter_h >= h_pulsewidth + h_bporch) and
(counter_h < h_pulsewidth + h_bporch + h_res)    
else
    '0';

-- Assign terminal signals for horizontal and vertical counters
h_end <= '1' when counter_h=799 else '0';
v_end <= '1' when counter_v=520 else '0';

-- Horizontal Counter
H_Counter: process(counter_h,counter_4,h_end)
begin
counter_h_next<=counter_h;
if counter_4 = 0 then
    if h_end='1' then
        counter_h_next<=0;
    else
        counter_h_next<=counter_h+1;
    end if;
end if;
end process;

-- Vertical Counter
V_Counter: process(counter_v,counter_4,h_end,v_end)
begin
    counter_v_next <= counter_v;
    if counter_4 = 0 and h_end='1' then
        if v_end='1' then
            counter_v_next<=0;
        else
            counter_v_next<=counter_v+1;
        end if;
   end if;
end process;

PixelX_Counter: process(x_counter,counter_4,h_end,video)
begin
     x_counter_next<=x_counter;
     -- Increment x when within the valid region
     if video = '1' then
        if counter_4 = 0 then
            if x_counter = 639 then
                x_counter_next<=0;
            else
                x_counter_next<=x_counter + 1;
            end if;
        end if;
   else
        x_counter_next<=0;
   end if;
end process;

PixelY_Counter: process(y_counter,counter_4,h_end,counter_v)
begin
     y_counter_next<=y_counter;
     -- Increment y when x has finished
     if counter_4 = 0 and h_end = '1' then
        if counter_v >= v_pulsewidth + v_bporch and counter_v < v_pulsewidth + v_bporch + v_res then
            y_counter_next<=y_counter + 1;
        else
            y_counter_next<=0;
        end if;
     end if;
end process;

-- Assign when the sync signal should be high
hs_buffer_next <= '0' when counter_h < 96 else '1';
vs_buffer_next <= '0' when counter_v < 2 else '1';

-- Assign outputs from buffer
y_pixel <= std_logic_vector(to_unsigned(y_counter, y_pixel'length));
x_pixel <= std_logic_vector(to_unsigned(x_counter, x_pixel'length));
h_s<= hs_buffer;
v_s<= vs_buffer;

end Behavioral;