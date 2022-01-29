	bra.w	run

waitframe:macro
\@1:	cmp.b	#$ff,$dff006
	bne.b	\@1
\@2:	cmp.b	#$2,$dff006
	bne.b	\@2
endm
waitblit:macro
	btst	#14,$dff002
	bne.b	*-8
	ENDM


run:	lea	screen,a0
	move.l	a0,d0
	lea	c11,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)

	lea	bufor(pc),a0
	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a

	lea	Adde,a0
	move.l	#319,d7
alop:	move.w	(a0),d0
	mulu.w	#40,d0
	move.w	d0,(a0)+
	dbra	d7,alop


	lea	copper(pc),a0
	move.l	a0,$dff080
	move.w	d0,$dff088

mysz:	waitframe

	move.l	#319,d7
	lea	screen,a0
	lea	Pos,a1
	lea	Adde,a2

Poin:	moveq	#0,d0
	move.b	$dff007,d0
	add.b	$dff006,d0
	add.b	$dff006,d0
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	add.w	d0,(a1)
	move.w	d7,d0
	move.b	d0,d1
	not.b	d1
	asr.w	#3,d0
	add.w	(a1)+,d0
	cmp.w	#260*40,d0
	ble.b	Nas
	clr.w	d0
Nas:	bset	d1,(a0,d0.w)
	bset	d1,-40(a0,d0.w)
	bset	d1,-80(a0,d0.w)
	bset	d1,-120(a0,d0.w)
	dbra	d7,Poin


	btst	#6,$bfe001
	bne.s	mysz
	


	move.w	bufor(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff09a

	rts

Pos:	blk.w	320
Adde:
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,²,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,²,1,2,3,2,1
	dc.w	1,2,3,2,1,2,3,2,1,2,3,²,1,2,3,2,1,2,3,²,1
	dc.w	1,2,3,2,1,2,3,²,1,2,3,2,1,2,³,²,1,2,3,2,1

bufor:		dc.w	0
screenn:	dc.l	0
	even
copper:
	dc.l	$009683e0,$00960020

	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000
	dc.l	$00920038,$009400d0

c11:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000

	dc.l	$01001000
	dc.l	$fffffffe

	blk.b	40*5
screen:
blk.b	$2900,0
