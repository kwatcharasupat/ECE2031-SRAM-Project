LIBRARY IEEE;
LIBRARY ALTERA_MF;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY SRAM_CONTROLLER IS
	PORT (
		IO_WRITE		:	IN STD_LOGIC;
		CTRL_WE			:	IN STD_LOGIC;
		CTRL_OE			:	IN STD_LOGIC;
		ADHI			:	IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		CLOCK			:	IN STD_LOGIC;
		
		SRAM_CE_N		:	OUT STD_LOGIC;
		SRAM_WE_N		:	OUT STD_LOGIC; --WE USE THIS
		SRAM_OE_N		:	OUT STD_LOGIC; -- WE USE THIS
		SRAM_UB_N		:	OUT STD_LOGIC;
		SRAM_LB_N		:	OUT STD_LOGIC;
		SRAM_ADLO		:	OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- WE USE THIS
		SRAM_ADHI		:	OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- WE USE THIS
		
		SRAM_DQ			:	INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		IO_DATA			:	INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END SRAM_CONTROLLER;

-- Declare SRAM_CONTROLLER architecture v0
ARCHITECTURE v0 OF SRAM_CONTROLLER IS
	TYPE STATE_TYPE IS (
		IDLE,
		WARM_UP,
		READ_PREP,	
		READ_DONE,
		WRITE_PREP, 	-- placeholder for write states
		WRITE_DONE
	);
	
	-- Declare internal signals
	SIGNAL STATE 	:	STATE_TYPE;						-- SRAM states
	SIGNAL ADDR		:	STD_LOGIC_VECTOR(17 DOWNTO 0);	-- Address
	SIGNAL DATA		:	STD_LOGIC_VECTOR(15 DOWNTO 0);	-- Data
	SIGNAL WE		:	STD_LOGIC;
	SIGNAL OE		:	STD_LOGIC;
	SIGNAL CE		:	STD_LOGIC;
	SIGNAL UB		:	STD_LOGIC;
	SIGNAL LB		:	STD_LOGIC;
    SIGNAL READ_SIG :   STD_LOGIC_VECTOR(2 DOWNTO 0);  -- READ SIGNAL FOR SRAM 
	
BEGIN
	-- Mirror unused internal signals to ports
	CE			<= '1';
	UB			<= '1';
	LB			<= '1';
	SRAM_CE_N	<=	NOT CE;
	SRAM_UB_N	<= 	NOT UB;
	SRAM_LB_N	<=	NOT LB;
	
	-- Use LPM function to drive I/O bus
	IO_BUS: LPM_BUSTRI
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => SRAM_DQ,
		enabledt => OE, -- if HIGH, enable data onto tridata (READ cycle)
		enabletr =>WE,	-- if HIGH, enable tridata onto data (WRITE cycle)
		tridata  => IO_DATA
	);
	
    --Concatenated Signals for Read Operation of SRAM
    READ_SIG	<=	CTRL_OE & ADHI; 
        
	PROCESS (CLOCK)
	BEGIN
		IF (RISING_EDGE(CLOCK)) THEN
			CASE STATE IS
				WHEN IDLE =>
					IF (IO_WRITE = '1') THEN
						STATE <= FETCH;
					ELSE
						STATE <= IDLE;
					END IF;
					
				WHEN WARM_UP =>
					ADDR	<= 	ADHI & IO_DATA;	-- As IO_DATA only contains the address related stuff During WarmUp
					SRAM_ADHI	<=	ADDR(17 DOWNTO 16);
					SRAM_ADLO	<=	ADDR(15 DOWNTO 0); -- Have the Address Fired
				        -- ADLO is contained in IO_DATA
					-- concat ADHI and IO_DATA to get 18-bit address
					
					IF (CTRL_WE = '1')	THEN
						STATE <= WRITE_PREP;
					ELSIF (CTRL_OE = '1' AND CTRL_WE = '0' AND ADHI = "01") THEN
						STATE <= READ_PREP;
					ELSE
						STATE <= IDLE;
					END IF;
				
				WHEN READ_PREP =>
					--Current State Handling...
					SRAM_ADHI	<=	ADDR(17 DOWNTO 16);
					SRAM_ADLO	<=	ADDR(15 DOWNTO 0); -- Keep the Address Fired
					SRAM_OE         <=      '0';
					SRAM_WE         <=      '1';
					SRAM_DQ         <=      IO_DATA;  --That's for the SCOMP To get connected to the GPIO that goes to the SRAM.
					--Next State Logic Set Up!
					IF (CTRL_OE = '0') THEN
						STATE <= READ_DONE;
					ELSE 
						STATE <= READ_PREP;
					
				WHEN WRITE_PREP =>
					--Current State Handling...
					SRAM_ADHI	<=	ADDR(17 DOWNTO 16);
					SRAM_ADLO	<=	ADDR(15 DOWNTO 0); -- Keep the Address Fired
					SRAM_OE         <=      '1';
					SRAM_WE         <=      '0';
					SRAM_DQ         <=      IO_DATA;  --That's for the SCOMP To get connected to the GPIO that goes to the SRAM.
	                                --Next State Logic Set Up!
					IF (CTRL_WE = '0') THEN
						STATE <= WRITE_DONE;
					ELSE 
						STATE <= WRITE_PREP;

				WHEN READ_DONE => 
		                        SRAM_OE <= '1';
				        STATE <= IDLE;

				WHEN WRITE_DONE =>
					SRAM_WE <= '1';
					STATE <= IDLE;
					
				WHEN OTHERS =>
					STATE <= IDLE;
					
			END CASE;
		END IF;
	END PROCESS;

END v0;
	
