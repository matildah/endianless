; memcpy -- copies n words from src to dest

;constants

ZERO     DB  0000 ; all bits zero
ONES     DB  FFFF ; all bits one
ONE      DB  0001 ; one
ADDINST  DB  4000 ; opcode for ADD
NANDINST DB  0000 ; opcode for NAND


;arguments

src      DB  1234 ;
dest     DB  5678 ;
n        DB  0010 ;


nprime   DB  0000 ; variable we iterate over. basically, instead of going from
                 ; zero to n, we go from 2^16-n to zero, and that allows us to 
                 ; use the carry flag (which gets set only when we increment
                 ; 2^16 - 1) to detect when we ned to exit the loop.

; memcpy is basically:
; for (int i = 0; i < n ; i++)
;   *(dst + i) = *(src + i)
;



memcpy:

NAND ZERO
NAND n
ST nprime





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




