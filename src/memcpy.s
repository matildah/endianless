; memcpy -- copies n words from src to dest

; memcpy is basically:
; for (int i = 0; i < n ; i++)
;   *(dst + i) = *(src + i)
;

;constants

ZERO     DB  0000 ; all bits zero
ONES     DB  FFFF ; all bits one
ONE      DB  0001 ; one
ADDINST  DB  4000 ; opcode for ADD
NANDINST DB  0000 ; opcode for NAND


; arguments


src      DB  1234 ;
dest     DB  5678 ;
n        DB  0010 ;



; local variables
nprime   DB  0000 




memcpy:

NAND ZERO ; acc = 0xffff
NAND n ; acc = acc ^ 0xffff
ADD ONE ; acc = n ^ 0xffff + 1 = -n 
ST nprime ; stores -n in nprime





copy: 
NAND ZERO ; acc = 0xffff
NAND ONES ; acc = 0x0000

load:
ADD src   ; acc = *src

store:
ST dest   ; *dest = *src


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




