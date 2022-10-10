--------------------------------------------------------------------------------------------------------------------------------
-- Module Name : Dn_Priority_Resolver

-- Functionality :

-- The Module is responsible for resolving the different down requests and the inner requests as well, 
-- where when moving down we need to find the Highest down request below the current floor in order
-- to go down to this floor.
-- And, it finds the Highest down request ABOVE the current floor as well in order to handle the corner case
-- in which there is no down requests below the current floor and no up requests above the current floor

-- For Example --> if we are on the 5th floor and the only requests are down ones on the 7th and 9th floors
-- So, we need to go to the 9th floor (Highest) Then 7th.

-- The No_Lower_Floor Flag Indicates that there is no internal request or down request for a floor below the current floor.

--------------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Dn_Priority_Resolver IS
    GENERIC (
        Floors_Count :      INTEGER := 10;
        Floor_Bits_Count :  INTEGER := 4
    );
    PORT (
        Buttons_Inside :        IN unsigned (Floors_Count - 1 DOWNTO 0);
        Floor_In :              IN unsigned (Floor_Bits_Count - 1 DOWNTO 0);
        Outside_Dn_Buttons :    IN unsigned (Floors_Count - 1 DOWNTO 0);
        Resolved_Floor :        OUT unsigned (Floor_Bits_Count - 1 DOWNTO 0);
        Lower_Req_Valid :       OUT STD_LOGIC;
        Upper_Req_Valid :       OUT STD_LOGIC;
        No_Lower_Floor :        OUT STD_LOGIC);

END Dn_Priority_Resolver;

ARCHITECTURE behav OF Dn_Priority_Resolver IS

    SIGNAL All_Requests :               unsigned (Floors_Count - 1 DOWNTO 0);
    SIGNAL Highest_Dn_BelowFloor :      unsigned (Floor_Bits_Count - 1 DOWNTO 0);
    SIGNAL Highest_Dn_AboveFloor :      unsigned (Floor_Bits_Count - 1 DOWNTO 0);
    SIGNAL No_Lower_Floor_c :           STD_LOGIC;

BEGIN
    All_Requests <= Buttons_Inside OR Outside_Dn_Buttons;

    Resolved_Floor_Process : PROCESS (No_Lower_Floor_c, Highest_Dn_BelowFloor, Highest_Dn_AboveFloor)
    BEGIN
        IF (No_Lower_Floor_c = '0') THEN
            Resolved_Floor <= Highest_Dn_BelowFloor;
        ELSE
            Resolved_Floor <= Highest_Dn_AboveFloor;
        END IF;
    END PROCESS; -- Resolved_Floor_Process

    PROCESS (All_Requests, Floor_In, Outside_Dn_Buttons)

    BEGIN

        Highest_Dn_BelowFloor   <= "1111";
        Highest_Dn_AboveFloor   <= "1111";
        Lower_Req_Valid         <= '0';
        Upper_Req_Valid         <= '0';

        FOR N IN 0 TO Floors_Count - 1 LOOP

            IF ((All_Requests(N) = '1') AND (Floor_In >= to_unsigned(N, Floor_Bits_Count))) THEN
                Highest_Dn_BelowFloor   <= To_Unsigned(N, Floor_Bits_Count);
                Lower_Req_Valid         <= '1';
            ELSIF ((Outside_Dn_Buttons(N) = '1') AND (Floor_In < to_unsigned(N, Floor_Bits_Count))) THEN
                Highest_Dn_AboveFloor   <= To_Unsigned(N, Floor_Bits_Count);
                Upper_Req_Valid         <= '1';
            END IF;

        END LOOP;

    END PROCESS;

    No_Lower_Floor_Process : PROCESS (Highest_Dn_BelowFloor, Floor_In)
    BEGIN
        IF (Highest_Dn_BelowFloor > Floor_In) THEN
            No_Lower_Floor_c <= '1';
        ELSE
            No_Lower_Floor_c <= '0';
        END IF;
    END PROCESS; -- No_Lower_Floor_Process

    No_Lower_Floor <= No_Lower_Floor_c;
END behav;