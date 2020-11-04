ENTRY(_enter_kernel)

SECTIONS
{
	. = 0x7e00;

	.text : ALIGN(0x1000)
	{
		KEEP(*(.text))
	}

	.idt BLOCK(0x1000) : ALIGN(0x1000) /* Could probably use this for other predefined memory spaces */
	{
		_idt = .;
		. = . + 0x1000;
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