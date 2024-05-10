----------------------------------------------------------------------------------
-- Filename : display_controller.vhdl
-- Author : Shyama Gandhi
-- Date : 06-Nov-10-2022
-- Design Name: display controller
-- Module Name: VHDL_essentials
-- Project Name: VHDL_essentials
-- Description : In this file we will implement a design that can read two 4 bit
-- characters from a register and show it on the appropriate seven segments display
-- Additional Comments:
-- Copyright : University of Alberta, 2022
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY display_controller IS
    PORT (
        clock    : IN STD_LOGIC;
        alarm    : IN STD_LOGIC;
        motor    : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        floor    : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        cc       : OUT STD_LOGIC := '0';             -- Controls active display
        segments : OUT STD_LOGIC_VECTOR (6 DOWNTO 0) --controls active segments
    );
END display_controller;

ARCHITECTURE Behavioral OF display_controller IS
    SIGNAL active_display : STD_LOGIC := '0';
    SIGNAL ticks          : INTEGER   := 0;
    --    CONSTANT count                     : INTEGER                       := 2; --1_250_000;
    CONSTANT count                     : INTEGER                       := 1_250_000;
    SIGNAL display_left, display_right : STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '0'); -- active segments for each display
BEGIN

    PROCESS (clock) IS -- Clock divider
    BEGIN
        IF rising_edge(clock) THEN
            ticks <= ticks + 1;
            IF ticks = count THEN
                ticks          <= 0;
                active_display <= NOT active_display;
            END IF;
        END IF;
    END PROCESS;

    cc <= active_display;

    WITH active_display SELECT
        segments <= display_right WHEN '1',
        display_left WHEN '0',
        (OTHERS => '0') WHEN OTHERS;

    PROCESS (motor, floor, alarm)
    BEGIN
        IF alarm = '0' THEN
            IF motor = "01" THEN
                display_left <= "1100111";
            ELSIF motor = "10" THEN
                display_left <= "1110110";
            ELSE
                display_left <= "0000001";
            END IF;

            IF floor = "00" THEN
                display_right <= "1111110";
            ELSIF floor = "01" THEN
                display_right <= "0000110";
            ELSIF floor = "10" THEN
                display_right <= "1101101";
            ELSIF floor = "11" THEN
                display_right <= "1001111";
            ELSE
                display_right <= "0000001";
            END IF;
        ELSE
            display_left  <= "1111001";
            display_right <= "0100001";
        END IF;
    END PROCESS;

END Behavioral;
