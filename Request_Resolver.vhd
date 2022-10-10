LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Request_Resolver IS
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

END Request_Resolver;

ARCHITECTURE RTL OF Request_Resolver IS

    COMPONENT Up_Priority_Resolver IS
        GENERIC (
            Floors_Count : INTEGER := 10;
            Floor_Bits_Count : INTEGER := 4
        );
        PORT (
            Buttons_Inside : IN unsigned (Floors_Count - 1 DOWNTO 0);
            Floor_In : IN unsigned (Floor_Bits_Count - 1 DOWNTO 0);
            Outside_Up_Buttons : IN unsigned (Floors_Count - 1 DOWNTO 0);
            Resolved_Floor : OUT unsigned (Floor_Bits_Count - 1 DOWNTO 0);
            Lower_Req_Valid : OUT STD_LOGIC;
            Upper_Req_Valid : OUT STD_LOGIC;
            No_Upper_Floor : OUT STD_LOGIC);

    END COMPONENT;

    COMPONENT Dn_Priority_Resolver IS
        GENERIC (
            Floors_Count : INTEGER := 10;
            Floor_Bits_Count : INTEGER := 4
        );
        PORT (
            Buttons_Inside : IN unsigned (Floors_Count - 1 DOWNTO 0);
            Floor_In : IN unsigned (Floor_Bits_Count - 1 DOWNTO 0);
            Outside_Dn_Buttons : IN unsigned (Floors_Count - 1 DOWNTO 0);
            Resolved_Floor : OUT unsigned (Floor_Bits_Count - 1 DOWNTO 0);
            Lower_Req_Valid : OUT STD_LOGIC;
            Upper_Req_Valid : OUT STD_LOGIC;
            No_Lower_Floor : OUT STD_LOGIC);

    END COMPONENT;

    SIGNAL Up_Resolved_Floor : unsigned (Floor_Bits_Count_cnfg - 1 DOWNTO 0);
    SIGNAL Dn_Resolved_Floor : unsigned (Floor_Bits_Count_cnfg - 1 DOWNTO 0);
    SIGNAL No_Lower_Floor : STD_LOGIC;
    SIGNAL No_Upper_Floor : STD_LOGIC;
    SIGNAL UP_Upper_Req_Valid : STD_LOGIC;
    SIGNAL UP_Lower_Req_Valid : STD_LOGIC;
    SIGNAL DN_Upper_Req_Valid : STD_LOGIC;
    SIGNAL DN_Lower_Req_Valid : STD_LOGIC;

    SIGNAL Elevator_CS : STD_LOGIC; -- Up (0) Or Down (1)

BEGIN
    -------------------------------------------------------------------------------------------------------
    --------------------------------- Dn_Priority_Resolver Instantiation ----------------------------------
    -------------------------------------------------------------------------------------------------------

    Dn_Priority_Resolver_Mod : Dn_Priority_Resolver
    GENERIC MAP(Floors_Count => Floors_Count_cnfg, Floor_Bits_Count => Floor_Bits_Count_cnfg)
    PORT MAP(Buttons_Inside, Floor_In, Outside_Dn_Buttons, Dn_Resolved_Floor, 
    DN_Lower_Req_Valid, DN_Upper_Req_Valid, No_Lower_Floor);

    -------------------------------------------------------------------------------------------------------
    --------------------------------- Up_Priority_Resolver Instantiation ----------------------------------
    -------------------------------------------------------------------------------------------------------

    Up_Priority_Resolver_Mod : Up_Priority_Resolver
    GENERIC MAP(Floors_Count => Floors_Count_cnfg, Floor_Bits_Count => Floor_Bits_Count_cnfg)
    PORT MAP(Buttons_Inside, Floor_In, Outside_Up_Buttons, Up_Resolved_Floor, 
    UP_Lower_Req_Valid, UP_Upper_Req_Valid, No_Upper_Floor);

    -------------------------------------------------------------------------------------------------------
    ---------------------------------------- Resolving Elevator_CS ----------------------------------------
    -------------------------------------------------------------------------------------------------------

    Elevator_CS_Process : PROCESS (clock, rst_n)
    BEGIN
        IF (rst_n = '0') THEN
            Elevator_CS <= '0'; --UP
        ELSIF (rising_edge(clock)) THEN
            IF ((UP = '1') OR ((DOOR_OPEN = '1') AND (No_Lower_Floor = '1'))) THEN
                Elevator_CS <= '0';
            ELSIF ((DN = '1') OR ((DOOR_OPEN = '1') AND (No_Upper_Floor = '1'))) THEN
                Elevator_CS <= '1';
            END IF;
        END IF;
    END PROCESS; -- Elevator_CS_Process

    -------------------------------------------------------------------------------------------------------
    ------------------------------------------- Req_Valid Logic -------------------------------------------
    -------------------------------------------------------------------------------------------------------

    Req_Valid_Process : PROCESS (Elevator_CS, UP_Upper_Req_Valid, DN_Lower_Req_Valid, No_Lower_Floor, 
    No_Upper_Floor, Dn_Resolved_Floor, Up_Resolved_Floor, UP_Lower_Req_Valid, DN_Upper_Req_Valid)
    BEGIN
        IF ((No_Upper_Floor = '1') AND (No_Lower_Floor = '1') AND (DN_Upper_Req_Valid = '1')) THEN
            Req_Valid <= '1';
            Resolved_Floor <= Dn_Resolved_Floor;

        ELSIF ((No_Upper_Floor = '1') AND (No_Lower_Floor = '1') AND (UP_Lower_Req_Valid = '1')) THEN
            Req_Valid <= '1';
            Resolved_Floor <= Up_Resolved_Floor;

        ELSIF (Elevator_CS = '0') THEN
            Req_Valid <= UP_Upper_Req_Valid;
            Resolved_Floor <= Up_Resolved_Floor;

        ELSE
            Req_Valid <= DN_Lower_Req_Valid;
            Resolved_Floor <= Dn_Resolved_Floor;
        END IF;
    END PROCESS; -- Req_Valid_Process

END RTL; -- RTL