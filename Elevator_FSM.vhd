-----------------------------------------------------------------------------------------------------
-- Module Name : Eelvator_FSM

-- Functionality :

-----------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY Elevator_FSM IS
    GENERIC (
        Floors_Count :      INTEGER := 10;
        Floor_Bits_Count :  INTEGER := 4
    );
    PORT (
        clock :             IN STD_LOGIC;
        rst_n :             IN STD_LOGIC;
        Req_Floor :         IN unsigned (Floor_Bits_Count - 1 DOWNTO 0);
        Req_Valid :         IN STD_LOGIC;
        Buttons_Inside :        IN unsigned (Floors_Count - 1 DOWNTO 0);
        Outside_Up_Buttons :    IN unsigned (Floors_Count - 1 DOWNTO 0);
        Current_Floor :     OUT unsigned (Floor_Bits_Count - 1 DOWNTO 0);
        up :                OUT STD_LOGIC;
        down :              OUT STD_LOGIC;
        door_open :         OUT STD_LOGIC
    );
END Elevator_FSM;

ARCHITECTURE RTL OF Elevator_FSM IS

    -------------------------------------------------------------------------------------------------------
    ------------------------------------ Counter Component Definition -------------------------------------
    -------------------------------------------------------------------------------------------------------

    COMPONENT GenCNT_En IS
        GENERIC (
            n : NATURAL := 3;
            k : NATURAL := 5);
        PORT (
            clock :     IN STD_LOGIC;
            rst_n :     IN STD_LOGIC;
            Syn_RST :   IN STD_LOGIC;
            En :        IN STD_LOGIC;
            rollover :  OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT TwoSec_CNT IS
        GENERIC (
            n : NATURAL := 1;
            k : NATURAL := 1);
        PORT (
            clock :     IN STD_LOGIC;
            rst_n :     IN STD_LOGIC;
            Syn_RST :   IN STD_LOGIC;
            En :        IN STD_LOGIC;
            rollover :  OUT STD_LOGIC);
    END COMPONENT;

    -------------------------------------------------------------------------------------------------------
    ----------------------------------------- States Definition -------------------------------------------
    -------------------------------------------------------------------------------------------------------

    CONSTANT IDLE :                     STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
    CONSTANT MOVING_UP :                STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
    CONSTANT MOVING_DN :                STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
    CONSTANT DOOR_OPEN_STATE :          STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";

    SIGNAL PS, NS :                     STD_LOGIC_VECTOR (1 DOWNTO 0);

    SIGNAL Floors_CNT :                 unsigned (Floor_Bits_Count - 1 DOWNTO 0);
    SIGNAL Incr_Floor :                 STD_LOGIC;
    SIGNAL Dec_Floor :                  STD_LOGIC;
    SIGNAL SYN_RST_CNT :                STD_LOGIC;

    SIGNAL OneSecFlag :                 STD_LOGIC;
    SIGNAL Flag_int :                   STD_LOGIC;
    SIGNAL TwoSec_Flag :                STD_LOGIC;
    SIGNAL Req_Floor_Reg :              unsigned (Floor_Bits_Count - 1 DOWNTO 0);
    SIGNAL Openning_Period_Finished :   STD_LOGIC;
    SIGNAL Req_Valid_Reg :              STD_LOGIC;

BEGIN

    -------------------------------------------------------------------------------------------------------
    ------------------------------------- One Second Cycles Counter ---------------------------------------
    -------------------------------------------------------------------------------------------------------

    OneSecond_Cycle_CNT : GenCNT_En
    GENERIC MAP(n => 26, k => 50000000)
    PORT MAP(clock, rst_n, SYN_RST_CNT, '1', OneSecFlag);

    -------------------------------------------------------------------------------------------------------
    ---------------------------------------- Two Seconds Counter ------------------------------------------
    -------------------------------------------------------------------------------------------------------

    TwoSeconds_CNT : TwoSec_CNT
    GENERIC MAP(n => 1, k => 1)
    PORT MAP(clock, rst_n, SYN_RST_CNT, OneSecFlag, Flag_int);

    TwoSec_Flag <= OneSecFlag AND Flag_int;

    -------------------------------------------------------------------------------------------------------
    ------------------------------------------ Next State Logic -------------------------------------------
    -------------------------------------------------------------------------------------------------------

    Next_State_Process : PROCESS (PS, Req_Floor_Reg, Req_Floor, Floors_CNT, Req_Valid, 
    Outside_Up_Buttons, Buttons_Inside, Openning_Period_Finished)
    BEGIN
        SYN_RST_CNT <= '0';
        CASE(PS) IS

            WHEN IDLE =>
            IF ((Outside_Up_Buttons(0) = '1') OR (Buttons_Inside(0) = '1')) THEN
                NS          <= DOOR_OPEN_STATE;
                SYN_RST_CNT <= '1';
            ELSIF ((Req_Floor_Reg > Floors_CNT) AND (Req_Valid = '1')) THEN
                NS          <= MOVING_UP;
                SYN_RST_CNT <= '1';
            ELSE
                NS          <= IDLE;
            END IF;

            WHEN MOVING_UP =>
            IF (Floors_CNT = Req_Floor_Reg) THEN
                NS          <= DOOR_OPEN_STATE;
                SYN_RST_CNT <= '1';
            ELSE
                NS          <= MOVING_UP;
            END IF;

            WHEN MOVING_DN =>
            IF (Floors_CNT = Req_Floor_Reg) THEN
                NS          <= DOOR_OPEN_STATE;
                SYN_RST_CNT <= '1';
            ELSE
                NS          <= MOVING_DN;
            END IF;

            WHEN DOOR_OPEN_STATE =>
            IF ((Floors_CNT > Req_Floor_Reg) AND (Openning_Period_Finished = '1') AND (Req_Valid = '1')) THEN
                NS          <= MOVING_DN;
                SYN_RST_CNT <= '1';
            ELSIF ((Floors_CNT < Req_Floor_Reg) AND (Openning_Period_Finished = '1') AND (Req_Valid = '1')) THEN
                NS          <= MOVING_UP;
                SYN_RST_CNT <= '1';
            ELSE
                NS          <= DOOR_OPEN_STATE;
            END IF;

            WHEN OTHERS => NS <= IDLE;

        END CASE;
    END PROCESS; -- Next_State_Process
    -------------------------------------------------------------------------------------------------------
    --------------------------------------- Present State Register ----------------------------------------
    -------------------------------------------------------------------------------------------------------

    PS_Process : PROCESS (clock, rst_n)
    BEGIN
        IF (rst_n = '0') THEN
            PS <= IDLE;
        ELSIF (rising_edge(clock)) THEN
            PS <= NS;
        END IF;
    END PROCESS; -- PS_Process

    -------------------------------------------------------------------------------------------------------
    ------------------------------------------- Floors Counter --------------------------------------------
    -------------------------------------------------------------------------------------------------------
    Floors_CNT_Process : PROCESS (clock, rst_n)
    BEGIN
        IF (rst_n = '0') THEN
            Floors_CNT <= (OTHERS => '0');
        ELSIF (rising_edge(clock)) THEN
            IF (Incr_Floor = '1') THEN
                Floors_CNT <= Floors_CNT + 1;
            ELSIF (Dec_Floor = '1') THEN
                Floors_CNT <= Floors_CNT - 1;
            END IF;
        END IF;
    END PROCESS; -- Floors_CNT_Process

    Current_Floor <= Floors_CNT;

    -------------------------------------------------------------------------------------------------------
    ------------------------------------- Floors Counter Control Flags ------------------------------------
    -------------------------------------------------------------------------------------------------------

    Incr_Floor_Process : PROCESS (PS, TwoSec_Flag)
    BEGIN
        IF ((PS = MOVING_UP) AND (TwoSec_Flag = '1')) THEN
            Incr_Floor <= '1';
        ELSE
            Incr_Floor <= '0';
        END IF;
    END PROCESS; -- Incr_Floor_Process

    Dec_Floor_Process : PROCESS (PS, TwoSec_Flag)
    BEGIN
        IF ((PS = MOVING_DN) AND (TwoSec_Flag = '1')) THEN
            Dec_Floor <= '1';
        ELSE
            Dec_Floor <= '0';
        END IF;
    END PROCESS; -- Dec_Floor_Process

    -------------------------------------------------------------------------------------------------------
    ------------------------------------------- Output Flags Logic ----------------------------------------
    -------------------------------------------------------------------------------------------------------

    Outputs_Process : PROCESS (PS)
    BEGIN
        IF (PS = MOVING_UP) THEN
            up          <= '1';
            down        <= '0';
            door_open   <= '0';
        ELSIF (PS = MOVING_DN) THEN
            up          <= '0';
            down        <= '1';
            door_open   <= '0';
        ELSIF (PS = DOOR_OPEN_STATE) THEN
            up          <= '0';
            down        <= '0';
            door_open   <= '1';
        ELSE
            up          <= '0';
            down        <= '0';
            door_open   <= '0';
        END IF;
    END PROCESS; -- Outputs_Process
    -------------------------------------------------------------------------------------------------------
    ----------------------------------------- Openning Period Flag ----------------------------------------
    -------------------------------------------------------------------------------------------------------
    Openning_Period_Finished_Process : PROCESS (clock, rst_n)
    BEGIN
        IF (rst_n = '0') THEN
            Openning_Period_Finished <= '0';
        ELSIF (rising_edge (clock)) THEN
            IF (PS /= DOOR_OPEN_STATE) THEN
                Openning_Period_Finished <= '0';
            ELSIF ((PS = DOOR_OPEN_STATE) AND (TwoSec_Flag = '1')) THEN
                Openning_Period_Finished <= '1';
            END IF;
        END IF;

    END PROCESS; -- Openning_Period_Finished_Process

    Req_Floor_Reg_Process : PROCESS (clock, rst_n)
    BEGIN
        IF (rst_n = '0') THEN
            Req_Floor_Reg <= (OTHERS => '0');
        ELSIF (rising_edge (clock)) THEN
            IF (Req_Valid = '1') THEN
                Req_Floor_Reg <= Req_Floor;
            END IF;
        END IF;

    END PROCESS; -- Req_Floor_Reg_Process

END RTL; -- RTL