; for loops 

ZERO     DB  0000 ; all bits zero
ONES     DB  FFFF ; all bits one
ONE      DB  0001 ; one
TWO      DB  0002 ; two
ADDINST  DB  4000 ; opcode for ADD
NANDINST DB  0000 ; opcode for NAND

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



; 0 to n

i       DB 0000
n       DB 0000
nprime  DB 0000 

; if n = 0x0003, we want to have an overflow when we add 0x0003 + nprime. 
; therefore nprime = 0x10000-0x0003 = 0xfffd = -n 

init:       ; can be skipped if n is known at assmebly time. if i had an optimizing 
            ; assembler this would be optimized away 

NAND ZERO   ; acc = 0xffff
NAND n      ; acc = n ^ 0xffff
ADD  ONE    ; acc = n ^ 0xffff + 1 = -n 
ST   nprime ; stores -n in nprime

; ^ can be optimized away if we know n at assembly time

init2:      ; entry point if nprime is already set 
            ; all we need to do is zero acc, set i = 0 and unset the carry flag
            ; so the first time we run the test we go into the loop.

NAND ZERO   ; acc = 0xffff
ADD  ONE    ; acc = 0x0000, carry set
JNC  hell   ; carry is set, so we don't jump. this unsets the carry though.
ST   i      ; store zero in i


            ; loop test -- we need acc = i and carry not set for the test
ADD  nprime ; acc = i + ( -n ) = i - n 

JNC  loop   ; jumps to the loop body if there's no carry. if there is a carry,
            ; it unsets carry, and we go to the next instruction

JNC  exit   ; we had a carry from the ADD, so now we need an exit

loop:
; 
; [loop body]
;

; increment i 
NAND ZERO   ; acc = 0xffff
ADD TWO     ; acc = 0x0001
ADD i       ; acc = i + 1
ST i        ; i   = i + 1

JNC test    ; unconditional jump back to test 
JNC test    ; ^

exit:






