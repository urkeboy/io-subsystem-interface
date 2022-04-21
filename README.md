# io-subsystem-interface
[Computer Architecture] CPU communication with I/O devices and DMA controllers in Assembly.

Homework/project in **Computer Architecture (13E112AR)** at the University of Belgrade, School of Electrical Engineering.

##

### First part

`Deo_A:` initializing IVT (Interrupt Vector Table) entries, and loading arrays A and B from two peripherals using interrupts.

The main program is stored in memory starting at address 4000h. Interrupt Vector (IV) table and Interrupt Vector Table Pointer (IVTP) register are initialized as follows:

| No. | Content | Device |
| --- | ------- | ------ |
| 3   | 0500h   | KP1.1  |
| 4   | 1000h   | KP1.2  |
| 1   | 1500h   | KP2.1  |
| 0   | 2000h   | DMA1.1 |
| 2   | 2500h   | DMA1.2 |
| 5   | 3000h   | DMA1.4 |

```
IVTP = 0300h
```

Arrays A and B are loaded and stored in memory starting at addresses 5000h and 6000h, respectively. The arrays have 8h elements each. Array A is loaded from KP1.1 using interrupts, and array B is loaded from KP2.1 using interrupts. Loading is done in parallel using both peripherals.

### Second part
`Deo_B:` processing elements using the dedicated subroutine and copying new array into operating memory using DMA (Direct memory access) controller in packet mode.

Subroutine void `processElem (int* elem)` performs a complementation operation on the data at the pointed address. After receiving arrays A and B, for each element A[i], the subroutine `processElem` is invoked if the corresponding element B[i] is an even number.

```
processElem:    push r0                 ! void processElem(int* elem)
                mvrpl r0, sp            ! stack: r0 [sp+0], PCret [sp+1], elem [sp+2]
                push r1
                push r2
                ldrid [r0]x.2, r1       ! r1 <= elem
                ldrid [r1]x.0, r2       ! r2 <= *elem
                not r2
                stri [r1], r2
                pop r2
                pop r1
                pop r0
                rts
```

After this, the zeroth element of array A is stored in memory at address 9999h. Also, starting at address 5100h, the processed array A is copied to memory using DMA1.4 devices in batch mode.

### Third part
`Deo_C:` sending the resulting array to a peripheral by probing device status.

After completing previous tasks, array A is sent to peripheral KP1.2 by examining the readiness bit.
```
ldimm x.0001, r0
loopV:  ldmem x.f141, r3                ! slanje KP1.2 (ispitivanjem ready bita)
        and r3, r3, r0
        beql loopV
        ldrid [r2]x.0000, r5
        stmem x.f143, r5
        inc r2
        dec r1
        bneq loopV

ldimm x.0000, r0
stmem x.f140, r0                        ! gasenje periferije (Control registar KP1.2)
```

Also, the value from memory location 9999h is sent to the DMA1.2 device in batch mode.
```
ldimm x.0001, r0                        ! inicijalizacija DMA1.2
stmem x.f044, r0                        ! DMA1.2 - Count registar
ldimm x.9999, r0
stmem x.f045, r0                        ! DMA1.2 - AR1 registar (src)
clr r1                                  ! sem (r1)
ldimm x.008e, r0
stmem x.f040, r0                        ! DMA1.2 - Control registar
```
