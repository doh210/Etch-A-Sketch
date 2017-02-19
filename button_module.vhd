-------------------------------------------------------------------------------
-- Company:     ENGS 31/COSC 56, 16X
-- Engineer:    David Oh and Yima Asom
-- 
-- Create Date: 08/19/2016 02:40:36 PM
-- Design Name: 
-- Module Name: button_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Etch-a-sketch Button/Knob Module
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

entity button_module is
    Port ( clk          : in std_logic;
           a_right, b_right, a_left, b_left : in std_logic;
           right_value, left_value          : out unsigned(1 downto 0));
end button_module;

architecture Behavioral of button_module is

type state_type is (Idle, A_hfirst, B_hfirst, A_hsecond, B_hsecond, A_lfirst, B_lfirst, A_lsecond, B_lsecond);
signal curr_stateR, next_stateR, curr_stateL, next_stateL: state_type;

begin

StateUpdate: process(clk)
begin
    if rising_edge(clk) then
        curr_stateR <= next_stateR;
        curr_stateL <= next_stateL;
    end if;
end process;

-- Logic for right knob
CombLogicR: process(curr_stateR, a_right, b_right)
begin
    right_value <= "00";
    next_stateR <= curr_stateR;
    case curr_stateR is
        when Idle =>
            -- Contrary to online documentation, the signals are high when idle
            -- Wait for a falling edge in either A or B
            if (a_right = '0') and (b_right = '1')then
                next_stateR <= A_hfirst;
            elsif (b_right = '0') and (a_right = '1') then
                next_stateR <= B_hfirst;
            end if;
        when A_hfirst =>
            if (b_right = '0') and (a_right = '0') then
                next_stateR <= B_hsecond;
            end if;
        when B_hfirst =>
            if (a_right = '0') and (b_right = '0')then
                next_stateR <= A_hsecond;
            end if;
        when A_hsecond =>
            if (b_right = '1') and (a_right = '0') then
                next_stateR <= B_lfirst;
            end if;
        when B_hsecond =>
            if (a_right = '1') and (b_right = '0') then
                next_stateR <= A_lfirst;
            end if;
        when A_lfirst =>
            if (b_right = '1') and (a_right = '1') then
                next_stateR <= B_lsecond;
            end if;
        when B_lfirst =>
            if (a_right = '1') and (b_right = '1') then
                next_stateR <= A_lsecond;
            end if;
        when A_lsecond =>
            -- Decrement
            right_value <= "10";
            next_stateR <= Idle;
        when B_lsecond =>
            -- Increment
            right_value <= "01";
            next_stateR <= Idle;
    end case;
end process;

-- Logic for left knob
CombLogicL: process(curr_stateL, a_left, b_left)
begin
    left_value <= "00";
    next_stateL <= curr_stateL;
    case curr_stateL is
        when Idle =>
            -- Contrary to online documentation, the signals are high when idle
            -- Wait for a falling edge in either A or B
            if (a_left = '0') and (b_left = '1') then
                next_stateL <= A_hfirst;
            elsif (b_left = '0') and (a_left = '1') then
                next_stateL <= B_hfirst;
            end if;
        when A_hfirst =>
            if (b_left = '0') and (a_left = '0') then
                next_stateL <= B_hsecond;
            end if;
        when B_hfirst =>
            if (a_left = '0') and (b_left = '0') then
                next_stateL <= A_hsecond;
            end if;
        when A_hsecond =>
            if (b_left = '1') and (a_left = '0') then
                next_stateL <= B_lfirst;
            end if;
        when B_hsecond =>
            if (a_left = '1') and (b_left = '0') then
                next_stateL <= A_lfirst;
            end if;
        when A_lfirst =>
            if (b_left = '1') and (a_left = '1') then
                next_stateL <= B_lsecond;
            end if;
        when B_lfirst =>
            if (a_left = '1') and (b_left = '1') then
                next_stateL <= A_lsecond;
            end if;
        when A_lsecond =>
            -- Decrement
            left_value <= "10";
            next_stateL <= Idle;
        when B_lsecond =>
            -- Increment
            left_value <= "01";
            next_stateL <= Idle;
        end case;
    end process;

end Behavioral;