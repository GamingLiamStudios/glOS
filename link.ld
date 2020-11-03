ENTRY(_enter_kernel)

SECTIONS
{
	. = 0x7e00;

	.text : ALIGN(0x1000) 
	{
		KEEP(*(.text))
	}

	.rodata : ALIGN(0x1000) 
	{
		KEEP(*(.rodata))
	}

	.data : ALIGN(0x1000) 
	{
		KEEP(*(.data))
	}

	.bss : ALIGN(0x1000) 
	{
		KEEP(*(COMMON))
		KEEP(*(.bss))
	}
}