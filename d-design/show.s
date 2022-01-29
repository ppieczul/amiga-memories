

	lea	bufor(pc),a0
	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a

	bsr	run
	bsr	run2
	bsr	run3

	move.w	bufor(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	rts

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


run:	lea	screen1,a0
	move.l	a0,d0

	lea	c11,a1
	moveq	#4,d7
setc:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$11a8,d0
	dbra	d7,Setc

	lea	copper(pc),a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	move.l	#10,d7

Show:	move.l	d7,d6
wq1:	waitframe
	dbra	d6,wq1

	move.w	#$5000,Scr
	waitframe
	move.w	#0,Scr
	dbra	d7,Show
	move.w	#$5000,Scr

	moveq	#50,d7
wq2:	waitframe
	dbra	d7,wq2
	
	move.l	#0,d7

Show2:	move.l	d7,d6
wq3:	waitframe
	dbra	d6,wq3

	move.w	#$5000,Scr
	waitframe
	move.w	#$0,Scr
	addq.l	#1,d7
	cmp.l	#10,d7
	bne	Show2
	move.w	#$0,Scr
	rts



run2:	lea	screen2,a0
	move.l	a0,d0
	addq.l	#2,d0
	lea	c12,a1
	moveq	#1,d7
setc2:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$578,d0
	dbra	d7,Setc2

	lea	Make2,a0
	move.b	#$99,d7
make2p:	move.l	#$01020000,(a0)+
	move.b	d7,(a0)+
	move.b	#7,(a0)+
	move.w	#$fffe,(a0)+
	addq.b	#1,d7
	cmp.b	#$bc,d7
	bne.b	Make2p

	lea	copper2,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	moveq	#0,d0
	move.l	#400,d6

upper:	waitframe

	moveq	#34,d7

	lea	Sin2,a0
	lea	Make2+2,a1
	add.l	d0,a0

Wav2:	move.w	(a0)+,d5
	asl.w	#4,d5
	move.w	d5,(a1)
	addq.l	#8,a1
	dbra	d7,Wav2
	addq.l	#2,d0
	cmp.l	#60*2,d0
	bne.b	No60
	moveq	#0,d0

No60:	cmp.l	#350,d6
	ble.b	MUp
	cmp.b	#$98,Up
	beq.b	MUp
	subq.b	#1,Up
MUp:
	cmp.l	#35,d6
	bge.b	NDn
	cmp.b	#$bb,Up
	beq.b	NDn
	addq.b	#1,Up
NDn:
	dbra	d6,Upper
	rts


run3:	lea	screen3,a0
	move.l	a0,d0
	lea	c13,a1
	moveq	#4,d7
setc3:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$2120,d0
	dbra	d7,Setc3

	lea	copper3,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	move.l	#500,d6

Part3:	waitframe

	move.w	Pal-2+31*4,d0
	lea	Pal-2+30*4,a0

	moveq	#29,d5
RotC:	move.w	(a0),4(a0)
	subq.l	#4,a0
	dbra	d5,RotC
	move.w	d0,Pal+2

	dbra	d6,PArt3
	rts


bufor:		dc.w	0


copper:	dc.l	$009683e0,$00960020

	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000,$01020000
	dc.l	$00920038,$009400d0,$01000000

c01:	dc.w $0180,$0000,$0182,$0fff,$0184,$0dee,$0186,$0bdd
	dc.w $0188,$09cc,$018a,$08bb,$018c,$06aa,$018e,$0599
	dc.w $0190,$0488,$0192,$0377,$0194,$0266,$0196,$0155
	dc.w $0198,$0144,$019a,$0033,$019c,$0022,$019e,$0011
	dc.w $01a0,$0101,$01a2,$0202,$01a4,$0302,$01a6,$0403
	dc.w $01a8,$0504,$01aa,$0604,$01ac,$0704,$01ae,$0804
	dc.w $01b0,$0804,$01b2,$0904,$01b4,$0a03,$01b6,$0b03
	dc.w $01b8,$0c03,$01ba,$0d02,$01bc,$0e01,$01be,$0f00

c11:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

	dc.l	$7a07fffe
	dc.w	$0100
Scr:	dc.w	0
	dc.l	$eb07fffe,$01000000
	dc.l	$fffffffe


copper2:
	dc.l	$009683e0,$00960020

	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000
	dc.l	$00920038,$009400d0,$01000000

c02:	dc.l	$01800000,$01820fff,$01840f00,$01860fff

c12:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000

	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

up:	dc.l	$bb07fffe
	dc.l	$01002000

make2:	ds.l	2*35

	dc.l	$bb07fffe,$01000000
	dc.l	$fffffffe


copper3:
	dc.l	$009683e0,$00960020

	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000,$01020000
	dc.l	$00920038,$009400d0,$01000000

pal=*+4
c03:	dc.w $0180,$0000,$0182,$0bdd,$0184,$0d02,$0186,$0fff
	dc.w $0188,$0d80,$018a,$0fe0,$018c,$08f0,$018e,$0080
	dc.w $0190,$00b6,$0192,$00dd,$0194,$00af,$0196,$007c
	dc.w $0198,$000f,$019a,$070f,$019c,$0c0e,$019e,$0c08
	dc.w $01a0,$0620,$01a2,$0e52,$01a4,$0a52,$01a6,$0fca
	dc.w $01a8,$0333,$01aa,$0444,$01ac,$0555,$01ae,$0666
	dc.w $01b0,$0777,$01b2,$0888,$01b4,$0999,$01b6,$0aaa
	dc.w $01b8,$0ccc,$01ba,$0ddd,$01bc,$0eee,$01be,$0fff


c13:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000

	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

	dc.l	$4007fffe
	dc.l	$01005000

	dc.l	$ffddfffe
	dc.l	$1407fffe,$01000000
	dc.l	$fffffffe

Sin2:
	DC.W	$0007,$0008,$0009,$000A,$000A,$000B,$000B,$000C,$000C,$000D
	DC.W	$000D,$000E,$000E,$000E,$000E,$000E,$000E,$000E,$000E,$000D
	DC.W	$000D,$000C,$000C,$000B,$000B,$000A,$000A,$0009,$0008,$0007
	DC.W	$0007,$0006,$0005,$0004,$0004,$0003,$0003,$0002,$0002,$0001
	DC.W	$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	DC.W	$0001,$0002,$0002,$0003,$0003,$0004,$0004,$0005,$0006,$0007
	DC.W	$0007,$0008,$0009,$000A,$000A,$000B,$000B,$000C,$000C,$000D
	DC.W	$000D,$000E,$000E,$000E,$000E,$000E,$000E,$000E,$000E,$000D
	DC.W	$000D,$000C,$000C,$000B,$000B,$000A,$000A,$0009,$0008,$0007
	DC.W	$0007,$0006,$0005,$0004,$0004,$0003,$0003,$0002,$0002,$0001
	DC.W	$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	DC.W	$0001,$0002,$0002,$0003,$0003,$0004,$0004,$0005,$0006,$0007


screen1:
	incbin	dachaos.iff
screen2:
	incbin	presentatos.iff
	dc.l	0
screen3:
	incbin	muertos.iff

