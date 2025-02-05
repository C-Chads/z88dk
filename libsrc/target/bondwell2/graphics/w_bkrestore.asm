;
;	Fast background restore
;
;	Bondwell2 version
;	Stefano, 2021
;
;	$Id: w_bkrestore.asm $
;

IF !__CPU_INTEL__
	SECTION   smc_clib
	
	
	EXTERN    w_pixeladdress
	EXTERN    swapgfxbk
	EXTERN    swapgfxbk1


    PUBLIC    bkrestore
    PUBLIC    _bkrestore
    PUBLIC    bkrestore_fastcall
    PUBLIC    _bkrestore_fastcall

.bkrestore
._bkrestore
    pop de
    pop hl
    push hl
    push de

.bkrestore_fastcall
._bkrestore_fastcall

	push	ix
; __FASTCALL__ : sprite ptr in HL
	
	push	hl
	pop	ix

	ld	l,(ix+2)	; x
	ld	h,(ix+3)
	ld	e,(ix+4)	; y
	;ld	d,(ix+5)
	ld		d,0
	
	ld		(x_coord+1),hl
	ld	c,e

	push	bc
	call	w_pixeladdress
	pop	bc

	ld	a,(ix+0)
	ld	b,(ix+1)
	
	dec	a
	srl	a
	srl	a
	srl	a
	inc	a
	inc	a		; INT ((Xsize-1)/8+2)
	ld	(rbytes+1),a

.bkrestores
	push	bc
	
.rbytes
	ld	b,0
.rloop
	ld	a,(ix+6)
	ld h,a
	call swapgfxbk
	ld a,h
	ld	(de),a
	call swapgfxbk1
	inc	de
	inc	ix
	djnz	rloop

	ld	d,0
	ld	e,c
	inc e	; y
.x_coord
	ld	hl,0
	call	w_pixeladdress
	
	pop	bc
	inc c	; y
	
	djnz	bkrestores
	pop	ix
	ret
ENDIF
