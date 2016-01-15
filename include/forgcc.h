#ifndef _FORGCC_H_
#define _FORGCC_H_

typedef signed char s8;
typedef unsigned char u8;
typedef signed short s16;
typedef unsigned short u16;
typedef signed long s32;
typedef unsigned long u32;
typedef float 	f32;
typedef double 	f64;

#define BIT(x) (1uL << (x))

#ifndef NULL
#define NULL	((void *)0)
#endif

#ifndef __even_in_range
#define __even_in_range(x,NUM)	(x & (~1uL))
#endif
// Macro for button IRQ
#define IRQ_TRIGGERED(flags, bit)               ((flags & bit) == bit)

// Macro for define an interrupt
// elf-gcc

#define MAKE_INTERRUPT(v,handle) void __attribute__((__interrupt__(v))) handle(void)

// gcc
//#define MAKE_INTERRUPT(v,handle) #pragma vector=v __interrupt void handle(void)

#endif

