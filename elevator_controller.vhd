------------------------------------------------------------------------
-- University  : University of Alberta 
-- Author      : Shyama Gandhi
-- Course      : ECE-410
-- Title       : elevator_controller.vhdl
-- Date        : 06-Nov-2022
-- Additional Comments:
-- Copyright : University of Alberta, 2022
-- License : CC0 1.0 Universal
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY cabin_controller_1 IS
    PORT (
        clock        : IN STD_LOGIC;
        cabin_btn    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);  -- Floor selection buttons (they are the same inside and outside)
        floor_sensor : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- Elevator floor position sensor
        alarm_led    : OUT STD_LOGIC := '0';
        row          : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        column       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
        motor_led    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Elevator motor (01 moving down, 10 moving up)
        floor_led    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Binary value of floor
        cc           : OUT STD_LOGIC := '0';             -- Controls active display
        segments     : OUT STD_LOGIC_VECTOR (6 DOWNTO 0) --controls active segments
    );
END cabin_controller_1;

ARCHITECTURE Mealy OF cabin_controller_1 IS

    SIGNAL floor_signal, request_signal, motor, floor         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL valid_sensor, valid_btn, clock_div                 : STD_LOGIC             := '0';
    SIGNAL emergency_timer, alarm_signal, reset, timer_signal : STD_LOGIC             := '0';
    SIGNAL destination                                        : INTEGER RANGE 0 TO 3  := 0;
    SIGNAL location                                           : INTEGER RANGE -1 TO 3 := 0;
    TYPE elevator_state_type IS (FLOOR_0, FLOOR_1, FLOOR_2, FLOOR_3, MOVING_DOWN, MOVING_UP, ALARM);
    SIGNAL state, next_state  : elevator_state_type := FLOOR_0;
    SIGNAL ticks, secs, timer : INTEGER             := 0;
    --    CONSTANT count           : INTEGER             := 2; -- for simulation
    CONSTANT count : INTEGER := 6_250_000; -- for implementation

BEGIN
    floor_encoder     : ENTITY work.priority_encoder(Behavioral) PORT MAP(data_in => floor_sensor, group_select => valid_sensor, data_out => floor_signal);
    cabin_btn_encoder : ENTITY work.priority_encoder(Behavioral) PORT MAP(data_in => cabin_btn, group_select => valid_btn, data_out => request_signal);
    alarm_fsm         : ENTITY work.alarm_fsm(Behavioral) PORT MAP(clock => clock, alarm => emergency_timer, row => row, column => column, alarm_led => alarm_led, rst => reset, alarm_timer => timer_signal);
    ssd_controller    : ENTITY work.display_controller(Behavioral) PORT MAP(clock => clock, alarm => timer_signal, motor => motor, floor => floor, cc => cc, segments => segments);

    motor_led <= motor;
    floor_led <= floor;

    WITH valid_sensor SELECT
        location <= to_integer(unsigned(floor_signal)) WHEN '1',
                                                   - 1 WHEN OTHERS;
    floor <= floor_signal;
    -- Clock divider and state update
    PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) THEN
            ticks <= ticks + 1;
            IF ticks = count THEN
                ticks     <= 0;
                clock_div <= NOT clock_div;
                state     <= next_state;
            END IF;
        END IF;
    END PROCESS;

    destination_process : PROCESS (clock_div, reset)
    BEGIN
        IF rising_edge(clock_div) AND valid_btn = '1' THEN
            CASE request_signal IS
                WHEN "00"   => destination   <= 0;
                WHEN "01"   => destination   <= 1;
                WHEN "10"   => destination   <= 2;
                WHEN "11"   => destination   <= 3;
                WHEN OTHERS => destination <= 0; -- Default value
            END CASE;
        END IF;

        IF reset = '1' THEN
            destination <= 0;
        END IF;
    END PROCESS;
    PROCESS (state, location, destination, emergency_timer) -- Mealy FSM
    BEGIN
        CASE state IS

            WHEN FLOOR_0 =>
                emergency_timer <= '0';
                IF destination > 0 THEN
                    next_state <= MOVING_UP;
                    motor      <= "10";
                ELSE
                    next_state <= FLOOR_0;
                    motor      <= "00";
                END IF;

            WHEN FLOOR_1 =>
                emergency_timer <= '0';
                IF destination > 1 THEN
                    next_state <= MOVING_UP;
                    motor      <= "10";
                ELSIF destination < 1 THEN
                    next_state <= MOVING_DOWN;
                    motor      <= "01";
                ELSE
                    next_state <= FLOOR_1;
                    motor      <= "00";
                END IF;

            WHEN FLOOR_2 =>
                emergency_timer <= '0';
                IF destination > 2 THEN
                    next_state <= MOVING_UP;
                    motor      <= "10";
                ELSIF destination < 2 THEN
                    next_state <= MOVING_DOWN;
                    motor      <= "01";
                ELSE
                    next_state <= FLOOR_2;
                    motor      <= "00";
                END IF;

            WHEN FLOOR_3 =>
                emergency_timer <= '0';
                IF destination < 3 THEN
                    next_state <= MOVING_DOWN;
                    motor      <= "01";
                ELSE
                    next_state <= FLOOR_3;
                    motor      <= "00";
                END IF;

            WHEN MOVING_UP =>
                emergency_timer <= '1';
                IF location = destination THEN
                    IF location = 1 THEN
                        next_state <= FLOOR_1;
                    ELSIF location = 2 THEN
                        next_state <= FLOOR_2;
                    ELSIF location = 3 THEN
                        next_state <= FLOOR_3;
                    END IF;
                    motor <= "00";
                ELSE
                    next_state <= MOVING_UP;
                    motor      <= "10";
                END IF;

            WHEN MOVING_DOWN =>
                emergency_timer <= '1';
                IF location = destination THEN
                    IF location = 0 THEN
                        next_state <= FLOOR_0;
                    ELSIF location = 1 THEN
                        next_state <= FLOOR_1;
                    ELSIF location = 2 THEN
                        next_state <= FLOOR_2;
                    END IF;
                    motor <= "00";
                ELSE
                    next_state <= MOVING_DOWN;
                    motor      <= "01";
                END IF;

            WHEN ALARM =>
                next_state <= ALARM;
                IF reset = '1' THEN
                    alarm_signal <= '0';
                    next_state   <= FLOOR_0;
                END IF;
        END CASE;
    END PROCESS;
END Mealy;
