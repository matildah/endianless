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
    return 0;

    
}

struct vm_state *initialize_vm()
{
    struct vm_state *newvm = NULL;
    int i = 0;

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
     
    int total_written = 0 ;     /* total number of words written to the array */

    assert(vm != NULL);

    curwrite = vm->memory;

    assert(curwrite != NULL);


    while (1)
    {
        read_a = fread(&a, 1, 1, infile);
        read_b = fread(&b, 1, 1, infile);
        
        if (read_a != read_b)
        {
        fprintf(stderr,"odd number of bytes in memory dump file \n");
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
                
                if (total_written == 0)
                {
                    /* reached EOF but didn't do anything useful in this 
                       function */

                    fprintf(stderr, "we didn't read any words into the memory array, are you sure all is OK?\n");
                }
            fprintf(stderr, "we read %d words into memory\n", total_written);
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

        *curwrite = a * 256 + b;
        total_written++; 

    }

}
