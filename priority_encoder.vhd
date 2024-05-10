----------------------------------------------------------------------------------
-- Filename : priority_encoder.vhdl
-- Author : Shyama Gandhi
-- Date : 06-Nov-10-2022
-- Design Name: 4:2 priority encoder
-- Module Name: VHDL_essentials
-- Project Name: VHDL_essentials
-- Description : In this file we will implement a 4:2 lines priority encoder
-- using positive logic
-- Additional Comments:
-- Copyright : University of Alberta, 2022
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY priority_encoder IS
    PORT (
        data_in      : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        data_out     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        group_select : OUT STD_LOGIC
    );
END priority_encoder;

ARCHITECTURE Behavioral OF priority_encoder IS
BEGIN

    group_select <= data_in(0) OR data_in(1) OR data_in(2) OR data_in(3);
    data_out(1)     <= data_in(2) OR data_in(3);
    data_out(0)     <= (NOT(data_in(2)) AND data_in(1)) OR data_in(3);

END Behavioral;
