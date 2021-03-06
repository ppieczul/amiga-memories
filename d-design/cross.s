
run:	lea	pstr(pc),a0
	moveq	#[pstrend-pstr]/2-1,d7
stilp:	move.w	(a0)+,d0
	bmi.b	stil
	asl.w	#2,d0
	move.w	d0,-2(a0)
stil:	dbra	d7,stilp

	lea	mul40(pc),a0
	moveq	#0,d0
lopklop:move.l	d0,d1
	mulu	#40,d1
	move.w	d1,(a0)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.b	lopklop

	lea	single(pc),a1
	lea	screen,a0
	move.l	a0,(a1)
	add.l	#$4fb0,a0
	move.l	a0,4(a1)
	add.l	#$4fb0,a0
	move.l	a0,8(a1)
	add.l	#$4fb0,a0
	move.l	a0,12(a1)

	moveq	#1,d1
	bsr.w	setscr
	move.l	single+12(pc),a0
	

	lea	bufor(pc),a0
	lea	stary(pc),a1
	lea	vblk(pc),a2
	lea	next(pc),a3

	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a
	move.l	$6c,(a1)
	move.l	a2,$6c
	move.l	stary(pc),$02(a3)
	
	move.w	(a0),d0
	or.w	#$8020,d0
	move.w	d0,$dff09a

	lea	copper(pc),a0
	move.l	a0,$dff080
	move.w	d0,$dff088

mysz:	btst	#6,$bfe001
	bne.s	mysz
	
