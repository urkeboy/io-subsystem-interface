! inicijalizacija simulacije
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! kraj inicijalizacije

! ###############################################################################

! Deo A3 - pocetak

Deo_A:
org x.4000                              ! glavni program
ldimm x.0300, r0
mvrir r0, ivtp                          ! IVTP <= 0300h
ldimm x.0500, r0                        ! inicijalizacija IV tabele
stmem x.0303, r0                        ! ul.3: KP1.1
ldimm x.1000, r0
stmem x.0304, r0                        ! ul.4: KP1.2
ldimm x.1500, r0
stmem x.0301, r0                        ! ul.1: KP2.1
ldimm x.2000, r0
stmem x.0300, r0                        ! ul.0: DMA1.1
ldimm x.2500, r0
stmem x.0302, r0                        ! ul.2: DMA1.2
ldimm x.3000, r0
stmem x.0305, r0                        ! ul.5: DMA1.4

ldimm x.0003, r0                        ! inicijalizacija KP1.1
stmem x.f102, r0                        ! KP1.1 - Entry registar
ldimm x.0001, r0                        ! inicijalizacija KP2.1
stmem x.f202, r0                        ! KP2.1 - Entry registar

ldimm x.0009, r1                        ! cnt1 (r1)
ldimm x.5000, r2                        ! ptr1 (r2)
clr r3                                  ! sem1 (r3)
ldimm x.0009, r4                        ! cnt2 (r4)
ldimm x.6000, r5                        ! ptr2 (r5)
clr r6                                  ! sem2 (r6)

ldimm x.000f, r0                        ! inicijalizacija KP1.1 i KP2.1
stmem x.f100, r0                        ! KP1.1 - Control registar
stmem x.f200, r0                        ! KP2.1 - Control registar

ldimm x.0001, r9
waitA1: cmp r3, r9                      ! cekanje na sem1 (r3)
        bneq waitA1
waitA2: cmp r6, r9                      ! cekanje na sem2 (r6)
        bneq waitA2

jmp Deo_B

! Deo A3 - kraj

! ###############################################################################

! Deo B3 - pocetak

Deo_B:
ldimm x.5000, r1                        ! niz A
ldimm x.6000, r2                        ! niz B
ldimm x.0009, r3                        ! cnt
clr ra                                  ! pok A
clr rb                                  ! pok B

loopB:  dec r3
        beql skipB
        add rb, r2, r3
        dec rb                          ! rb <= &B[i]
        ldrid [rb]x.0000, r4            ! r4 <= B[i]
        ldimm x.0001, r5
        and r4, r4, r5                  ! r4 = B[i] % 2
        bneq loopB                      ! if (B[i] % 2 != 0) { continue; }
        add ra, r1, r3
        dec ra                          ! r1 <= &A[i]
        push ra
        jsr processElem                 ! else { processElem(i); }
        pop ra
        jmp loopB

skipB:
ldmem x.5000, r1                        ! cuvanje A[0]    na MEM[9999h]
stmem x.9999, r1

ldimm x.0008, r0                        ! inicijalizacija DMA1.4
stmem x.f0c4, r0                        ! DMA1.4 - Count registar
ldimm x.5000, r0
stmem x.f0c5, r0                        ! DMA1.4 - AR1 registar (src)
ldimm x.5100, r0
stmem x.f0c6, r0                        ! DMA1.4 - AR2 registar (dst)
clr r1                                  ! sem (r1)
ldimm x.be, r0
stmem x.f0c0, r0                        ! DMA1.4 - Control registar

ldimm x.0001, r9
wait3:  cmp r1, r9                      ! cekanje na sem (r1)
        bneq wait3

jmp Deo_V

processElem:    push r0                 ! void processElem(int* elem)
                mvrpl r0, sp            ! stack: r0 [sp+0], PCret [sp+1], elem [sp+2]
                push r1
                push r2
                ! <--
                ldrid [r0]x.2, r1       ! r1 <= elem
                ldrid [r1]x.0, r2       ! r2 <= *elem
                not r2
                stri [r1], r2
                ! -->
                pop r2
                pop r1
                pop r0
                rts


! Deo B3 - kraj

! ###############################################################################

! Deo V0 - pocetak

Deo_V:
ldimm x.0004, r0                        ! inicijalizacija KP1.2
stmem x.f140, r0                        ! KP1.2 - Control registar

ldimm x.0008, r1                        ! cnt (r1)
ldimm x.5000, r2                        ! ptr (r2)

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

ldimm x.0001, r0                        ! inicijalizacija DMA1.2
stmem x.f044, r0                        ! DMA1.2 - Count registar
ldimm x.9999, r0
stmem x.f045, r0                        ! DMA1.2 - AR1 registar (src)
clr r1                                  ! sem (r1)
ldimm x.008e, r0
stmem x.f040, r0                        ! DMA1.2 - Control registar

ldimm x.0001, r9
waitV:  cmp r1, r9                      ! cekanje na sem (r1)
        bneq waitV


! Deo V0 - kraj

halt                                    ! kraj programa

! ###############################################################################

! Prekidne rutine - pocetak

org x.0500                              ! prekidna rutina KP1.1
dec r1
bneq runKP11
clr r3                                  ! gasenje periferije (Control registar KP1.1)
stmem x.f100, r3
ldimm x.0001, r3                        ! paljenje semafora (sem1)
jmp backKP11
runKP11:        ldmem x.f103, r0        ! ucitavanje podatka (iz Data registra KP1.1)
                stri [r2], r0
                inc r2
backKP11:       rti

org x.1500                              ! prekidna rutina KP2.1
dec r4
bneq runKP21
clr r6                                  ! gasenje periferije (Control registar KP2.1)
stmem x.f200, r6
ldimm x.0001, r6                        ! paljenje semafora (sem2)
jmp backKP21
runKP21:        ldmem x.f203, r0        ! ucitavanje podatka (iz Data registra KP1.1)
                stri [r5], r0
                inc r5
backKP21:       rti

org x.2000                              ! prekidna rutina DMA1.1
clr r1
stmem x.f000, r1                        ! gasenje periferije (Control registar DMA1.1)
ldimm x.0001, r1                        ! paljenje semafora (r1)
rti

org x.2500                              ! prekidna rutina DMA1.2
clr r1
stmem x.f040, r1                        ! gasenje periferije (Control registar DMA1.2)
ldimm x.0001, r1                        ! paljenje semafora (r1)
rti

org x.3000                              ! prekidna rutina DMA1.4
clr r1
stmem x.f0c0, r1                        ! gasenje periferije (Control registar DMA1.4)
ldimm x.0001, r1                        ! paljenje semafora (r1)
rti

! Prekidne rutine - kraj
