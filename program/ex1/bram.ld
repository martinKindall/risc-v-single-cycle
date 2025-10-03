MEMORY
{
   IMEM (RX)  : ORIGIN = 0x00000000, LENGTH = 0x0800   /* 2 KB */
   DMEM (RW)  : ORIGIN = 0x00001000, LENGTH = 0x1000   /* 4 KB */
}

SECTIONS
{
   .text :
   {
      . = ALIGN(4);
      testProgram.o (.text)
      *(.text*)
   } >IMEM

   .data :
   {
      *(.data*)
      *(.rodata*)
      *(.bss*)
   } >DMEM
}