quit:  	move.w	#$7fff,$dff09a
	move.l	stary(pc),$6c
	move.w	bufor(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	rts


zet:	MACRO
	moveq	#0,d4
	move.w	d5,d4
lefty:	move.l	#$0,d6
	asl.l	#1,d4
	sub.l	d4,d6
	muls	d6,d0
	muls	d6,d1
	swap	d0
	swap	d1
	exg	d4,d5
	ENDM

rotate:	MACRO
	add.w	d2,d2
	lea	sinus(pc),a6
	move.w	(a6,d2.w),d6
	add.w	#180,a6
	move.w	(a6,d2.w),d4
	add.w	d0,d0
	move.w	d0,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	d4,d0
	swap	d0
	muls.w	d6,d1
	swap	d1
	sub.w	d1,d0
	muls.w	d6,d2
	swap	d2
	muls.w	d4,d3
	swap	d3
	add.w	d2,d3
	exg	d3,d1
	ENDM
	
vblk:	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$dff01e,d0
	and.w	#$0020,d0
	bne.s	okey
	bra.s	exit2
exit1:
;	move.w	#$fff,$dff180
	move.w	#$0020,$dff09c
exit2:	movem.l	(sp)+,d0-d7/a0-a6
next:	jmp	0.l

okey:
	cmp.l	#$3000,lefty+2
	bge.b	NOPq
	add.l	#$40,Lefty+2
NOPq:
	;bra	exit1
	lea	single(pc),a0
	move.l	8(a0),d0
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	moveq	#1,d1
	bsr.w	setscr

	bsr.w	clear

	lea	destp(pc),a4
	lea	points(pc),a5
	move.l	#[pointsend-points]/6-1,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

cpr2:	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5
	move.w	alfa(pc),d2
	exg	d1,d5
	ROTATE
	exg	d1,d5
	move.w	alfa+2(pc),d2
	exg	d0,d5
	ROTATE
	exg	d0,d5
	move.w	alfa+4(pc),d2
	ROTATE
	ZET
	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2

	lea	y1(pc),a0
	lea	dodp(pc),a1
	lea	bplp(pc),a2
	lea	hide(pc),a3
	lea	destp(pc),a4
	lea	scract(pc),a5
	move.l	single(pc),(a5)
	lea	pstr(pc),a6

	move.w	(a6)+,d0
	move.w	d0,(a1)
	move.w	d0,2(a1)

rept:	tst.l	(a3)
	bne.b	rept2

	move.w	(a1),d3
	move.w	(a6),d4
	move.w	2(a6),d5

	move.w	(a4,d3.w),d0
	sub.w	(a4,d4.w),d0
	move.w	2(a4,d5.w),d1
	sub.w	2(a4,d4.w),d1
	mulu	d1,d0
	move.w	(a4,d4.w),d1
	sub.w	(a4,d5.w),d1
	move.w	2(a4,d4.w),d2
	sub.w	2(a4,d3.w),d2
	mulu	d2,d1

	cmp.w	d1,d0
	bpl.b	rept2

wait:	move.w	(a6)+,d0
	bpl.b	wait	
	cmp.w	#-4,d0
	beq.b	wait
	subq.l	#2,a6

rept2:	move.w	(a6)+,d0
	bpl.b	pluk
	cmp.w	#-1,d0
	beq.b	quity
	move.w	d0,d6
	moveq	#0,d7
	move.w	(a6)+,d7
	move.l	(a2,d7.w),d7
	add.l	single(pc),d7
	move.w	2(a1),d0
	move.w	(a1),d1
	bsr.b	draw
	move.w	(a6),(a1)
	move.w	(a6)+,2(a1)
	move.l	d7,(a5)
	cmp.b	#-4,d6
	beq.b	rept2
	bra.b	rept

pluk:	move.w	(a1),d1
	move.w	d0,(a1)
	bsr.b	draw
	bra.b	rept2

draw:	move.w	d0,d2
	move.w	d1,d3
	move.w	(a4,d2.w),4(a0)
	move.w	2(a4,d2.w),(a0)
	move.w	(a4,d3.w),6(a0)
	move.w	2(a4,d3.w),2(a0)
	bsr.b	line
	rts
	
quity:	bsr.w	fill
	lea	alfa(pc),a0
	lea	dodaj(pc),a1
	moveq	#2,d0
addlv2:	move.w	(a1),d1
	add.w	d1,(a0)
	cmp.w	#360,(a0)
	bmi.b	nookr2
	clr.w	(a0)
nookr2:	tst.w	(a0)
	bpl.b	nookr3
	clr.w	(a0)
nookr3:	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,addlv2
	bsr	waitblit
	bra.w	exit1

line:	movem.l	d0-d6/a0-a6,-(sp)

	add.w	#162,4(a0)
	add.w	#162,6(a0)
	add.w	#128,(a0)
	add.w	#128,2(a0)


	lea	mul40(pc),a1
	lea	$dff000,a5

	move.w	(a0),d0
	cmp.w	2(a0),d0
	beq.w	l_quit
	bhi.b	l_noych
	move.w	2(a0),(a0)
	move.w	d0,2(a0)
	move.w	4(a0),d0
	move.w	6(a0),4(a0)
	move.w	d0,6(a0)
l_noych:subq.w	#1,(a0)

	move.w	4(a0),d0
	move.w	(a0),d1
	move.w	6(a0),d2
	move.w	2(a0),d3
	move.l	scract(pc),a6

	moveq	#0,d4
	move.w	d1,d4
	add.w	d4,d4

	move.w	(a1,d4.w),d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a6,d4

	moveq	#0,d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.b	y2Gy1
	neg.w	d3
y2Gy1:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx1
	neg.w	d2
x2Gx1:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdx
	exg.l	d2,d3
dyGdx:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsF(pc,d5.w),d5

WBlit:	btst.b	#14,$02(a5)
	bne.b	WBlit

	move.w	d2,$62(a5)
	sub.w	d3,d2
	bge.b	SignNl
	or.b	#$40,d5
SignNl:
	move.w	d2,$52(a5)
	sub.w	d3,d2
	move.w	d2,$64(a5)
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0b4a,d0
	move.l	#$ffff8000,$72(a5)
	move.l	#$ffffffff,$44(a5)
	move.w	#40,$60(a5)
	move.w	#40,$66(a5)
	move.w	d0,$40(a5)
	move.w	d5,$42(a5)
	move.l	d4,$48(a5)
	move.l	d4,$54(a5)

	addq.w	#1,d3
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$58(a5)

l_quit:	movem.l	(sp)+,d0-d6/a0-a6
	rts
OctantsN:
	dc.b	1,17,09,21,5,25,13,29
OctantsF:
	dc.b	3,19,11,23,7,27,15,31


waitblit:	
	btst	#14,$dff002
waitbl:	btst	#14,$dff002
	bne.s	waitbl
	rts

clear:	bsr.b	waitblit
	move.l	single(pc),a6
	add.l	#8,a6
	move.l	a6,$dff054
	move.l	#%00000001000000000000000000000000,$dff040
	move.w	#14,$dff066
	move.w	#[510<<6]!13,$dff058
	rts

fill:	move.l	single+4(pc),d0
	add.l	#$27d8*2-8,d0
	bsr.b	waitblit
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#14,$dff064
	move.w	#14,$dff066
	move.w	#[510<<6]!13,$dff058
	rts


setscr:	move.l	single+8(pc),d0
	lea	c11(pc),a1
clop:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$27d8,d0
	dbra	d1,clop
	rts


vx=20

points:
dc.w	-5*vx,-25*vx,5*vx
dc.w	5*vx,-25*vx,5*vx
dc.w	5*vx,-15*vx,5*vx
dc.w	20*vx,-15*vx,5*vx

dc.w	20*vx,-5*vx,5*vx
dc.w	5*vx,-5*vx,5*vx
dc.w	5*vx,25*vx,5*vx
dc.w	-5*vx,25*vx,5*vx

dc.w	-5*vx,-5*vx,5*vx
dc.w	-20*vx,-5*vx,5*vx
dc.w	-20*vx,-15*vx,5*vx
dc.w	-5*vx,-15*vx,5*vx

dc.w	-5*vx,-25*vx,-5*vx
dc.w	5*vx,-25*vx,-5*vx
dc.w	5*vx,-15*vx,-5*vx
dc.w	20*vx,-15*vx,-5*vx

dc.w	20*vx,-5*vx,-5*vx
dc.w	5*vx,-5*vx,-5*vx
dc.w	5*vx,25*vx,-5*vx
dc.w	-5*vx,25*vx,-5*vx

dc.w	-5*vx,-5*vx,-5*vx
dc.w	-20*vx,-5*vx,-5*vx
dc.w	-20*vx,-15*vx,-5*vx
dc.w	-5*vx,-15*vx,-5*vx


pointsend:

pstr:
dc.w	0,1,2,3,4,5,6,7,8,9,10,11

dc.w	-3,0
dc.w	23,22,21,20,19,18,17,16,15,14,13,12

dc.w	-3,1
dc.w	1,0,12,13

dc.w	-4,1
dc.w	3,2,14,15
dc.w	-4,0
dc.w	3,2,14,15

dc.w	-4,1
dc.w	10,11,23,22
dc.w	-4,0
dc.w	10,11,23,22


dc.w	-3,1
dc.w	18,19,7,6

dc.w	-4,1
dc.w	5,4,16,17
dc.w	-4,0
dc.w	5,4,16,17

dc.w	-4,1
dc.w	8,9,21,20
dc.w	-4,0
dc.w	8,9,21,20,8

dc.w	-1,-1,-1,-1,-1,-1
pstrend:

destp:	blk.b	200,0

even

bufor:		dc.w	0
stary:		dc.l	0
alfa:		dc.w	0,0,0,0
dodaj:		dc.w	0,6,3
posx:		dc.l	0
scract:		dc.l	0
single:		dc.l	0,0,0,0
dodp:		dc.l	0,0
y1:		dc.w	0
y2:		dc.w	0
x1:		dc.w	0
x2:		dc.w	0
pointsp:	dc.l	0
pstrp:		dc.l	0
pointsl:	dc.l	0
hide:		dc.l	0
object:		dc.l	-1
bplp:		dc.l	0,$27d8,$27d8*2,$27d8*3

even
copper:
	dc.l	$009683c0

	dc.l	$008e2081,$009028c1
	dc.w	$0108,0,$010A,0

	dc.l	$00920038,$009400d0

	dc.l	$01200000,$01220000
	dc.l	$01240000,$01260000
	dc.l	$01280000,$012a0000
	dc.l	$012c0000,$012e0000
	dc.l	$01300000,$01320000
	dc.l	$01340000,$01360000
	dc.l	$01380000,$013a0000
	dc.l	$013c0000,$013e0000

	dc.l	$01800000
	dc.l	$01820fff,$01840999
	dc.l	$01860555,$01880fff

	dc.l	$3007fffe

c11:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000

	dc.l	$00e80000
	dc.l	$00ea0000

	dc.l	$7007fffe
	dc.l	$01002000

	dc.w	$ffff,$fffe

sinus:
	DC.B	$00,$00,$02,$3B,$04,$77,$06,$B2
	DC.B	$08,$ED,$0B,$27,$0D,$61,$0F,$99
	DC.B	$11,$D0,$14,$05,$16,$39,$18,$6C
	DC.B	$1A,$9C,$1C,$CA,$1E,$F7,$21,$20
	DC.B	$23,$47,$25,$6C,$27,$8D,$29,$AB
	DC.B	$2B,$C6,$2D,$DE,$2F,$F2,$32,$03
	DC.B	$34,$0F,$36,$17,$38,$1C,$3A,$1B
	DC.B	$3C,$17,$3E,$0D,$3F,$FF,$41,$EC
	DC.B	$43,$D3,$45,$B6,$47,$93,$49,$6A
	DC.B	$4B,$3B,$4D,$07,$4E,$CD,$50,$8C
	DC.B	$52,$46,$53,$F9,$55,$A5,$57,$4B
	DC.B	$58,$E9,$5A,$81,$5C,$12,$5D,$9C
	DC.B	$5F,$1E,$60,$99,$62,$0C,$63,$78
	DC.B	$64,$DC,$66,$38,$67,$8D,$68,$D9
	DC.B	$6A,$1D,$6B,$58,$6C,$8B,$6D,$B6
	DC.B	$6E,$D9,$6F,$F2,$71,$03,$72,$0B
	DC.B	$73,$0A,$74,$00,$74,$EE,$75,$D2
	DC.B	$76,$AD,$77,$7E,$78,$46,$79,$05
	DC.B	$79,$BB,$7A,$67,$7B,$09,$7B,$A2
	DC.B	$7C,$31,$7C,$B7,$7D,$32,$7D,$A4
	DC.B	$7E,$0D,$7E,$6B,$7E,$C0,$7F,$0A
	DC.B	$7F,$4B,$7F,$82,$7F,$AF,$7F,$D2
	DC.B	$7F,$EB,$7F,$FA,$7F,$FF,$7F,$FA
	DC.B	$7F,$EB,$7F,$D2,$7F,$AF,$7F,$82
	DC.B	$7F,$4B,$7F,$0A,$7E,$C0,$7E,$6B
	DC.B	$7E,$0D,$7D,$A4,$7D,$32,$7C,$B7
	DC.B	$7C,$31,$7B,$A2,$7B,$09,$7A,$67
	DC.B	$79,$BB,$79,$05,$78,$46,$77,$7E
	DC.B	$76,$AD,$75,$D2,$74,$EE,$74,$00
	DC.B	$73,$0A,$72,$0B,$71,$03,$6F,$F2
	DC.B	$6E,$D9,$6D,$B6,$6C,$8C,$6B,$58
	DC.B	$6A,$1D,$68,$D9,$67,$8D,$66,$38
	DC.B	$64,$DC,$63,$78,$62,$0C,$60,$99
	DC.B	$5F,$1E,$5D,$9C,$5C,$12,$5A,$81
	DC.B	$58,$E9,$57,$4B,$55,$A5,$53,$F9
	DC.B	$52,$46,$50,$8C,$4E,$CD,$4D,$07
	DC.B	$4B,$3B,$49,$6A,$47,$93,$45,$B6
	DC.B	$43,$D3,$41,$EC,$3F,$FF,$3E,$0D
	DC.B	$3C,$17,$3A,$1B,$38,$1C,$36,$17
	DC.B	$34,$0F,$32,$03,$2F,$F2,$2D,$DE
	DC.B	$2B,$C6,$29,$AB,$27,$8D,$25,$6C
	DC.B	$23,$47,$21,$20,$1E,$F7,$1C,$CA
	DC.B	$1A,$9C,$18,$6C,$16,$39,$14,$05
	DC.B	$11,$D0,$0F,$99,$0D,$61,$0B,$27
	DC.B	$08,$ED,$06,$B2,$04,$77,$02,$3B
	DC.B	$00,$00,$FD,$C4,$FB,$88,$F9,$4D
	DC.B	$F7,$12,$F4,$D8,$F2,$9E,$F0,$66
	DC.B	$EE,$2F,$EB,$FA,$E9,$C6,$E7,$93
	DC.B	$E5,$63,$E3,$35,$E1,$08,$DE,$DF
	DC.B	$DC,$B8,$DA,$93,$D8,$72,$D6,$54
	DC.B	$D4,$39,$D2,$21,$D0,$0D,$CD,$FC
	DC.B	$CB,$F0,$C9,$E8,$C7,$E3,$C5,$E4
	DC.B	$C3,$E8,$C1,$F2,$C0,$00,$BE,$13
	DC.B	$BC,$2C,$BA,$49,$B8,$6C,$B6,$95
	DC.B	$B4,$C4,$B2,$F8,$B1,$32,$AF,$73
	DC.B	$AD,$B9,$AC,$06,$AA,$5A,$A8,$B4
	DC.B	$A7,$16,$A5,$7E,$A3,$ED,$A2,$63
	DC.B	$A0,$E1,$9F,$66,$9D,$F3,$9C,$87
	DC.B	$9B,$23,$99,$C7,$98,$72,$97,$26
	DC.B	$95,$E2,$94,$A7,$93,$74,$92,$49
	DC.B	$91,$26,$90,$0D,$8E,$FC,$8D,$F4
	DC.B	$8C,$F5,$8B,$FF,$8B,$11,$8A,$2D
	DC.B	$89,$52,$88,$81,$87,$B9,$86,$FA
	DC.B	$86,$44,$85,$98,$84,$F6,$84,$5D
	DC.B	$83,$CE,$83,$48,$82,$CD,$82,$5B
	DC.B	$81,$F2,$81,$94,$81,$3F,$80,$F5
	DC.B	$80,$B4,$80,$7D,$80,$50,$80,$2D
	DC.B	$80,$14,$80,$05,$80,$00,$80,$05
	DC.B	$80,$14,$80,$2D,$80,$50,$80,$7D
	DC.B	$80,$B4,$80,$F5,$81,$3F,$81,$94
	DC.B	$81,$F2,$82,$5B,$82,$CD,$83,$48
	DC.B	$83,$CE,$84,$5D,$84,$F6,$85,$98
	DC.B	$86,$44,$86,$FA,$87,$B9,$88,$81
	DC.B	$89,$52,$8A,$2D,$8B,$11,$8B,$FE
	DC.B	$8C,$F5,$8D,$F4,$8E,$FC,$90,$0D
	DC.B	$91,$26,$92,$49,$93,$73,$94,$A7
	DC.B	$95,$E2,$97,$26,$98,$72,$99,$C7
	DC.B	$9B,$23,$9C,$87,$9D,$F3,$9F,$66
	DC.B	$A0,$E1,$A2,$63,$A3,$ED,$A5,$7E
	DC.B	$A7,$16,$A8,$B4,$AA,$5A,$AC,$06
	DC.B	$AD,$B9,$AF,$73,$B1,$32,$B2,$F8
	DC.B	$B4,$C4,$B6,$95,$B8,$6C,$BA,$49
	DC.B	$BC,$2C,$BE,$13,$C0,$00,$C1,$F2
	DC.B	$C3,$E8,$C5,$E4,$C7,$E3,$C9,$E8
	DC.B	$CB,$F0,$CD,$FC,$D0,$0D,$D2,$21
	DC.B	$D4,$39,$D6,$54,$D8,$72,$DA,$93
	DC.B	$DC,$B8,$DE,$DF,$E1,$08,$E3,$34
	DC.B	$E5,$63,$E7,$93,$E9,$C6,$EB,$FA
	DC.B	$EE,$2F,$F0,$66,$F2,$9E,$F4,$D8
	DC.B	$F7,$12,$F9,$4D,$FB,$88,$FD,$C4
	DC.B	$00,$00,$02,$3B,$04,$77,$06,$B2
	DC.B	$08,$ED,$0B,$27,$0D,$61,$0F,$99
	DC.B	$11,$D0,$14,$05,$16,$39,$18,$6C
	DC.B	$1A,$9C,$1C,$CA,$1E,$F7,$21,$20
	DC.B	$23,$47,$25,$6C,$27,$8D,$29,$AB
	DC.B	$2B,$C6,$2D,$DE,$2F,$F2,$32,$03
	DC.B	$34,$0F,$36,$17,$38,$1C,$3A,$1B
	DC.B	$3C,$17,$3E,$0D,$3F,$FF,$41,$EC
	DC.B	$43,$D3,$45,$B6,$47,$93,$49,$6A
	DC.B	$4B,$3B,$4D,$07,$4E,$CD,$50,$8C
	DC.B	$52,$46,$53,$F9,$55,$A5,$57,$4B
	DC.B	$58,$E9,$5A,$81,$5C,$12,$5D,$9C
	DC.B	$5F,$1E,$60,$99,$62,$0C,$63,$78
	DC.B	$64,$DC,$66,$38,$67,$8D,$68,$D9
	DC.B	$6A,$1D,$6B,$58,$6C,$8B,$6D,$B6
	DC.B	$6E,$D9,$6F,$F2,$71,$03,$72,$0B
	DC.B	$73,$0A,$74,$00,$74,$EE,$75,$D2
	DC.B	$76,$AD,$77,$7E,$78,$46,$79,$05
	DC.B	$79,$BB,$7A,$67,$7B,$09,$7B,$A2
	DC.B	$7C,$31,$7C,$B7,$7D,$32,$7D,$A4
	DC.B	$7E,$0D,$7E,$6B,$7E,$C0,$7F,$0A
	DC.B	$7F,$4B,$7F,$82,$7F,$AF,$7F,$D2
	DC.B	$7F,$EB,$7F,$FA,$7F,$FF,$7F,$FA
	DC.B	$7F,$EB,$7F,$D2,$7F,$AF,$7F,$82
	DC.B	$7F,$4B,$7F,$0A,$7E,$C0,$7E,$6B
	DC.B	$7E,$0D,$7D,$A4,$7D,$32,$7C,$B7
	DC.B	$7C,$31,$7B,$A2,$7B,$09,$7A,$67
	DC.B	$79,$BB,$79,$05,$78,$46,$77,$7E
	DC.B	$76,$AD,$75,$D2,$74,$EE,$74,$00
	DC.B	$73,$0A,$72,$0B,$71,$03,$6F,$F2
	DC.B	$6E,$D9,$6D,$B6,$6C,$8C,$6B,$58
	DC.B	$6A,$1D,$68,$D9,$67,$8D,$66,$38
	DC.B	$64,$DC,$63,$78,$62,$0C,$60,$99
	DC.B	$5F,$1E,$5D,$9C,$5C,$12,$5A,$81
	DC.B	$58,$E9,$57,$4B,$55,$A5,$53,$F9
	DC.B	$52,$46,$50,$8C,$4E,$CD,$4D,$07
	DC.B	$4B,$3B,$49,$6A,$47,$93,$45,$B6
	DC.B	$43,$D3,$41,$EC,$3F,$FF,$3E,$0D
	DC.B	$3C,$17,$3A,$1B,$38,$1C,$36,$17
	DC.B	$34,$0F,$32,$03,$2F,$F2,$2D,$DE
	DC.B	$2B,$C6,$29,$AB,$27,$8D,$25,$6C
	DC.B	$23,$47,$21,$20,$1E,$F7,$1C,$CA
	DC.B	$1A,$9C,$18,$6C,$16,$39,$14,$05
	DC.B	$11,$D0,$0F,$99,$0D,$61,$0B,$27
	DC.B	$08,$ED,$06,$B2,$04,$77,$02,$3B
	DC.B	$00,$00,$FD,$C4,$FB,$88,$F9,$4D
	DC.B	$F7,$12,$F4,$D8,$F2,$9E,$F0,$66
	DC.B	$EE,$2F,$EB,$FA,$E9,$C6,$E7,$93
	DC.B	$E5,$63,$E3,$35,$E1,$08,$DE,$DF
	DC.B	$DC,$B8,$DA,$93,$D8,$72,$D6,$54
	DC.B	$D4,$39,$D2,$21,$D0,$0D,$CD,$FC
	DC.B	$CB,$F0,$C9,$E8,$C7,$E3,$C5,$E4
	DC.B	$C3,$E8,$C1,$F2,$C0,$00,$BE,$13
	DC.B	$BC,$2C,$BA,$49,$B8,$6C,$B6,$95
	DC.B	$B4,$C4,$B2,$F8,$B1,$32,$AF,$73
	DC.B	$AD,$B9,$AC,$06,$AA,$5A,$A8,$B4
	DC.B	$A7,$16,$A5,$7E,$A3,$ED,$A2,$63
	DC.B	$A0,$E1,$9F,$66,$9D,$F3,$9C,$87
	DC.B	$9B,$23,$99,$C7,$98,$72,$97,$26
	DC.B	$95,$E2,$94,$A7,$93,$74,$92,$49
	DC.B	$91,$26,$90,$0D,$8E,$FC,$8D,$F4
	DC.B	$8C,$F5,$8B,$FF,$8B,$11,$8A,$2D
	DC.B	$89,$52,$88,$81,$87,$B9,$86,$FA
	DC.B	$86,$44,$85,$98,$84,$F6,$84,$5D
	DC.B	$83,$CE,$83,$48,$82,$CD,$82,$5B
	DC.B	$81,$F2,$81,$94,$81,$3F,$80,$F5
	DC.B	$80,$B4,$80,$7D,$80,$50,$80,$2D
	DC.B	$80,$14,$80,$05,$80,$00,$80,$05
	DC.B	$80,$14,$80,$2D,$80,$50,$80,$7D
	DC.B	$80,$B4,$80,$F5,$81,$3F,$81,$94
	DC.B	$81,$F2,$82,$5B,$82,$CD,$83,$48
	DC.B	$83,$CE,$84,$5D,$84,$F6,$85,$98
	DC.B	$86,$44,$86,$FA,$87,$B9,$88,$81
	DC.B	$89,$52,$8A,$2D,$8B,$11,$8B,$FE
	DC.B	$8C,$F5,$8D,$F4,$8E,$FC,$90,$0D
	DC.B	$91,$26,$92,$49,$93,$73,$94,$A7
	DC.B	$95,$E2,$97,$26,$98,$72,$99,$C7
	DC.B	$9B,$23,$9C,$87,$9D,$F3,$9F,$66
	DC.B	$A0,$E1,$A2,$63,$A3,$ED,$A5,$7E
	DC.B	$A7,$16,$A8,$B4,$AA,$5A,$AC,$06
	DC.B	$AD,$B9,$AF,$73,$B1,$32,$B2,$F8
	DC.B	$B4,$C4,$B6,$95,$B8,$6C,$BA,$49
	DC.B	$BC,$2C,$BE,$13,$C0,$00,$C1,$F2
	DC.B	$C3,$E8,$C5,$E4,$C7,$E3,$C9,$E8
	DC.B	$CB,$F0,$CD,$FC,$D0,$0D,$D2,$21
	DC.B	$D4,$39,$D6,$54,$D8,$72,$DA,$93
	DC.B	$DC,$B8,$DE,$DF,$E1,$08,$E3,$34
	DC.B	$E5,$63,$E7,$93,$E9,$C6,$EB,$FA
	DC.B	$EE,$2F,$F0,$66,$F2,$9E,$F4,$D8
	DC.B	$F7,$12,$F9,$4D,$FB,$88,$FD,$C4

mul40:	blk.w	256,0	

screen:	blk.b	$4fb0*3,0
	blk.b	$4fb0,0

