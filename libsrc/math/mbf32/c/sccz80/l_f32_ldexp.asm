;
; Intrinsic sccz80 routine to multiply by a power of 2
;
;
    SECTION code_fp_mbf32

    PUBLIC  l_f32_ldexp

; Entry: a = adjustment for exponent
;       Stack: float, ret
; Exit: dehl = adjusted float

l_f32_ldexp:
    ld      c,a
    ld      a,d
    and     a
    ret     z
    add     c
    ld      d,a
    ret
