ZERO    DB  0000 ; all bits zero
ONES    DB  FFFF ; all bits one
ONE     DB  0001 ; one!
JNCINST DB  4000 ; opcode for JNC

dest    DB  0000 

jump: ;jumps to the address held in the double byte at dest
NAND ZERO ; acc = 0xffff
ADD ONE ; acc = 0x0000 *and* carry flag IS SET
JNC nowhere ; will not jump because carry flag is set, but UNSETS carry flag

ADD JNCINST
ADD dest

ST jinst

jinst: ; the actual jump opcode is here
JNC dest






