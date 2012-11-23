; memcpy -- copies n words from src to dest

;constants

ZERO     DB  0000 ; all bits zero
ONES     DB  FFFF ; all bits one
ONE      DB  0001 ; one
ADDINST  DB  4000 ; opcode for ADD
NANDINST DB  0000 ; opcode for NAND


;arguments




; memcpy is basically:
; for (int i = 0; i < n ; i++)
;   *(dst + i) = *(src + i)
;



src      DB  1234 ;
dest     DB  5678 ;
n        DB  0010 ;


nprime   DB  0000 
memcpy:

NAND ZERO ; acc = 0xffff
NAND n ; acc = acc ^ 0xffff
ADD ONE ; acc = n ^ 0xffff + 1 = -n 
ST nprime ; stores -n in nprime





copy: 
NAND ZERO
NAND ONES

load:
ADD src

store:
ST dest


increment:
NAND ZERO
NAND ONES
ADD load
ADD ONE
ST load
NAND ZERO
NAND ONES
ADD store
ADD ONE
ST store




