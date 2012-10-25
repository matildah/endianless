ZERO    DB  0000 ; all bits zero
ONES    DB  FFFF ; all bits one
ONE     DB  0001 ; one!
JNCINST DB  4000 ; opcode for JNC
hell    DB  3fff ; the address that halts execution when we jump to 
dest    DB  0000 
fdest   DB  0000 ; dest + 1 + 0x4000 -- we can do this fixup at assembly-time

jump: ;jumps to the address held in the double byte at dest
NAND ZERO ; acc = 0xffff
ADD ONE ; acc = 0x0000 *and* carry flag IS SET
JNC hell; will not jump because carry flag is set, but UNSETS carry flag
ADD JNCINST
ADD dest
ST jinst
jinst: ; the actual jump opcode is here
JNC dest

JNCINSTPLUS DB 4001 ; opcode for JNC plus one

jump2:   ; does the same, but with one less instruction
NAND ZERO ; acc = 0xffff
ADD JNCINSTPLUS ; acc = 0x4000, carry flag is set
ADD dest 
JNC hell ; won't jump, carry flag is set, but this UNSETS it
ST jinst2
jinst2:
JNC hell ; will get fixed up, don't worry. 


jump3:  ; takes fixed up "addresses" (actually pre-assembled jump instructions)

NAND ZERO
ADD dest
JNC hell
ST jinst3
jinst3:
JNC hell

