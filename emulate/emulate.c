#include "emulate.h"


int main(int argc, char **argv)
{
    
    FILE *in = NULL, *out = NULL;
    struct vm_state *myvm = NULL ;
    int runcycles = 0;
    if (argc != 4)
    {
        fprintf(stderr, "usage: %s input output cycles \n", argv[0]);
        exit(1);
    }

    in = fopen(argv[1], "rb");
    out = fopen(argv[2], "wb");    

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

    myvm = initialize_vm();
    load_vm(myvm, in);
    run_vm(myvm, runcycles);
    return 0;

    
}

struct vm_state *initialize_vm()
{
    struct vm_state *newvm = NULL;
    int i = 0;

    newvm = (struct vm_state *)malloc(sizeof(struct vm_state));
    assert(newvm != NULL);

    newvm->pc = RESET_VECTOR;
    newvm->acc = 0;
    
    for (i = 0; i < MEMORY_SIZE; i++)
    {
        newvm->memory[i] = 0xFFFF;
    }


    return newvm;

}


void load_vm(struct vm_state *vm, FILE *infile) 
{
    /* read, byte by byte, an input memory image file, and every other byte, we 
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

       A_1        B_1           A_2         B_2

       gets translated to the 16-bit words:

       A_1 * 256 + B_1          A_2 * 256 + B_2

       in other words, the most significant byte comes first / has lower address
       than the least significant byte. 

       */

    int read_a = 0;             /* numbers of bytes read in the first fread call */
    int read_b = 0;             /* numbers of bytes read in the second fread call */
    

    uint8_t a = 0, b = 0;       /* where we store each byte pair after reading it but
                                 before storing it into the array */

    uint16_t *curwrite = NULL;  /* pointer to the beginning of where we're currently 
                                 writing */
     

    assert(vm != NULL);

    curwrite = vm->memory;

    assert(curwrite != NULL);


    while (1)
    {
        read_a = fread(&a, 1, 1, infile);
        read_b = fread(&b, 1, 1, infile);
        
        if (read_a != read_b)
        {
            fprintf(stderr,"error: odd number of bytes in memory dump file \n");
            exit(2);
        }

        if (read_a != 1 || read_b != 1 )
        {
            /* we weren't able to get two bytes from the file, either we have
               an EOF condition or an error condition */
            
            if (ferror(infile))
            {
                /* error condition, bail out */
                fprintf(stderr,"error reading memory dump file \n");
                exit(2);
            }

            if (feof(infile))
            {
                /* we reached EOF, we're done reading */
                
                if (curwrite - vm->memory == 0)
                {
                    /* reached EOF but didn't do anything useful in this 
                       function */

                    fprintf(stderr, "we didn't read any words into the memory array, are you sure all is OK?\n");
                    exit(2);
                }
            fprintf(stderr, "we read %ld words into memory\n", curwrite - vm->memory);
            return; /* our work here is done 'cuz we don't have anything more
                     to read */
            }
            
            /* we weren't able to read two bytes from the file, but ferror and
               feof both returned zero, something weird is up */
            fprintf(stderr, "wasn't able to read two bytes from file, but ferror and feof both returned zero, this should not happen\n");
            exit(10);
        }
        
        /* ok, now we've taken care of all the possible error conditions, so we
           can assume we've read two bytes into a and b */
        
        if (curwrite - vm->memory >= MEMORY_SIZE  )
        {
            fprintf(stderr, "too many words in the memory dump file to fit in memory, halting!\n");
            exit(3);
        }
        *curwrite = a * 256 + b;
        curwrite++;



    }

}


void dump_vm(struct vm_state *vm, FILE *infile) 
    /* dumps the memory contents to a file */
{

}


uint32_t run_vm(struct vm_state *myvm, uint32_t runcycles) 
    /* runs the VM described at myvm for runcycles cycles and returns the number
       of cycles executed (this may be lower than runcycles if the instruction
       pointer hits the reset vector) 
     
       if runcycles == 0, we run for infinitely many cycles */
{
    uint32_t cycle;
    uint16_t ins, opcode, addr;
    for (cycle = 0; (cycle < runcycles) || (runcycles == 0 ); cycle ++)
    {
        ins = myvm->memory[myvm->pc];
        opcode = ins & 0xC000;
        addr   = ins & 0x3fff;
        
        switch (opcode)
        {
            case 0x0000: /* nand */
                myvm->pc  = (myvm->pc + 1) % MEMORY_SIZE;
                myvm->acc = ~ (myvm->acc & myvm->memory[addr]);
                break;

            case 0x4000: /* add */
                myvm->pc  = (myvm->pc + 1) % MEMORY_SIZE;
                myvm->acc = myvm->acc & 0xFFFF; /* clear carry bit */
                myvm->acc = (myvm->acc + myvm->memory[addr]);
                break;

            case 0x8000: /* store */
                myvm->pc = (myvm->pc + 1) % MEMORY_SIZE;
                myvm->memory[addr] = (myvm->acc) & 0xFFFF;
                break;

            case 0xC000: /* jump if carry not set */
                if (myvm->acc & 0x10000 == 0x10000) /* test carry bit */
                { /* carry bit is set */
                    myvm->acc = myvm->acc & 0xFFFF; /* clear carry bit */
                    myvm->pc = (myvm->pc + 1) % MEMORY_SIZE;
                    break;
                }
                /* carry is not set, so we must jump */ 
                myvm->pc = addr; /* jump to the given address */
                break;

            default: /* this never, ever, should be reached */
                assert (1 == 0);
        }

        if (myvm->pc == RESET_VECTOR)
        {
            return cycle;
        }

    }
    return cycle;
}

