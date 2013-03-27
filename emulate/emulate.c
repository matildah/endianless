#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "emulate.h"

int main(int argc, char **argv)
{
    
    FILE *in, *out;
    struct vm_state *st;
    int runcycles;
    if (argc != 4)
    {
        fprintf(stderr, "usage: %s input output cycles \n", argv[0]);
        exit(1);
    }

    in = fopen(argv[1], "r");
    out = fopen(argv[2], "w");    

    if (in == NULL)
    {
        perror("opening input file");
        exit(1);
    }
    if (out == NULL)
    {
        perror("opening output file");
        exit(1);
    }
    runcycles = atoi(argv[3]);



}

struct vm_state * initialize_vm()
{
    struct vm_state *newvm;
    int i;

    newvm = (struct vm_state *)malloc(sizeof(struct vm_state));

    newvm->pc=0;
    newvm->acc=0;
    newvm->cycles=0;
    
    for(i = 0; i < MAX_BREAKPOINTS; i++) 
    {
        newvm->breakpoints[i]=RESET_VECTOR;
    }

    return newvm;

}


void load_vm(struct vm_state *vm, FILE *infile) 
{
    /* read, byte by byte, an input memory image file, and very other byte, we 
       convert the last two bytes into one 16 bit quantity and shove it into 
       the vm->memory array. Notice we don't need to know the endianness of the
       system this is running on.

       The only kind of endianness we need to assume is the endianness of the 
       memory image file ('cuz the image file is byte-addressed but vm->memory 
       is 16-bit-word addressed). This is /arbitrary/ and doesn't affect any 
       aspect of the emulation or anything besides the byte order of memory 
       dump files.

       I arbitrarily set the byte order to be big endian -- this means that a
       memory dump file with initial four bytes:

       A_1        A_2           A_3         A_4

       gets translated to the 16-bit words:

       A_1 * 256 + A_2          A_3 * 256 + A_4

       in other words, the most significant byte comes first / has lower address
       than the least significant byte. 

       */
    int numread;
    uint16_t *foo;

}



