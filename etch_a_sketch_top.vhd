-------------------------------------------------------------------------------
-- Company:     ENGS 31/COSC 56, 16X
-- Engineer:    David Oh and Yima Asom
-- 
-- Create Date: 08/19/2016 01:49:00 PM
-- Design Name: 
-- Module Name: etch_a_sketch_top - Behavioral
-- Project Name: Etch-a-sketch
-- Target Devices: Digilent Basys3 (Artix 7)
-- Tool Versions: 
-- Description: Etch-a-sketch Top Level File
-- 
-- Dependencies: 
-- sync_module.vhd
-- button_module.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity etch_a_sketch_top is
    port(   mclk                : in std_logic;
            a_right, b_right, a_left, b_left : in std_logic;
            color_switch0, color_switch1, color_switch2    : in std_logic;
            reset               : in std_logic;
            color               : out std_logic_vector(11 downto 0);
            hsync, vsync        : out std_logic);
            
end etch_a_sketch_top;

architecture Behavioral of etch_a_sketch_top is

-- Component declarations
    component sync_module is
        Port (
            clk : in STD_LOGIC;
            y_pixel : out STD_LOGIC_VECTOR (8 downto 0);
            x_pixel : out STD_LOGIC_VECTOR (9 downto 0);
            h_s : out STD_LOGIC;
            v_s : out STD_LOGIC );
    end component;
    
    component button_module is
        Port ( 
            clk : in std_logic;
            a_right, b_right, a_left, b_left : in std_logic;
            right_value, left_value          : out unsigned(1 downto 0)
            );
    end component;

-- SIGNAL DECLARATIONS

-- Create RAM
constant RAM_ADDR_BITS  : integer := 17;
constant RAM_WIDTH      : integer := 3;
type ram_type is array (2**RAM_ADDR_BITS-1 downto 0) of std_logic_vector (RAM_WIDTH-1 downto 0);
signal myRAM            : ram_type;

-- Color constants
constant RED            : std_logic_vector(11 downto 0) := "111100000000";
constant GREEN          : std_logic_vector(11 downto 0) := "000011110000";
constant BLUE           : std_logic_vector(11 downto 0) := "000000001111";
constant CYAN           : std_logic_vector(11 downto 0) := "000011111111";
constant YELLOW         : std_logic_vector(11 downto 0) := "111111110000";
constant PURPLE         : std_logic_vector(11 downto 0) := "111100001111";
constant WHITE          : std_logic_vector(11 downto 0) := "111111111111";
constant BLACK          : std_logic_vector(11 downto 0) := "000000000000";
constant GRAY0          : std_logic_vector(11 downto 0) := "110011001100";
constant GRAY1          : std_logic_vector(11 downto 0) := "011001100110";
constant DARK_BLU       : std_logic_vector(11 downto 0) := "000010001000";
constant DARK_PUR       : std_logic_vector(11 downto 0) := "010000001000";

-- Row and column signals to get from sync_module
signal row          : std_logic_vector(8 downto 0) := (others => '0');
signal column       : std_logic_vector(9 downto 0) := (others => '0');

-- Tracker for pixel in etch-a-sketch
signal curr_x       : std_logic_vector(9 downto 0) := "0000000001";
signal curr_y       : std_logic_vector(8 downto 0) := "000000001";

-- Reset pixel counters
signal reset_x       : std_logic_vector(9 downto 0) := (others => '0');
signal reset_y       : std_logic_vector(8 downto 0) := (others => '0');

signal addra        : std_logic_vector(16 downto 0) := (others => '0');

signal r_inc, l_inc : unsigned(1 downto 0) := (others => '0');

-- Write and read data for RAM, respectively
signal color_to_save    : std_logic_vector(RAM_WIDTH-1 downto 0);
signal RAM_to_color : std_logic_vector(RAM_WIDTH-1 downto 0);

signal ena          : std_logic := '1';

signal start        : std_logic := '1';

signal counter_64: unsigned(5 downto 0):="000000";

signal reset_counter : unsigned(16 downto 0) := (others => '0');
    
begin

-- Select corresponding color from 3-bit RAM data
ChooseColor: process(RAM_to_color)
begin
case to_integer(unsigned(RAM_to_color)) is
    when 0 =>
        color <= BLACK;
    when 1 =>
        color <= BLUE;
    when 2 =>
        color <= GREEN;
    when 3 =>
        color <= CYAN;
    when 4 =>
        color <= RED;
    when 5 =>
        color <= PURPLE;
    when 6 =>
        color <= YELLOW;
    when 7 =>
        color <= WHITE;
    when others =>
        color <= BLACK;
end case;
end process;


ResetRAM: process(mclk)--reset_y,reset_x)
begin
    if rising_edge(mclk) then
    if start = '1' then
            if (reset_x >= 0 and reset_x < 639) and (reset_y >= 0 and reset_y < 479) then 
                reset_x <= std_logic_vector(unsigned(reset_x) + 1);
            else
                reset_x <= "0000000000"; 
                reset_y <= std_logic_vector(unsigned(reset_y) + 1);
            end if;
        end if;
    end if;
end process;
    
-- Set the colors based on the current pixel from sync_module
ReadRAM: process(column, row)
begin
    RAM_to_color <= myRAM( to_integer(unsigned(column(9 downto 1)) & unsigned(row(8 downto 1))));
end process;

-- Write the data for the current pixel into RAM
WriteRAM: process(mclk)
begin
    if rising_edge(mclk) then
        if start = '1' then 
            myRAM( to_integer(unsigned(reset_x(9 downto 1)) & unsigned(reset_y(8 downto 1))) ) <= color_to_save;
        else 
            myRAM( to_integer(unsigned(curr_x(9 downto 1)) & unsigned(curr_y(8 downto 1))) ) <= color_to_save;
        end if; 
    end if;
end process;

-- Toggle colors based on the switch inputs
ColorSelect: process(color_switch2, color_switch1, color_switch0, reset)
begin
    if reset = '0' then
        color_to_save <= color_switch2 & color_switch1 & color_switch0;
    else 
        color_to_save <= '0' & '0' & '0';
    end if;
end process;

-- Incrementer/decrementer using knob output values
RotateKnobs: process(mclk)
begin
    if rising_edge(mclk) then
        if reset = '0' then
            start <= '0';
            if (r_inc = 1) and (curr_x < 640 - 1) then
                curr_x <= std_logic_vector(unsigned(curr_x) + 1);
            end if;
            if (r_inc = 2) and (curr_x > 1) then
                curr_x <= std_logic_vector(unsigned(curr_x) - 1);
            end if;
            if (l_inc = 1) and (curr_y < 480 - 1) then
                curr_y <= std_logic_vector(unsigned(curr_y) + 1);
            end if;
            if (l_inc = 2) and (curr_y > 1) then
                curr_y <= std_logic_vector(unsigned(curr_y) - 1);
            end if;
        else
            curr_x <= "0000000000";
            curr_y <= "000000000";
            start <= '1';
        end if;
    end if;
end process;

-- Map signals to modules
video: sync_module port map(
    clk => mclk,
    y_pixel => row,
    x_pixel => column,
    h_s => hsync,
    v_s => vsync );
    
button: button_module port map(
    clk => mclk,
    a_right => a_right,
    b_right => b_right,
    a_left => a_left,
    b_left => b_left,
    right_value => r_inc,
    left_value => l_inc);

end Behavioral;