run:	lea	pstr,a0
	moveq	#[pstrend-pstr]/2-1,d7
stilp:	move.w	(a0)+,d0
	bmi.b	stil
	asl.w	#2,d0
	move.w	d0,-2(a0)
stil:	dbra	d7,stilp

	lea	mul40,a0
	moveq	#0,d0
lopklop:move.l	d0,d1
	mulu	#40,d1
	move.w	d1,(a0)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.b	lopklop

	lea	single,a1
	lea	screen,a0
	move.l	a0,(a1)
	add.l	#$1900*3,a0
	move.l	a0,4(a1)
	add.l	#$1900*3,a0
	move.l	a0,8(a1)
	add.l	#$1900*3,a0
	move.l	a0,12(a1)

	lea	Pic1,a0
	move.l	a0,d0
	lea	c10,a1
	moveq	#2,d1
clop2:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$4d8,d0
	dbra	d1,clop2

	lea	Pic2,a0
	move.l	a0,d0
	lea	c20,a1
	moveq	#2,d1
clop3:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$a28,d0
	dbra	d1,clop3

	moveq	#2,d1
	bsr.w	setscr
	move.l	single+12,a0
	

	lea	bufor,a0
	lea	stary,a1
	lea	vblk,a2
	lea	next,a3

	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a
	move.l	$6c,(a1)
	move.l	a2,$6c
	move.l	stary,$02(a3)
	
	move.w	(a0),d0
	or.w	#$8020,d0
	move.w	d0,$dff09a

	lea	copper,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

mysz:	btst	#6,$bfe001
	bne.s	mysz
	
quit:  	move.w	#$7fff,$dff09a
	move.l	stary,$6c
	move.w	bufor,d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	rts


vblk:	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$dff01e,d0
	and.w	#$0020,d0
	bne.s	okey
	bra.s	exit2
exit1:
;	move.w	#$8,$dff180
	move.w	#$0020,$dff09c
exit2:	movem.l	(sp)+,d0-d7/a0-a6
next:	jmp	0.l

okey:	lea	single,a0
	movem.l	(a0),d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,(a0)

	moveq	#2,d1
	bsr.w	setscr

	bsr.w	clear

	lea	PreAlfa,a0
	lea	destp,a4
	lea	points,a5
	move.l	#[pointsend-points]/6-1,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

	lea	sinus,a6

	move.w	alfa,d2
	add.w	d2,d2
	move.w	(a6,d2.w),2(a0)
	add.w	#180,a6
	move.w	(a6,d2.w),(a0)

	move.w	alfa+2,d2
	add.w	d2,d2
	move.w	(a6,d2.w),6(a0)
	add.w	#180,a6
	move.w	(a6,d2.w),4(a0)

	move.w	alfa+4,d2
	add.w	d2,d2
	move.w	(a6,d2.w),10(a0)
	add.w	#180,a6
	move.w	(a6,d2.w),8(a0)

