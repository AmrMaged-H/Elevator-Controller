
LIBRARY IEEE; -- ADDED
USE IEEE.std_logic_1164.ALL; -- ADDED
USE IEEE.numeric_std.ALL; -- ADDED
USE IEEE.std_logic_textio.ALL; -- ADDED

LIBRARY std;
USE std.textio.ALL;

ENTITY elevator_ctrl_tb IS
    -- No Inputs OR Outputs
END elevator_ctrl_tb;

ARCHITECTURE Behaviour OF elevator_ctrl_tb IS

    -------------------------------------------------------------------------------------------------------
    -------------------------------------- DUT Component Definition ---------------------------------------
    -------------------------------------------------------------------------------------------------------

    COMPONENT Elevator_CTRL_TOP IS
        GENERIC (
            Floors_Count_Top : INTEGER := 10;
            Floor_Bits_Count_Top : INTEGER := 4
        );
        PORT (
            clock : IN STD_LOGIC;
            rst_n : IN STD_LOGIC;
            Outside_Up_Buttons : IN unsigned (Floors_Count_Top - 1 DOWNTO 0);
            Outside_Dn_Buttons : IN unsigned (Floors_Count_Top - 1 DOWNTO 0);
            Buttons_Inside : IN unsigned (Floors_Count_Top - 1 DOWNTO 0);
            Current_Floor : OUT unsigned (Floor_Bits_Count_Top - 1 DOWNTO 0);
            up : OUT STD_LOGIC;
            down : OUT STD_LOGIC;
            door_open : OUT STD_LOGIC
        );
    END COMPONENT;

    -------------------------------------------------------------------------------------------------------
    ------------------------------------ TestBench Signals Definition -------------------------------------
    -------------------------------------------------------------------------------------------------------

    SIGNAL clk_tb : STD_LOGIC;
    SIGNAL rst_n_tb : STD_LOGIC;
    SIGNAL up_tb : STD_LOGIC;
    SIGNAL down_tb : STD_LOGIC;
    SIGNAL door_open_tb : STD_LOGIC;
    SIGNAL Outside_Up_Buttons_tb : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL Outside_Dn_Buttons_tb : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL Buttons_Inside_tb : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL Current_Floor_tb : unsigned (3 DOWNTO 0);
    SIGNAL NextInput : STD_LOGIC;

