#include <stdint.h>

#define RESET_VECTOR 0x3fffU

#define MAX_BREAKPOINTS 1024    /* maximum number of breakpoints you can have 
                                   at one time */

#define MEMORY_SIZE     16384   /* number of *words* in the memory space of the
                                   vm */

struct 
vm_state
{
    uint32_t acc;               /* accumulator + carry bit -- the accumulator
                                 is only 16 bits wide, but we use the bit above
                                 the MSB of the accumulator to be the carry 
                                 flag, that makes things easier*/

    uint16_t pc;                /* program counter, this is 14 bits wide */
    uint16_t memory[MEMORY_SIZE];     /* memory for the cpu, 2^14 elements, each 
                                   2 bytes wide */

    uint32_t cycles;            /* cycles elapsed since start */
    
    uint16_t breakpoints[MAX_BREAKPOINTS]; /* array of addresses at which we 
                                              stop execution */

};


