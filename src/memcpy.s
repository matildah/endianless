; memcpy -- copies n words from src to dest
; oh, and also this is where I try to figure out how to implement a for loop 
; with the fewest instructions :-P

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


nprime   DB  0000 

; memcpy is basically:
; for (int i = 0; i < n ; i++)
;   *(dst + i) = *(src + i)
;



; How we implement "for (int i = 0; i < b; i++) {X(i)}" loops in endianless:

; the only kind of jump we have in endianless is jump-if-carry-not-set, and we
; can combine that with the increment needed in the for loop. We have two 
; outcomes -- do the loop or exit the loop, and that maps onto carry not set / 
; carry set. The reason we do it this way rather than the other way around is 
; that we can set things up such that the loop counter increments from 0xffff
; on the exit-the-loop case and sets a carry, and the normal case does not set
; a carry. Namely, you can't increment something, and have it generate a 
; carry, and increment it again, and have it generate a carry again. 
; 
; We have the additional requirement that we be able to have the current value 
; of i (not i prime) inside a variable (it's needed to do relative addressing)
; 
; Given anything inside acc, we can increment i with NAND ZERO, ADD 0x0002,
; ADD i, ST i. however, if we have something which is related to i with a 
; known offset, we can do this with less instructions:
; ADD [the right constant], ST i.
; 
; We have a choice though -- how do we order the increment, the test, and the
; loop body? 
; 
; Also, we have basically two choices for how to move the loop index -- from
; zero to b or from 0xffff - b to zero. 
; 
; 0 to b
; i DB 0000 
; bprime  DB 0000 

; if b = 0x2, we want to have an overflow at i = 0x2 => i -1  = 0x1. so we need 
; a bprime value of 0xffff. b = 0x3 => bprime = 0xfffe,



; entry:
; 
; test: 
; NAND ZERO
; ADD i ; acc = i - 1 
; ADD bprime ; acc = i - 1 + bprime
; 
; 
; 
; 
; [loop body]
; 
; JNC test
; JNC test
;




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




