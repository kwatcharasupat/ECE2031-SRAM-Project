LIBRARY IEEE;
LIBRARY ALTERA_MF;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY SRAM IS
	PORT (
		IO_WRITE		:	IN STD_LOGIC;
		CTRL_WE			:	IN STD_LOGIC;
		CTRL_OE			:	IN STD_LOGIC;
		ADHI			:	IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		CLOCK			:	IN STD_LOGIC;
		
		SRAM_CE_N		:	OUT STD_LOGIC;
		SRAM_WE_N		:	OUT STD_LOGIC;
		SRAM_OE_N		:	OUT STD_LOGIC;
		SRAM_UB_N		:	OUT STD_LOGIC;
		SRAM_LB_N		:	OUT STD_LOGIC;
		SRAM_ADLO		:	OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		SRAM_ADHI		:	OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		SRAM_DQ			:	INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		IO_DATA			:	INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END SRAM;

-- Declare SRAM architecture v0
ARCHITECTURE v0 OF SRAM IS
	TYPE STATE_TYPE IS (
		IDLE,
		FETCH,
		READ_PREP,	
		READ_DONE,
		WRITE_INIT 	-- placeholder for write states
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
        SIGNAL READ_SIG         :       STD_LOGIC_VECTOR(2 DOWNTO 0);  -- READ SIGNAL FOR SRAM
	
BEGIN
	-- Mirror unused internal signals to ports
	CE			<= '1';
	UB			<= '1';
	LB			<= '1';
	SRAM_CE_N	<=	NOT CE;
	SRAM_UB_N	<= 	NOT	UB;
	SRAM_LB_N	<=	NOT LB;
	
	SRAM_ADHI	<=	ADDR(17 DOWNTO 16);
	SRAM_ADLO	<=	ADDR(15 DOWNTO 0);
	

        --Concatenated Signals for Read Operation of SRAM
        READ_SIG        <=      CTRL_OE & ADHI; 
        
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
					
				WHEN FETCH =>
					ADDR	<= 	ADHI & IO_DATA;	
					-- ADLO is contained in IO_DATA
					-- concat ADHI and IO_DATA to get 18-bit address
					WE		<= CTRL_WE;	-- get WE from CTRL
					OE		<= CTRL_OE;	-- get OE from CTRL
					
					IF (WE = '1')	THEN
						STATE <= WRITE_INIT;
					ELSIF (OE = '1') THEN
						STATE <= READ_PREP;
					ELSE
						STATE <= IDLE;
					END IF;
				
				WHEN READ_PREP => -- Hold State until READ_SIG goes down to 0 else move to read_done on Rising edge of CLOCK
					
					IF(READ_SIG = "000") THEN
					   STATE <= READ_DONE;
				        ELSE 
					    STATE <= READ_PREP;
				        END IF;
					
				WHEN WRITE_INIT =>
					-- DO SOMETHING
					
					STATE <= IDLE; -- REMOVE THIS LINE!!!
				
				
				WHEN READ_DONE => 
				        STATE <= IDLE;
					
				WHEN OTHERS =>
					STATE <= IDLE;
					
			END CASE;
		END IF;
	END PROCESS;

END v0;
	
