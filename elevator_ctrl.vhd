-----------------------------------------------------------------------------------------------------------

-- Module Name : elevator_ctrl

-- Functionality:

-- This Module is to provide the required hardware validation setup for our design where The 
-- setup is limited to 4 floors only. The buttons are limited to the ones inside the elevator only 
-- the other buttons are hardwired to ‘0’ to be inactive during the test. The 4 control buttons 
-- are assumed to be KEY0, KEY1, KEY2, and KEY3. Those key correspond to bn0, bn1, 
-- bn2, and  bn3. The reset_n is active low and is tied to push button KEY4. The floor count 
-- is connected to the units SSD. The status output signal mv_up, mv_down, and door_open 
-- are connected to LED0, LED1, and LED3; respectively. 

-----------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY elevator_ctrl IS
    PORT (
        KEY0 : IN STD_LOGIC;
        KEY1 : IN STD_LOGIC;
        KEY2 : IN STD_LOGIC;
        KEY3 : IN STD_LOGIC;
        KEY4 : IN STD_LOGIC;
        LED0 : OUT STD_LOGIC;
        LED1 : OUT STD_LOGIC;
        LED2 : OUT STD_LOGIC;
        HEX0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        clk : IN STD_LOGIC
    );
END elevator_ctrl;

ARCHITECTURE RTL OF elevator_ctrl IS
    -------------------------------------------------------------------------------------------------------
    -------------------------------- Elevator_CTRL_TOP Component Definition -------------------------------
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
    ------------------------------ Seven Segment Display Component Definition -----------------------------
    -------------------------------------------------------------------------------------------------------
    COMPONENT ssd IS
        PORT (
            SW0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            OUT_SEG0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL Buttons_Inside_Int : unsigned (9 DOWNTO 0);
    SIGNAL Buttons_CNFG : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL Floor : unsigned (3 DOWNTO 0);


BEGIN
    Buttons_CNFG <= "000000" & (NOT KEY3) & (NOT KEY2) & (NOT KEY1) & (NOT KEY0);
    Buttons_Inside_Int <= unsigned(Buttons_CNFG);

    -------------------------------------------------------------------------------------------------------
    ------------------------------ Elevator_CTRL_TOP Component Instantiation ------------------------------
    -------------------------------------------------------------------------------------------------------

    CTRL_Top_Module : Elevator_CTRL_TOP
    GENERIC MAP(Floors_Count_Top => 10, Floor_Bits_Count_Top => 4)
    PORT MAP(clk, KEY4, to_unsigned(0, 10), to_unsigned(0, 10), Buttons_Inside_Int, Floor,  LED0, LED1, LED2);


    -------------------------------------------------------------------------------------------------------
    ----------------------------- Seven Segment Display Component Instantiation ---------------------------
    -------------------------------------------------------------------------------------------------------    

    SSD_Module : ssd PORT MAP (STD_LOGIC_VECTOR(Floor), HEX0);

END RTL; -- RTL