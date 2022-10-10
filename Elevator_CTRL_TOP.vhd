
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY Elevator_CTRL_TOP IS
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
END Elevator_CTRL_TOP;

ARCHITECTURE RTL OF Elevator_CTRL_TOP IS

    COMPONENT Request_Resolver IS
        GENERIC (
            Floors_Count_cnfg : INTEGER := 10;
            Floor_Bits_Count_cnfg : INTEGER := 4
        );
        PORT (
            clock : IN STD_LOGIC;
            rst_n : IN STD_LOGIC;
            Buttons_Inside : IN unsigned (Floors_Count_cnfg - 1 DOWNTO 0);
            Outside_Dn_Buttons : IN unsigned (Floors_Count_cnfg - 1 DOWNTO 0);
            Outside_Up_Buttons : IN unsigned (Floors_Count_cnfg - 1 DOWNTO 0);
            Floor_In : IN unsigned (Floor_Bits_Count_cnfg - 1 DOWNTO 0);
            UP : IN STD_LOGIC;
            DN : IN STD_LOGIC;
            DOOR_OPEN : IN STD_LOGIC;
            Req_Valid : OUT STD_LOGIC;
            Resolved_Floor : OUT unsigned (Floor_Bits_Count_cnfg - 1 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT Elevator_FSM IS
        GENERIC (
            Floors_Count : INTEGER := 10;
            Floor_Bits_Count : INTEGER := 4
        );
        PORT (
            clock : IN STD_LOGIC;
            rst_n : IN STD_LOGIC;
            Req_Floor : IN unsigned (Floor_Bits_Count - 1 DOWNTO 0);
            Req_Valid : IN STD_LOGIC;
            Buttons_Inside :        IN unsigned (Floors_Count - 1 DOWNTO 0);
            Outside_Up_Buttons :    IN unsigned (Floors_Count - 1 DOWNTO 0);
            Current_Floor : OUT unsigned (Floor_Bits_Count - 1 DOWNTO 0);
            up : OUT STD_LOGIC;
            down : OUT STD_LOGIC;
            door_open : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL Req_Valid_Int : STD_LOGIC;
    SIGNAL Resolved_Floor_Int : unsigned (Floor_Bits_Count_Top - 1 DOWNTO 0);
    SIGNAL Current_Floor_Int : unsigned (Floor_Bits_Count_Top - 1 DOWNTO 0);
    SIGNAL up_Int : STD_LOGIC;
    SIGNAL down_Int : STD_LOGIC;
    SIGNAL door_open_Int : STD_LOGIC;

BEGIN

    Current_Floor <= Current_Floor_Int;
    up <= up_Int;
    down <= down_Int;
    door_open <= door_open_Int;

    Req_Resolver_Module : Request_Resolver
    GENERIC MAP(Floors_Count_cnfg => Floors_Count_Top, Floor_Bits_Count_cnfg => Floor_Bits_Count_Top)
    PORT MAP(clock, rst_n, Buttons_Inside, Outside_Dn_Buttons, Outside_Up_Buttons, Current_Floor_Int, up_Int, down_Int, door_open_Int, Req_Valid_Int, Resolved_Floor_Int);

    FSM_Module : Elevator_FSM
    GENERIC MAP(Floors_Count => Floors_Count_Top, Floor_Bits_Count => Floor_Bits_Count_Top)
    PORT MAP(clock, rst_n, Resolved_Floor_Int, Req_Valid_Int, Buttons_Inside, Outside_Up_Buttons, Current_Floor_Int, up_Int, down_Int, door_open_Int);

END RTL; -- RTL