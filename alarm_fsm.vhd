LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY alarm_fsm IS
    PORT (
        clock       : IN STD_LOGIC;
        alarm       : IN STD_LOGIC;
        row         : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        rst         : OUT STD_LOGIC;
        column      : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
        alarm_timer : OUT STD_LOGIC;
        alarm_led   : OUT STD_LOGIC
    );
END alarm_fsm;

ARCHITECTURE Behavioral OF alarm_fsm IS
    TYPE alarm_state_type IS (LED_ON, LED_OFF, IDLE);
    SIGNAL current_state, next_state                           : alarm_state_type := IDLE;
    SIGNAL clock_signal, clock_signal_1Hz, alarm_Signal, reset : STD_LOGIC        := '0';
    SIGNAL timer                                               : INTEGER          := 0;

BEGIN
    rst         <= reset;
    alarm_timer <= alarm_signal;
    clock_div     : ENTITY work.clock_divider(Behavioral) GENERIC MAP(freq_out => 8)PORT MAP(clock => clock, clock_div => clock_signal);
    clock_div_1Hz : ENTITY work.clock_divider(Behavioral) GENERIC MAP(freq_out => 1)PORT MAP(clock => clock, clock_div => clock_signal_1Hz);
    keypad_reset  : ENTITY work.keypad_press(Behavioral) PORT MAP(clock => clock, row => row, column => column, data_out => reset);

    state_update : PROCESS (clock_signal, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= IDLE;
        ELSIF rising_edge(clock_signal) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    alarm_process : PROCESS (clock_signal_1Hz, reset, timer, alarm)
    BEGIN
        IF rising_edge(clock_signal_1Hz) AND alarm = '1' THEN
            timer <= timer + 1;
        END IF;

        IF timer >= 10 THEN
            alarm_signal <= '1';
        END IF;

        IF alarm = '0' OR reset = '1' THEN
            timer        <= 0;
            alarm_signal <= '0';
        END IF;

    END PROCESS;

    PROCESS (current_state, alarm_signal, reset)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                IF reset = '0' AND alarm_signal = '1' THEN
                    next_state <= LED_ON;
                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN LED_ON =>
                IF reset = '1' AND alarm_signal = '0' THEN
                    next_state <= IDLE;
                ELSE
                    next_state <= LED_OFF;
                END IF;

            WHEN LED_OFF =>
                IF reset = '1' AND alarm_signal = '0' THEN
                    next_state <= IDLE;
                ELSE
                    next_state <= LED_ON;
                END IF;
        END CASE;

    END PROCESS;

    PROCESS (current_state)
    BEGIN
        CASE current_state IS
            WHEN LED_ON =>
                alarm_led <= '1';
            WHEN LED_OFF =>
                alarm_led <= '0';
            WHEN OTHERS =>
                alarm_led <= '0';
        END CASE;
    END PROCESS;

END Behavioral;
