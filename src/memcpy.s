; memcpy -- copies n words from src to dest

ZERO    DB  0000 ; all bits zero
ONES    DB  FFFF ; all bits one

src     DB  1234 ;
dest    DB  5678 ;
n       DB  0010 ;

; memcpy is basically:
; for (int i = 0; i < n ; i++)
;   *(dst + i) = *(src + i)
;



memcpy:

NAND ZERO
NAND ONES






