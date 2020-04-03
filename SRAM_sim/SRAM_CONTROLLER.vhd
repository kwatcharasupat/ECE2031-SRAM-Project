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
		IO_WRITE		:	IN STD_LOGIC;						-- from SCOMP
		CTRL_WE			:	IN STD_LOGIC;						-- from IO_DECODER
		CTRL_OE			:	IN STD_LOGIC;						-- from IO_DECODER
		ADHI			:	IN STD_LOGIC_VECTOR(1 DOWNTO 0);	-- from IO_DECODER
		CLOCK			:	IN STD_LOGIC;						-- from external (could be SCOMP)
		
		IO_DATA			:	INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);	-- to/from SCOMP
		SRAM_ADDR		:	OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		SRAM_OE_N		:	OUT STD_LOGIC;
		SRAM_DQ			:	INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);	-- to/from SRAM hardware
		SRAM_WE_N		:	OUT STD_LOGIC; 						
		 						
		
		SRAM_UB_N		:	OUT STD_LOGIC;
		SRAM_LB_N		:	OUT STD_LOGIC;
		SRAM_CE_N		:	OUT STD_LOGIC
	);
END SRAM_CONTROLLER;

-- Declare SRAM_CONTROLLER architecture v0
ARCHITECTURE v0 OF SRAM_CONTROLLER IS
	TYPE STATE_TYPE IS (
		IDLE,
		WARM_UP,
		READ_PREP,	
		READ_DONE,
		WRITE_ADDR_PREP, 	-- placeholder for write states
		WRITE_WE_ASSERT,
		WRITE_WAIT,	        -- Wait for signal  
		WRITE_LOCK          -- Clean Up!
	);
	
	-- Declare internal signals
	SIGNAL STATE 		:	STATE_TYPE;						-- SRAM states
	SIGNAL ADDR		:	STD_LOGIC_VECTOR(17 DOWNTO 0);	-- Address
	SIGNAL DATA		:	STD_LOGIC_VECTOR(15 DOWNTO 0);	-- Data
	SIGNAL WE		:	STD_LOGIC;
	SIGNAL OE		:	STD_LOGIC;
	SIGNAL CE		:	STD_LOGIC;
	SIGNAL UB		:	STD_LOGIC;
	SIGNAL LB		:	STD_LOGIC;
	SIGNAL READ_ENABLE	:	STD_LOGIC;
	SIGNAL WRITE_ENABLE	:	STD_LOGIC;
	
BEGIN
	-- Mirror unused internal signals to ports
	CE			<= '1';
	UB			<= '1';
	LB			<= '1';
	SRAM_CE_N	<=	NOT CE;
	SRAM_UB_N	<= 	NOT UB;
	SRAM_LB_N	<=	NOT LB;
	
	-- Use LPM function to drive I/O bus
	-- This bus controls the flow of data from SRAM to SCOMP
	IO_BUS_READ: LPM_BUSTRI
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => SRAM_DQ,
		enabledt => READ_ENABLE, 
		tridata  => IO_DATA
	);
	
	-- This bus controls the flow of data from DATA to SRAM
	IO_BUS_WRITE: LPM_BUSTRI
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => DATA,
		enabledt => WRITE_ENABLE, -- if HIGH, enable data onto tridata
		tridata  => SRAM_DQ
	);
	
	PROCESS (CLOCK)
	BEGIN
		IF (RISING_EDGE(CLOCK)) THEN
			CASE STATE IS
				WHEN IDLE =>
					SRAM_OE_N <= '1';
					SRAM_WE_N <= '1';
					-- disable everything here
				
					READ_ENABLE <= '0';
					WRITE_ENABLE <= '0';
				
					IF (IO_WRITE = '1') THEN
						STATE <= WARM_UP;
					ELSE
						STATE <= IDLE;
					END IF;
					
				WHEN WARM_UP =>
					ADDR	<= 	ADHI & IO_DATA;	-- As IO_DATA only contains the address related stuff During WarmUp
					-- ADLO is contained in IO_DATA
					-- concat ADHI and IO_DATA to get 18-bit address.
				        
					-- ## Karn's comment ##
					-- I think this is redundant since WARM_UP is only reachable via IDLE
					--	and IDLE alr has these two lines
					READ_ENABLE <= '0';
					WRITE_ENABLE <= '0';		
					-- ##
					
					IF (CTRL_WE = '1')	THEN
						-- write cycle
						WE <= '1';
						-- ## Karn's edit ##
						OE <= '0';
						SRAM_OE_N <= '1';
						-- help make sure that we don't need to worry about additional timing requirement
						-- ##
						STATE <= WRITE_ADDR_PREP;
					ELSIF (CTRL_OE = '1' AND CTRL_WE = '0') THEN
						-- read cycle
						STATE <= READ_PREP;
					ELSE
						-- catch error
						STATE <= WARM_UP;
					END IF;
				
				WHEN READ_PREP =>
					SRAM_ADDR	<=	ADDR;
					SRAM_OE_N   <=  '0';
					SRAM_WE_N	<=  '1';
					
					READ_ENABLE <= '1';
					-- equiv: IO_DATA <= SRAM_DQ;  
				
					--Next State Logic Setup
					IF (CTRL_OE = '1' AND IO_WRITE = '0') THEN
						STATE <= READ_DONE;
					ELSE 
						STATE <= READ_PREP;
					END IF;
						
				WHEN READ_DONE =>
					-- Wait until SCOMP has finished reading before going high-Z
					IF (CTRL_OE = '0' AND IO_WRITE = '0') THEN
						SRAM_OE_N   <= '1';
						READ_ENABLE <= '0';
						STATE <= IDLE;
					ELSE 
						STATE <= READ_DONE;
					END IF;
					
				WHEN WRITE_ADDR_PREP =>
					-- output address to hardware
					SRAM_ADDR	<=	ADDR;
                   	STATE <= WRITE_WE_ASSERT;
			    
				WHEN WRITE_WE_ASSERT =>
				    -- enable write on the hardware
				    SRAM_WE_N <= '0';
				    STATE <= WRITE_WAIT;
				
				WHEN WRITE_WAIT =>
					DATA <= IO_DATA; -- let data from SCOMP goes into internal ctrl latch

					WRITE_ENABLE <= '1';
					-- then write that data to the hardware
				
					IF (CTRL_OE = '1') THEN
						-- lock the data before SCOMP stops writing
						WE <= '0';
						SRAM_WE_N <= '1';
						STATE <= WRITE_LOCK;
				    ELSE
						STATE <= WRITE_WAIT;
				    END IF;
						
				WHEN WRITE_LOCK =>
					WRITE_ENABLE <= '0';
					-- just for safety (doesn't actually matter)
					
					-- wait until SCOMP is done with OUT cycle before going IDLE
					IF (IO_WRITE = '0' AND CTRL_OE = '0') THEN
						STATE <= IDLE;
					ELSE
						STATE <= WRITE_LOCK;
					END IF;
				
				WHEN OTHERS =>
					STATE <= IDLE;
					
			END CASE;
		END IF;
	END PROCESS;

END v0;
