#!/usr/bin/python

# 16-bit endianless emulator
# by susan werner <heinousbutch@gmail.com> 

import array

# input: assembled endianless-16 code
# output: memory image at given breakpoints (supplied on the command line)
# and when the reset instruction is executed




class CPU:
    """CPU object -- holds state of a CPU, memory, and breakpoints"""

    RESET_VECTOR = 0x3fff 

    def __init__(self, initial_memory, breakpoints=[]):
        """Creates a CPU object given a memory image, along with an optional 
        list of breakpoints. 

        """
        # actual cpu state
        self.acc    = 0x0000 # 16 bit wide accumulator
        self.pc     = self.RESET_VECTOR  # 14 bit program counter
        self.carry  = False  # carry flag
        
        self.memory = initial_memory

        # other stuff
        self.breakpoints = breakpoints

        self.cycles = 0      # cycles elapsed since start


    def run(self, runcycles=0):
        """runs the CPU for the given number of cycles or until the CPU 
        executes a reset instruction, whichever comes first. runcycles=0 means no 
        limit on the cycle count"""
        
        assert runcycles >= 0

        startcycles = self.cycles
         
        while True:                 
                                    
            if (runcycles != 0) and (self.cycles - startcycles >= runcycles):
                break
            if (self.pc == self.RESET_VECTOR) and (self.cycles != 0):
                break
            if (self.pc in self.breakpoints):
                break


            inst = self.memory[self.pc] 
            opcode = inst & 0xC000
            addr   = inst & 0x3fff
            print (addr)
            if   opcode == 0x0000: # nand
                print("nand")
                self.acc = ~ (self.acc & self.memory[addr])
                self.pc = (self.pc + 1) % (2**14)

            elif opcode == 0x4000: # add
                print("add")
                result = self.acc + self.memory[addr]
                if (result % (2 ** 16) != result):
                    self.carry = True
                self.acc = result % (2 ** 16)
                self.pc = (self.pc + 1) % (2**14)

            elif opcode == 0x8000: # store
                print("store")
                self.memory[addr] = self.acc
                self.pc = (self.pc + 1) % (2**14)

            elif opcode == 0xC000: # jump if carry isn't set
                print("jnc")
                if self.carry == True:                  # carry set, so we 
                    self.carry = False                  # unset it
                    self.pc = (self.pc + 1) % (2**14)   # and don't jump

                else:                                   # carry isn't set, so
                    self.pc = addr                      # we jump
                    print("jumping to", addr)

            else:                  # something went seriously wrong
                assert 1 == 0      # so we ruin everything

            print("loldone")

            self.cycles += 1
            




if __name__ == "__main__":
    mem = array.array('H',[0x8ffe] * (2**14))
    a = open("output",'wb')
    cpu = CPU(mem)
    cpu.run(100)
    mem.tofile(a)