BEGIN

    -------------------------------------------------------------------------------------------------------
    ------------------------------------ DUT Component Instantiation --------------------------------------
    -------------------------------------------------------------------------------------------------------
    CTRL_Top_Module : Elevator_CTRL_TOP
    GENERIC MAP(Floors_Count_Top => 10, Floor_Bits_Count_Top => 4)
    PORT MAP(
        clk_tb, rst_n_tb, unsigned(Outside_Up_Buttons_tb), unsigned(Outside_Dn_Buttons_tb),
        unsigned(Buttons_Inside_tb), Current_Floor_tb, up_tb, down_tb, door_open_tb);
    -------------------------------------------------------------------------------------------------------
    ------------------------------------------- Applying Inputs -------------------------------------------
    -------------------------------------------------------------------------------------------------------

    Buttons_Process : PROCESS
        -------------------------------------------------------------------------------------------------------
        PROCEDURE CNFG_UP_Buttons (
            Applied_In : IN STD_LOGIC_VECTOR (9 DOWNTO 0)
        ) IS

        BEGIN
            Outside_Up_Buttons_tb <= Applied_In;
        END CNFG_UP_Buttons;

        PROCEDURE CNFG_DN_Buttons (
            Applied_In : IN STD_LOGIC_VECTOR (9 DOWNTO 0)
        ) IS

        BEGIN
            Outside_Dn_Buttons_tb <= Applied_In;
        END CNFG_DN_Buttons;

        PROCEDURE CNFG_IN_Buttons (
            Applied_In : IN STD_LOGIC_VECTOR (9 DOWNTO 0)
        ) IS

        BEGIN
            Buttons_Inside_tb <= Applied_In;
        END CNFG_IN_Buttons;
        -------------------------------------------------------------------------------------------------------
    BEGIN
        write (output, "The First Input aims to test openning the door at Floor No. 0" & LF);

        CNFG_UP_Buttons ("0000000001");
        CNFG_DN_Buttons ("0000000000");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        write (output,LF & "The Second Input Sequence aims to test Multiple Up Requests" & LF);

        CNFG_UP_Buttons ("0100100100");
        CNFG_DN_Buttons ("0000000000");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0100100000");
        CNFG_DN_Buttons ("0000000000");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0100000000");
        CNFG_DN_Buttons ("0000000000");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        write (output, LF & "The Third Input Sequence aims to test Multiple Dn Requests" & LF);

        CNFG_UP_Buttons ("0000000000");
        CNFG_DN_Buttons ("0001010100");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0000000000");
        CNFG_DN_Buttons ("0000010100");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0000000000");
        CNFG_DN_Buttons ("0000000001");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        write (output, LF & "The Fourth Input Sequence aims to test Going Up With neglecting Down Requests" & LF);

        CNFG_UP_Buttons ("0100100100");
        CNFG_DN_Buttons ("0010010010");
        CNFG_IN_Buttons ("0000010000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0100100000");
        CNFG_DN_Buttons ("0010010010");
        CNFG_IN_Buttons ("0000010000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0100100000");
        CNFG_DN_Buttons ("0010010010");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0100000000");
        CNFG_DN_Buttons ("0010010010");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        write (output, LF & "Then The Elevator Should Respond To Dn Requests After Going all the way up And Neglect Lower Up Req." & LF);

        CNFG_UP_Buttons ("0000101000");
        CNFG_DN_Buttons ("0010010010");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0000101000");
        CNFG_DN_Buttons ("0000010010");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        CNFG_UP_Buttons ("0000101000");
        CNFG_DN_Buttons ("0000000010");
        CNFG_IN_Buttons ("0000000000");

        WAIT UNTIL (door_open_tb = '1');

        write (output, LF & "Now We May Test The case in which the only request is a down one above the current floor," & LF);
        write (output, "So, The Elevator Should Respond And Go Up" & LF);

        CNFG_UP_Buttons ("0000000000");
        CNFG_DN_Buttons ("0100000000");
        CNFG_IN_Buttons ("0000000000");


        WAIT UNTIL (door_open_tb = '1');

        write (output, LF & "Now We May Test The case in which the only request is an up one below the current floor," & LF);
        write (output, "So, The Elevator Should Respond And Go Down" & LF);

        CNFG_UP_Buttons ("0000000010");
        CNFG_DN_Buttons ("0000000000");
        CNFG_IN_Buttons ("0000000000");

        WAIT;

    END PROCESS; -- Buttons_Process

    -------------------------------------------------------------------------------------------------------
    ------------------------------------------ Monitoring Inputs ------------------------------------------
    -------------------------------------------------------------------------------------------------------  
    Monitor_Inputs_Process : PROCESS (Outside_Dn_Buttons_tb, Outside_Up_Buttons_tb, Buttons_Inside_tb)
    BEGIN
        write (output, "Up Buttons = " & to_string (Outside_Up_Buttons_tb) & LF);
        write (output, "Dn Buttons = " & to_string (Outside_Dn_Buttons_tb) & LF);
        write (output, "Inner Buttons = " & to_string (Buttons_Inside_tb) & LF);
    END PROCESS; -- Monitor_Inputs_Process  

    -------------------------------------------------------------------------------------------------------
    ----------------------------------------- Monitoring Elevator -----------------------------------------
    -------------------------------------------------------------------------------------------------------  

    Monitoring_Elevator_Process : PROCESS (Current_Floor_tb, up_tb, down_tb, door_open_tb)
    BEGIN
        IF (up_tb) THEN
            write (output, "The Eelvator Is Moving Up And Floor =  " & to_string (to_integer(Current_Floor_tb)) & LF);
        ELSIF (down_tb) THEN
            write (output, "The Eelvator Is Moving Down And Floor =  " & to_string (to_integer(Current_Floor_tb)) & LF);
        ELSIF (door_open_tb) THEN
            write (output, "The Eelvator Is Opened And Floor =  " & to_string (to_integer(Current_Floor_tb)) & LF);
        END IF;

    END PROCESS; -- Monitoring_Elevator_Process
    -------------------------------------------------------------------------------------------------------
    ------------------------------------------- Clock Generator -------------------------------------------
    -------------------------------------------------------------------------------------------------------
    Clock_Process : PROCESS
    BEGIN
        clk_tb <= '0';
        WAIT FOR 10 NS;
        clk_tb <= '1';
        WAIT FOR 10 NS;
    END PROCESS; -- Clock_Process

    -------------------------------------------------------------------------------------------------------
    -------------------------------------------- Reset Sequence -------------------------------------------
    -------------------------------------------------------------------------------------------------------
    RST_Process : PROCESS
    BEGIN
        rst_n_tb <= '0';
        WAIT FOR 10 NS;
        rst_n_tb <= '1';
        WAIT;
    END PROCESS; -- Clock_Process
END Behaviour; -- Behaviour