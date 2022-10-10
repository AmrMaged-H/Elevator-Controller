--------------------------------------------------------------------------------------------------------------------------------
-- Module Name : Up_Priority_Resolver

-- Functionality :

-- The Module is responsible for resolving the different up requests and the inner requests as well, 
-- where when moving up we need to find the LEAST up request following the current floor in order
-- to go up to this floor.
-- And, it finds the LEAST up request BELOW the current floor as well in order to handle the corner case
-- in which there is no up requests above the current floor and no down requests below the current floor

-- For Example --> if we are on the 5th floor and the only requests are up ones on the 3rd and 2nd floors
-- So, we need to go to the 2nd floor (LEAST) Then 3rd.

-- The No_Upper_Floor Flag Indicates that there is no internal request or up request for a floor higher than the current floor.

--------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Up_Priority_Resolver IS
    GENERIC (
        Floors_Count        : INTEGER := 10;
        Floor_Bits_Count    : INTEGER := 4
    );
    PORT (
        Buttons_Inside :        IN unsigned (Floors_Count - 1 DOWNTO 0);
        Floor_In :              IN unsigned (Floor_Bits_Count - 1 DOWNTO 0);
        Outside_Up_Buttons :    IN unsigned (Floors_Count - 1 DOWNTO 0);
        Resolved_Floor :        OUT unsigned (Floor_Bits_Count - 1 DOWNTO 0);
        Lower_Req_Valid :       OUT STD_LOGIC;
        Upper_Req_Valid :       OUT STD_LOGIC;
        No_Upper_Floor :        OUT STD_LOGIC);

END Up_Priority_Resolver;

ARCHITECTURE behav OF Up_Priority_Resolver IS

    SIGNAL All_Requests :           unsigned (Floors_Count - 1 DOWNTO 0);
    SIGNAL Least_Up_BelowFloor :    unsigned (Floor_Bits_Count - 1 DOWNTO 0);
    SIGNAL Least_Up_AboveFloor :    unsigned (Floor_Bits_Count - 1 DOWNTO 0);
    SIGNAL No_Upper_Floor_c :       STD_LOGIC;

BEGIN

    All_Requests <= Buttons_Inside OR Outside_Up_Buttons;

    Resolved_Floor_Process : PROCESS (No_Upper_Floor_c, Least_Up_AboveFloor, Least_Up_BelowFloor)
    BEGIN

        IF (No_Upper_Floor_c = '0') THEN
            Resolved_Floor <= Least_Up_AboveFloor;
        ELSE
            Resolved_Floor <= Least_Up_BelowFloor;
        END IF;

    END PROCESS; -- Resolved_Floor_Process

    PROCESS (All_Requests, Floor_In, Outside_Up_Buttons)

    BEGIN

        Least_Up_AboveFloor <= "0000";
        Least_Up_BelowFloor <= "0000";
        Lower_Req_Valid     <= '0';
        Upper_Req_Valid     <= '0';

        FOR N IN Floors_Count - 1 DOWNTO 0 LOOP

            IF ((All_Requests(N) = '1') AND (Floor_In <= to_unsigned(N, Floor_Bits_Count))) THEN
                Least_Up_AboveFloor <= To_Unsigned(N, Floor_Bits_Count);
                Upper_Req_Valid     <= '1';
            ELSIF ((Outside_Up_Buttons(N) = '1') AND (Floor_In > to_unsigned(N, Floor_Bits_Count))) THEN
                Least_Up_BelowFloor <= To_Unsigned(N, Floor_Bits_Count);
                Lower_Req_Valid     <= '1';
            END IF;

        END LOOP;

    END PROCESS;

    No_Upper_Floor_Process : PROCESS (Least_Up_AboveFloor, Floor_In)
    BEGIN

        IF (Least_Up_AboveFloor < Floor_In) THEN
            No_Upper_Floor_c <= '1';
        ELSE
            No_Upper_Floor_c <= '0';
        END IF;

    END PROCESS; -- No_Upper_Floor_Process

    No_Upper_Floor <= No_Upper_Floor_c;

END behav;