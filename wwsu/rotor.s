
;Wkretator by PePe/tRSi

ilepts	=7600
ilesin	=100
ilesin2	=400

	section	code,code_p

	bra.w	run

frag1	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
endfrag1

frag2	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
	bset.b	d0,(a4,d1.w)
endfrag2

frag3	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a4,d1.w)
endfrag3

setscr	move.l	screenn+4,d0
	lea	c11,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1f40,d0
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

emptp	tst.l	d5
	beq.b	okiy
	move.w	#$43e9,(a0)+		;lea	XXXX(a1),a1
	move.w	d5,(a0)+
	add.l	d5,d5
	move.w	#$41e8,(a0)+		;lea	XXXX(a0),a0
	move.w	d5,(a0)+
	moveq	#0,d5
okiy	rts

run	lea	screen,a0
	lea	screenn,a1
	move.l	a0,(a1)+
	add.l	#$1f40*2,a0
	move.l	a0,(a1)+
	add.l	#$1f40*2,a0
	move.l	a0,(a1)+

	lea	tablica1,a0
	lea	tabl1,a1
	move.l	#endtabl1-tablica1,d0
	bsr.w	Decrunch

	lea	PicPP,a0
	lea	Pic,a1
	move.l	#endpic-picpp,d0
	bsr.w	Decrunch

	lea	PutPoints,a0
	lea	tabl1,a6
	lea	tabl2,a3
	lea	pic+$1f40,a4
	lea	pic,a5

	move.l	#ilepts-1,d7	
	moveq	#0,d5

putprg	move.b	(a3)+,d0
	move.w	(a6)+,d1

	btst.b	d0,(a5,d1.w)
	beq.b	bpl2

	btst.b	d0,(a4,d1.w)
	bne.b	bpl12

	bsr.w	emptp
	move.l	Frag1,(a0)+
	move.l	Frag1+4,(a0)+
	bra.b	quitp

bpl12	bsr.w	emptp
	move.l	Frag2,(a0)+
	move.l	Frag2+4,(a0)+
	move.l	Frag2+8,(a0)+
	bra.b	quitp

Bpl2	btst.b	d0,(a4,d1.w)
	beq.b	nobpl2

	bsr.w	emptp
	move.l	Frag3,(a0)+
	move.l	Frag3+4,(a0)+
	bra.b	quitp

nobpl2	addq.l	#1,d5

quitp	dbra	d7,putprg

	move.w	#$4e75,(a0)+		;rts

	move.w	$dff01c,bufor
	move.w	#$7fff,$dff09a

	lea	copper,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

main	bsr.w	setscr

	movem.l	screenn,d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,screenn

	btst	#14,$dff002
	bne.b	*-8

	move.l	#$01000000,$dff040
	clr.l	$dff044
	move.l	screenn,$dff054
	move.w	#0,$dff066
	move.w	#[400<<6]!20,$dff058

	addq.l	#4,adder
	cmp.l	#endsin-sin,adder
	bne.b	noway1
	clr.l	adder

noway1	move.l	screenn+4,a5

	lea	$1f40(a5),a4

	lea	tabl1,a0
	lea	tabl2,a1
	lea	sin,a2

	move.l	adder,d0
	move.l	(a2,d0.l),d1
	asr.l	#1,d1
	sub.l	d1,a0
	asr.l	#1,d1
	sub.l	d1,a1

	moveq	#0,d0
	moveq	#0,d1

	jsr	PutPoints

waitfr	cmp.b	#$ff,$dff006
	bne.b	waitfr

	btst	#6,$bfe001
	bne.w	main
	
	move.w	bufor,d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	rts

	incdir	df0:
	include	PPackerDecrunch.s

bufor	dc.w	0
screenn	dc.l	0,0,0,0
adder	dc.l	0

sin	blk.l	100
sin1	blk.l	ilesin
sin2	blk.l	ilesin2
	blk.l	100,36324
endsin

	auto	cs\sin1\90\360+90\ilesin\50\-50\l4\yy
	auto	cs\sin2\270\360\ilesin2\9100\9100\l4\yy

	incdir	df0:incl/

tablica1	incbin	tabl.pp
endtabl1
PicPP		incbin	pic.raw.pp
endpic

		section	chips,data_c

copper		dc.l	$009683c0,$00960020
		dc.l	$008e2c50,$00902cc1
		dc.l	$01080000,$010a0000
		dc.l	$00920038,$009400d0

		dc.w	$0180,$0333,$0182,$0fff,$0184,$0aaa,$0186,$0888

c11		dc.l	$00e00000
		dc.l	$00e20000
		dc.l	$00e40000
		dc.l	$00e60000

		dc.l	$01002000
		dc.l	$f007fffe,$01000000
		dc.l	-2

		section	screen,bss_c

screen		ds.b	$1f40*2*3

		section	dupa,bss_p

putpoints	ds.b	$6000
pic		ds.b	$1f40*2

		ds.b	$d99c/2
tabl1		ds.b	$d99c/2
tabl2		ds.b	$d99c/4