cpr2:	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5


	exg	d0,d5
	add.w	d0,d0
	move.w	d0,d2

	add.w	d5,d5
	move.w	d5,d3

	muls.w	(a0),d0
	swap	d0
	muls.w	2(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	2(a0),d2
	swap	d2
	muls.w	(a0),d5
	swap	d5
	add.w	d2,d5
	exg	d0,d5

	add.w	d5,d5
	move.w	d5,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	4(a0),d5
	swap	d5
	muls.w	6(a0),d3
	swap	d3
	sub.w	d3,d5
	muls.w	6(a0),d2
	swap	d2
	muls.w	4(a0),d1
	swap	d1
	add.w	d2,d1

	add.w	d0,d0
	move.w	d0,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	8(a0),d0
	swap	d0
	muls.w	10(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	10(a0),d2
	swap	d2
	muls.w	8(a0),d1
	swap	d1
	add.w	d2,d1

lefty:	;move.l	#$2000,d3
	sub.l	#vx*2*40,d5
	asl.l	#3,d5
	move.l	d5,d3
	muls.w	d3,d0
	muls.w	d3,d1
	swap	d0
	swap	d1

	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2

	bsr.w	fill

	lea	dodp,a1
	lea	bplp,a2
	move.l	single,a3
	lea	destp,a4
	move.l	a3,a5
	lea	pstr,a6

	move.w	(a6)+,d0

	move.w	d0,(a1)
	move.w	d0,2(a1)

rept:	move.w	(a1),d3

	move.w	(a6),d4
	move.w	2(a6),d5

	move.w	(a4,d3.w),d0
	sub.w	(a4,d4.w),d0
	move.w	2(a4,d5.w),d1
	sub.w	2(a4,d4.w),d1
	mulu.w	d1,d0
	move.w	(a4,d4.w),d1
	sub.w	(a4,d5.w),d1
	move.w	2(a4,d4.w),d2
	sub.w	2(a4,d3.w),d2
	mulu.w	d2,d1

	cmp.w	d1,d0
	bpl.b	Pluk

wait:	move.w	(a6)+,d0
	bpl.b	wait	
	cmp.w	#-4,d0
	beq.b	wait
	subq.l	#2,a6
	bra.b	Pluk

rept2:	move.w	(a1),d1
	move.w	d6,(a1)

	move.w	(a4,d1.w),d2
	move.w	2(a4,d1.w),d3
	move.w	2(a4,d6.w),d1
	move.w	(a4,d6.w),d0
	bsr.w	line

Pluk:	move.w	(a6)+,d6
	bpl.b	Rept2

	cmp.b	#-1,d6
	beq.b	quity

	move.l	a5,d7
	move.w	(a6)+,d0
	add.l	(a2,d0.w),d7

	move.l	(a1),d0

	move.w	(a4,d0.w),d2
	move.w	2(a4,d0.w),d3
	swap	d0
	move.w	2(a4,d0.w),d1
	move.w	(a4,d0.w),d0
	bsr.w	line

	move.w	(a6),(a1)
	move.w	(a6)+,2(a1)
	move.l	d7,a3
	cmp.b	#-4,d6
	beq.b	pluk
	bra.w	rept

quity:

	lea	alfa,a0
	lea	dodaj,a1

	moveq	#2,d0
addlv2:	move.w	(a1),d1
	add.w	d1,(a0)
	cmp.w	#360,(a0)
	blt.b	nookr2
	sub.w	#360,(a0)
nookr2:	tst.w	(a0)
	bge.b	nookr3
	add.w	#360,(a0)
nookr3:	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,addlv2

	lea	Msin,a0
	move.l	SinPos,d0
	move.l	Addz,d1
	add.l	d1,d1
	add.l	d1,SinPos

	cmp.l	#MEndSin-Msin,SinPos
	blt.b	NME
	sub.l	#MEndSin-Msin,SinPos
	clr.l	sinpos
NME:	add.l	d0,a0
	move.w	(a0),d0

	move.w	d0,Points+4
	move.w	d0,Points+4+6
	move.w	d0,Points+4+12
	move.w	d0,Points+4+18

	add.w	#25*vx,d0

	move.w	d0,Points+4+24
	move.w	d0,Points+4+30
	move.w	d0,Points+4+36
	move.w	d0,Points+4+42

	subq.w	#1,Timer
	bgt.b	NoSCH

	lea	Script,a0
	move.l	ScriptPos,d0
	add.l	#10,ScriptPos
	cmp.l	#ScriptEnd-Script,ScriptPos
	blt.b	NoSE
;	move.l	#Script2-Script,ScriptPos
	clr.l	scriptpos
NoSE:	add.l	d0,a0
	move.w	(a0)+,Timer
	move.l	(a0)+,Dodaj
	move.w	(a0)+,Dodaj+4
	move.w	(a0)+,Addz+2
NoSCH:

	bra.w	exit1

line:	movem.l	d0-d6/a0-a6,-(sp)

	add.w	#160,d0
	add.w	#160,d2
	add.w	#110,d1
	add.w	#110,d3


	lea	mul40,a1
	lea	$dff000,a5

	cmp.w	d3,d1
	beq.w	l_quit
	bhi.b	l_noych

	exg.l	d1,d3
	exg.l	d0,d2

l_noych:subq.w	#1,d1

	moveq	#0,d4
	move.w	d1,d4
	add.w	d4,d4

	move.w	(a1,d4.w),d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a3,d4

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
	move.l	single,a6
	addq.l	#4,a6
	move.l	a6,$dff054
	move.l	#$01000000,$dff040
	move.w	#10,$dff066
	move.w	#[480<<6]!15,$dff058
	rts

fill:	move.l	single+4,d0
	add.l	#$1900*3-6,d0
	bsr.b	waitblit
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#10,$dff064
	move.w	#10,$dff066
	move.w	#[480<<6]!15,$dff058
	rts


setscr:
	move.l	single+8,d0
	add.l	#48*40,d0
	lea	c11,a1
clop:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1900,d0
	dbra	d1,clop
	rts


vx=15
yx=15

points:

dc.w	-05*vx,+05*yx,+00*vx
dc.w	+05*vx,+05*yx,+00*vx
dc.w	+05*vx,-05*yx,+00*vx
dc.w	-05*vx,-05*yx,+00*vx
dc.w	-05*vx,+05*yx,+36*vx
dc.w	+05*vx,+05*yx,+36*vx
dc.w	+05*vx,-05*yx,+36*vx
dc.w	-05*vx,-05*yx,+36*vx

dc.w	-10*vx,+10*yx,+00*vx
dc.w	+10*vx,+10*yx,+00*vx
dc.w	+10*vx,-10*yx,+00*vx
dc.w	-10*vx,-10*yx,+00*vx

dc.w	-15*vx,+15*yx,+00*vx
dc.w	+15*vx,+15*yx,+00*vx
dc.w	+15*vx,-15*yx,+00*vx
dc.w	-15*vx,-15*yx,+00*vx
pointsend:

pstr:
dc.w	0,1,2,3
dc.w	-4,1
dc.w	0,1,2,3
dc.w	-3,0
dc.w	7,6,5,4
dc.w	-4,1
dc.w	7,6,5,4
dc.w	-3,1
dc.w	4,5,1,0
dc.w	-3,1
dc.w	6,7,3,2

dc.w	-3,0
dc.w	5,6,2,1
dc.w	-3,0
dc.w	0,3,7,4

dc.w	-3,2
dc.w	8,9,10,11

dc.w	-3,2
dc.w	11,10,9,8

dc.w	-3,2
dc.w	12,13,14,15

dc.w	-3,2
dc.w	15,14,13,12,15

dc.w	-1,-1,-1,-1,-1,-1
pstrend:

destp:	blk.b	200,0

even

bufor:		dc.w	0
stary:		dc.l	0
alfa:		dc.w	0,0,0,0
dodaj:		dc.w	0,6,0
posx:		dc.l	0
scract:		dc.l	0
single:		dc.l	0,0,0,0
dodp:		dc.l	0,0
pointsp:	dc.l	0
pstrp:		dc.l	0
pointsl:	dc.l	0
addz:		dc.l	0
object:		dc.l	-1
bplp:		dc.l	0,$1900,$1900*2,$1900*3
prealfa:	dc.l	0,0,0,0,0,0,0,0
SinPos:		dc.l	0
timer:		dc.l	0
scriptpos:	dc.l	0

Msin:	DC.W	$002D,$003C,$004B,$005A,$0069,$0069,$0078,$0087,$0096,$0096
	DC.W	$00A5,$00A5,$00B4,$00B4,$00B4,$00B4,$00B4,$00B4,$00A5,$00A5
	DC.W	$0096,$0096,$0087,$0078,$0069,$0069,$005A,$004B,$003C,$002D
	DC.W	$000F,$0000,$FFF1,$FFE2,$FFD3,$FFD3,$FFC4,$FFB5,$FFA6,$FFA6
	DC.W	$FF97,$FF97,$FF88,$FF88,$FF88,$FF88,$FF88,$FF88,$FF97,$FF97
	DC.W	$FFA6,$FFA6,$FFB5,$FFC4,$FFD3,$FFD3,$FFE2,$FFF1,$0000,$000F
Mendsin:


script:
	dc.w	90,0,0,0,1
	dc.w	21,0,4,0,1
	dc.w	90,0,0,0,1
	dc.w	25,4,0,0,1
	dc.w	90,0,0,0,1
	dc.w	90,-4,0,0,1
	dc.w	90,3,2,1,1
	dc.w	90,4,3,4,1
	dc.w	90,3,5,4,2
	dc.w	90,5,4,6,3
	dc.w	90,6,8,3,4
	dc.w	180,8,4,6,4
	dc.w	180,4,10,6,4
	dc.w	180,7,13,11,5
	dc.w	90,0,0,0,5
	dc.w	45,4,0,0,5
	dc.w	90,0,0,0,5
	dc.w	44,0,4,0,5
	dc.w	90,0,0,0,5
	dc.w	20,0,0,0,6
	dc.w	20,0,0,0,7
	dc.w	20,0,0,0,8
	dc.w	20,0,0,0,9
	dc.w	20,0,0,0,10
	dc.w	20,0,0,0,11
	dc.w	20,0,0,0,12
	dc.w	20,0,0,0,13
	dc.w	20,0,0,0,14
	dc.w	20,0,0,0,15
	dc.w	500,20,15,12,15

scriptend:

even

copper:	dc.l	$009683c0,$01000000

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

	dc.w $0180,$0000,$0182,$0404,$0184,$0505,$0186,$0707
	dc.w $0188,$0909,$018a,$0b0b,$018c,$0d0d,$018e,$0f0f

	dc.l	$4107fffe
c10:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000

	dc.l	$01003000
	dc.l	$6007fffe,$01000000

	dc.w $0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000

;	dc.l	$fffffffe

	dc.l	$6c07fffe

c11:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000

	dc.l	$00e80000
	dc.l	$00ea0000

	dc.l	$6d07fffe
	dc.l	$01003000

	dc.l	$6e07fffe

	dc.l	$0180000f
	dc.l	$0182000f,$0184000f
	dc.l	$0186000f
	dc.l	$0188000f
	dc.l	$018a000f,$018c000f
	dc.l	$018e000f

	dc.l	$6f07fffe
	dc.l	$01800000
	dc.l	$01820fff,$01840ccc
	dc.l	$01860999
	dc.l	$01880444
	dc.l	$018a0999,$018c0888
	dc.l	$018e0666

	dc.l	$e707fffe
	dc.l	$0180000f
	dc.l	$0182000f,$0184000f
	dc.l	$0186000f
	dc.l	$0188000f
	dc.l	$018a000f,$018c000f
	dc.l	$018e000f

	dc.l	$e807fffe
	dc.l	$01800000
	dc.l	$01820000,$01840000
	dc.l	$01860000
	dc.l	$01880000
	dc.l	$018a0000,$018c0000
	dc.l	$018e0000

	dc.l	$e907fffe
c20:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000

	dc.l	$01800000
	dc.l	$01820fff,$01840ccc
	dc.l	$01860999
	dc.l	$01880444
	dc.l	$018a0999,$018c0888
	dc.l	$018e0666

	dc.l	$01003000
	dc.l	$ffddfffe,$4007fffe,$01000000
	dc.l	-2

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

	incdir	df0:
pic1:	incbin	anal.iff
pic2:	incbin	info.iff

screen:	blk.b	$4b00*4,0



