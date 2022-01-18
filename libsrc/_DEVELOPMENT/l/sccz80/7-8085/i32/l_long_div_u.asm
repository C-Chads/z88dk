;       Z88 Small C+ Run Time Library
;       Long functions
;
;       feilipu 10/2021


SECTION code_clib
SECTION code_l_sccz80

PUBLIC  l_long_div_u, l_long_div_u_0

;for __printf_number where LSB of modulus is required in a
;where the math library provides a l_long_div_u without this feature
PUBLIC  l_long_div_m

;quotient = primary / secondary
;enter with secondary (divisor) in dehl, primary (dividend | quotient) on stack
;exit with quotient in dehl

.l_long_div_u
.l_long_div_m
    ld a,d                      ;check for divide by zero
    or e
    or h
    or l                        ;clear Carry to quotient
    jp Z, divide_by_zero

    push    de                  ;put secondary (divisor) on stack
    push    hl

    ld      bc,0                ;establish remainder on stack
    push    bc
    push    bc

    push    bc                  ;save null sign info

    call    l_long_div_u_0      ;unsigned division

    ;tidy up with quotient to dehl

    ld      de,sp+14            ;get quotient MSW
    ld      hl,(de)
    ld      bc,hl               ;quotient MSW

    ld      de,sp+10            ;get return from stack
    ld      hl,(de)
    ld      de,sp+14            ;place return on stack
    ld      (de),hl

    ld      de,sp+2             ;get remainder LSB (for __printf_number)
    ld      a,(de)

    ld      de,sp+12            ;get quotient LSW
    ld      hl,(de)

    ld      de,sp+14            ;point to return again
    ex      de,hl               ;quotient LSW <> return sp
    ld      sp,hl               ;remove stacked parameters

    ex      de,hl               ;quotient LSW
    ld      de,bc               ;quotient MSW

    ret


.l_long_div_u_0
    ld      b,32                ;set up div_loop counter

.div_loop

    ld      de,sp+14            ;rotate left dividend + quotient Carry

    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a

    ld      de,sp+4             ;rotate left remainder + dividend Carry

    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a

    ld      de,sp+8             ;compare (remainder - divisor)
    ex      de,hl
    ld      de,sp+4

    ld      a,(de)
    sub     a,(hl)
    inc     de
    inc     hl
    ld      a,(de)
    sbc     a,(hl)
    inc     de
    inc     hl
    ld      a,(de)
    sbc     a,(hl)
    inc     de
    inc     hl
    ld      a,(de)
    sbc     a,(hl)

    jp      C,skip_subtract     ;skip if remainder < divisor

    ld      de,sp+8             ;subtract (remainder - divisor)
    ex      de,hl
    ld      de,sp+4

    ld      a,(de)
    sub     a,(hl)
    ld      (de),a
    inc     de
    inc     hl
    ld      a,(de)
    sbc     a,(hl)
    ld      (de),a
    inc     de
    inc     hl
    ld      a,(de)
    sbc     a,(hl)
    ld      (de),a
    inc     de
    inc     hl
    ld      a,(de)
    sbc     a,(hl)
    ld      (de),a

.skip_subtract
    ccf                         ;prepare Carry for quotient

    dec     b
    jp      NZ,div_loop

    ld      de,sp+14            ;rotate left quotient Carry

    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a
    inc     de
    ld      a,(de)
    rla
    ld      (de),a

    ret


.divide_by_zero
    pop     bc                  ;pop return
    pop     hl                  ;pop dividend
    pop     de
    push    bc                  ;replace return

    ld      de,$ffff            ;return ULONG_MAX
    ld      hl,de

    ret
