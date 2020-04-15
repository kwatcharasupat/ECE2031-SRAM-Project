# ECE2031 SRAM Project
Georgia Institute of Technology

Spring 2020

## The Team:
  - Felicia E
  - Jacques M Crawford
  - Karn Watcharasupat
  - Segev Apter
  - Siddhanta Panda

# Upcoming Meeting
- [x] Meeting 1: 10 Mar 2020, 1815 to 1945 EDT 
  - [x] Consensus Form [Felicia]
- [x] Meeting 2: 11 Mar 2020, 1630 to 1800 EDT 
  - [x] Consensus Form [Felicia]
- [x] Meeting 3: 17 Mar 2020, 1800 to 2030 EDT
  - [x] Consensus Form [Karn]
- [x] Meeting 4: 1 Apr 2020, 2200 to 2330 EDT
  - [x] Consensus Form [Segev]
- [x] Meeting 5: 7 Apr 2020, 2200 to 8 Apr 0000 EDT
  - [x] Consensus Form [Felicia]
- [x] Meeting 6: 9 Apr 0030 to 0300 EDT
  - [x] Consensus Form [Felicia]
- [ ] Meeting 7:
  - [ ] Consensus Form
- [ ] Meeting 8: 
  - [ ] Consensus Form

To-do Format: [x] [task] [in-charge] 
# Week 1 (09 Mar to 15 Mar)
- [x] Week 1 Exercise 
- [x] Consensus form #1.1 & #1.2 [Felicia]
- [x] SRAM skeleton VHDL [Karn]
- [x] SRAM read VHDL and UML [Siddhant & Jacques]
- [x] IO Decoder VHDL [Felicia & Segev]

# Spring Break Week 1 (16 Mar to 22 Mar)
- [ ] Sleep 8 hours a day
- [x] Write cycle UML [Felicia & Jacques]
- [x] SRAM write VHDL [Siddhanta & Segev]
- [x] IO_DECODER write VHDL [Karn]

# Spring 'Break' Week 2 (23 Mar 29 Mar)

# Week 2 (30 Mar to 05 Apr)
- [x] Proposal slides [Everyone]
    - Introduction (2 min/2 min)
        - Problem statement [Felicia]
        - Requirements [Felicia]
    - Technical Approach
        - Assembly and User Interaction [Felicia & Karn] (2 min/4 min)
        - Read Cycle [Siddhanta & Jacques] (2 min/6 min)
        - Write Cycle [Siddhanta & Segev] (2 min/8 min)
    - Project Timeline (2 min/10 min)
        - Current progress
        - Future work (Gaant Chart?)
        - Contingency plan 
- [x] Minor fix to UML [Felicia]
- [x] Assembly code for verification of read/write cycle [x]

# Week 3 (06 Apr to 12 Apr)
- [x] User error case management 
    - [x] (R) calls IN R?? before OUT R??
        - SRAM interface remains in IDLE
    - [x] (R) calls two OUT R?? consecutively
        - SRAM interface remains in READ_PREP until IN is called. SRAM will ignore all OUT R?? after the first one.
    - [x] (R) calls OUT Rxy then IN Rzw : 
        - SRAM takes data from xy & ADLO. ADHI code does not matter for IN
    - [x] (R) calls OUT WA?? instead of OUT R?? then calls IN R??
        - SRAM write -1 to IO_DATA then returns to IDLE
        - The memory at that addresss is also corrupted to -1
    - [x] (W) calls OUT WD?? before OUT WA??
        - SRAM treats WD as if it is a WA
        - SRAM data will take the value of ADLO during OUT WA but will be stuck in WRITE_WAIT until WD is called again
    - [x] (W) calls two OUT WA?? consecutively
        - The second OUT WA?? is ignored. SRAM stays in WRITE_WAIT until WD is called
    - [x] (W) calls OUT R?? instead of OUT WA?? then calls OUT WD??
        - SRAM stuck in READ_PREP until IN R is called
    - [x] (W) calls IN WD?? instead of OUT WD??
        - SRAM continues to WRITE_LOCK without actually writing the data
        - The memory at that addresss is also corrupted to -1

# Week 4 (13 Apr to 19 Apr)
  - [ ] Demo slides
  
  - SLOW_SRAM (unclocked), SCOMP 50 MHz
    - WRITE: 28 SCOMP clock cycles.
    - READ: 25 SCOMP clock cycles.
  
  - New SRAM 50/100 MHz, SCOMP 50 MHz
    - WRITE: 14 SCOMP clock cycles. 8 cycles for IO instructions. [50% reduction in # of clock cycles cf. SLOW_SRAM]
    - READ: 12 SCOMP clock cycles. 8 cycles for IO instructions. [52% reduction in # of clock cycles]
  
  
# Demo (21 Apr)
  - [ ] Pray to George P Burdell and hope Buzz still loves us remotely
