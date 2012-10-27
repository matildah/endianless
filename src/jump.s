ZERO        DB  0000 ; all bits zero
ONES        DB  FFFF ; all bits one
ONE         DB  0001 ; one!
JNCINST     DB  4000 ; opcode for JNC
JNCINSTPLUS DB  4001 ; opcode for JNC plus one
hell        DB  3fff ; the address that halts execution when we jump to 
dest        DB  0000 
fdest       DB  0000 ; dest + 1 + 0x4000 -- we can do this fixup at assembly-time






jump:           ; jumps to the address stored at dest
NAND ZERO       ; acc = 0xffff
ADD JNCINSTPLUS ; acc = 0x4000, carry flag is set
ADD dest        ; acc is now the correct jump instruction 
ST jinst2       ; ...which is now stored where we'll execute it
JNC hell        ; won't jump, carry flag is set, but this UNSETS it
jinst2:
JNC hell        ; will get fixed up, don't worry. 


fjump:     ; takes fake "addresses" -- the jump opcode 0x4000 plus the 
           ; destination plus one (so when added to 0xffff, it creates the
           ; correct jump instruction)
           ; 
           ; When addresses are known at compile time, this allows to save one
           ; instruction


NAND ZERO  ; acc = 0xffff
ADD fdest  ; acc = fdest - 1 = 0x4000 + destination. carry flag gets set
ST jinst3  ; stores acc, so we can execute it
JNC hell   ; does not jump. unsets carry flag
jinst3:
JNC hell   ; acc gets stored here and gets executed





jump3: ;jumps to the address held in the word at dest. more efficient version 
       ; exists in the "jump" routine
NAND ZERO ; acc = 0xffff
ADD ONE ; acc = 0x0000 *and* carry flag IS SET
JNC hell; will not jump because carry flag is set, but UNSETS carry flag
ADD JNCINST
ADD dest
ST jinst
jinst: ; the actual jump opcode is here
JNC dest
