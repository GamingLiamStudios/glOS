ENTRY(_enter_lm)

SECTIONS
{
	. = 0x7e00;

	.text ALIGN(4K) :
	{
		KEEP(*(.text*))
	}

	.rodata ALIGN(4K) :
	{
		KEEP(*(.rodata*))
	}

	.data ALIGN(4K) :
	{
		KEEP(*(.data*))
	}

	.bss ALIGN(4K) :
	{
		KEEP(*(COMMON))
		KEEP(*(.bss*))
	}
}