# ECE2031 SRAM Project
Spring 2020

# Upcoming Meeting
- [x] Meeting 1: 10 Mar 2020, 1815 to 1945 EDT 
  - [x] Consensus Form [Felicia]
- [x] Meeting 2: 11 Mar 2020, 1630 to 1800 EDT 
  - [x] Consensus Form [Felicia]
- [x] Meeting 3: 17 Mar 2020, 1800 to 2030 EDT
  - [x] Consensus Form [Karn]
- [x] Meeting 4: 1 Apr 2020, 2200 to 2330 EDT
  - [x] Consensus Form [Segev]
- [ ] Meeting 5: 
  - [ ] Consensus Form
- [ ] Meeting 6: 
  - [ ] Consensus Form
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
- [ ] Proposal slides [Everyone]
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
- [ ] Minor fix to UML [Felicia]
- [x] Assembly code for verification of read/write cycle [x]

# Week 3 (06 Apr to 12 Apr)
- [ ] User error case management 
    - [x] (R) calls IN R?? before OUT R?? : SRAM interface remains in IDLE
    - [x] (R) calls two OUT R?? consecutively : SRAM interface remains in READ_PREP until IN is called. SRAM will ignore all OUT R?? after the first one.
    - [ ] (R) calls OUT Rxy then IN Rzw : 
    - [ ] (R) calls OUT WA?? instead of OUT R?? then calls IN R??
    - [ ] (W) calls IN WD?? before OUT WA??
    - [ ] (W) calls two OUT WA?? consecutively
    - [ ] (W) calls OUT R?? instead of OUT WA?? then calls IN WD??
    - [ ] (W) calls IN WA?? instead of IN WD??

# Week 4 (13 Apr to 19 Apr)

# Demo
