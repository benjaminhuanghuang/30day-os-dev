ENTRY( entry )

SECTIONS
{
  .text 0xc200: { 
    *(.text) 
  }
  .data : { *(.data) }
}