        .text
        .global _start
        .option norvc
_start:
        /* disable mie */
        csrci mstatus, 0x8

        la t0, handler
        csrw mtvec, t0

        la t0, main
        csrw mepc, t0

        /* enable MEIE */
        li t0, 0x800
        csrs mie, t0
        csrsi mstatus, 0x8

        /* clear interrupt bit and jump to main */
        mret

main:
        j main

handler:
        csrr t0, mcause
        li t1, 0x8000000b
        beq t0, t1, pass
fail:
        la t1, tohost
        sw t0, (t1)
        mret
pass:
        li t0, 1
        la t1, tohost
        sw t0, (t1)
        mret

        .data
        .global tohost
tohost:
        .dword 0
