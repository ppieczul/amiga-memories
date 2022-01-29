SECTION	code,code_c

ScrSzer	=40
ScrWys	=150
bpllen	=ScrSzer*ScrWys

	incdir	df0:incl/
	incdir	ram:

waitblit:macro
	btst	#14,$dff002
	bne.b	*-8
	EndM

	bra.w	run
vblk:	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$dff01e,d0
	and.w	#$0020,d0
	bne.s	okey
	bra.s	exit2

exit1:	move.w	#$0020,$dff09c
exit2:	movem.l	(sp)+,d0-d7/a0-a6
next_vbl_adr:
	jmp	0.l

okey:	move.l	mode(pc),d0
	add.l	d0,d0
	add.l	d0,d0
	jsr	jump_t(pc,d0.l)

	bsr.w	set_mouse_pos
	bra.b	exit1

jump_t:	bra.w	direct_mode
	bra.w	take_mode
	bra.w	use_mode
	bra.w	speak_mode
	bra.w	fight_mode
	bra.w	look_mode



direct_mode:
	bsr	left_button
	tst.b	d0
	beq.b	dm_nobut
	cmp.b	#1,d0
	bne.b	dm_nopres
	lea	main_gadgets(pc),a6
	bsr.w	mouse_zone
	lea	dm_tmp(pc),a5
	move.b	d0,(a5)
	tst.w	d0
	bmi.b	dm_nobut
	moveq	#-1,d6
	bsr.w	half_rec

	bra.b	dm_nobut
dm_nopres:
	lea	dm_tmp(pc),a6
	cmp.b	#-1,(a6)
	beq.b	dm_nobut
	clr.l	d0
	move.b	(a6),d0
	lea	main_gadgets(pc),a6
	moveq	#0,d6
	bsr.w	half_rec
	add.l	d0,d0
	add.l	d0,d0
	lea	main_gadgets_j(pc),a5
	lea	mode(pc),a6
	jsr	(a5,d0.l)
dm_nobut:
	rts
dm_tmp:	dc.l	0,0



take_mode:
	bsr.w	check_undo
	rts
use_mode:
	bsr.w	check_undo
	rts
speak_mode:
	bsr.w	check_undo
	rts
fight_mode:
	bsr.w	check_undo
	rts
look_mode:
	bsr.w	check_undo
	rts



set_take_mode:
	move.l	#1,(a6)
	moveq	#3,d0
	moveq	#0,d1
	bsr.w	set_sprite
	rts
set_use_mode:
	move.l	#2,(a6)
	moveq	#3,d0
	moveq	#0,d1
	bsr.w	set_sprite
	rts
set_speak_mode:
	move.l	#3,(a6)
	moveq	#2,d0
	moveq	#0,d1
	bsr.w	set_sprite
	rts
set_fight_mode:
	move.l	#4,(a6)
	moveq	#1,d0
	moveq	#0,d1
	bsr.w	set_sprite
	rts
set_look_mode:
	move.l	#5,(a6)
	moveq	#0,d0
	moveq	#0,d1
	bsr.w	set_sprite
	rts



left_button:
	lea	lb_tmp(pc),a6
	btst	#6,$bfe001
	bne.b	lb_not
	tst.b	(a6)
	beq.b	lb_1
	moveq	#0,d0
	rts
lb_1:	move.b	#-1,(a6)
	moveq	#1,d0
	rts
lb_not:	tst.b	(a6)
	bne.b	lb_set
	move.b	#0,(a6)
	rts	
lb_set:	moveq	#-1,d0
	move.b	#0,(a6)
	rts
lb_tmp:	dc.l	0




check_undo:
	btst	#10,$dff016
	bne.b	cu_nobut
	move.l	a6,-(sp)
	lea	mode(pc),a6
	move.l	#0,(a6)
	moveq	#4,d0
	moveq	#0,d1
	bsr.w	set_sprite
	move.l	(sp)+,a6
cu_nobut:
	rts



mouse_zone:
	movem.l	d1-d6/a6,-(sp)
	movem.l	reg_clear(pc),d0-d6
	move.b	mouse_pos+2(pc),d2
	move.b	mouse_pos+3(pc),d1
	add.w	d1,d1
	sub.w	#134,d1
	sub.w	#44,d2
mz_loop:move.w	(a6)+,d3
	move.w	(a6)+,d4	
	move.w	(a6)+,d5
	move.w	(a6)+,d6
	cmp.w	#-1,d3
	bne.b	mz_cont
	moveq	#-1,d0
	bra.b	mz_out
mz_cont:cmp.w	d1,d3
	bge.b	mz_next		;x gadgetu>x myszy
	cmp.w	d2,d4
	bge.b	mz_next		;y gadgetu>y myszy
	cmp.w	d1,d5
	ble.b	mz_next		;x1 gad<x myszy
	cmp.w	d2,d6
	ble.b	mz_next		;y1 gad<y myszy
	bra.b	mz_out
mz_next:addq.l	#1,d0
	bra.b	mz_loop
mz_out:	movem.l	(sp)+,d1-d6/a6
	rts
	


set_mouse_pos:
	movem.l	d0-d2/a6,-(sp)
	lea	mouse_pos(pc),a6
	move.w	(a6),d0
	cmp.w	$dff00a,d0
	beq.b	smp_ret
	clr.w	d0
	clr.w	d1
	clr.w	d2
	move.b	$dff00a,d0
	move.b	$dff00b,d1
	move.b	(a6),d2
	sub.b	d0,d2
	beq.b	smp_n1
	bpl.b	smp_pl1
	neg.b	d2
	and.b	#$f,d2
	neg.b	d2
	bra.b	smp_pl2
smp_pl1:and.b	#$f,d2
smp_pl2:sub.b	d2,2(a6)
	move.b	d0,(a6)
	move.b	2(a6),d2
	cmp.w	#$ef,d2
	bmi.b	smp_gt1
	move.b	#$ef,2(a6)
smp_gt1:cmp.w	#$40,d2
	bpl.b	smp_n1
	move.b	#$40,2(a6)
smp_n1:	move.b	1(a6),d2
	sub.b	d1,d2
	beq.b	smp_n2
	sub.b	d2,3(a6)
	move.b	d1,1(a6)
smp_n2:	move.w	2(a6),d0
	moveq	#0,d1
	bsr.b	set_sprite_pos
smp_ret:movem.l	(sp)+,d0-d2/a6
	rts
mouse_pos:	dc.w	0
		dc.w	0,0



set_sprite:
	movem.l	a5-a6/d7,-(sp)
	lea	sprite_data+4(pc),a5
	lea	sprite_bank(pc),a6
	asl.l	#6,d0
	add.l	d0,a6
	asl.l	#7,d1
	add.l	d1,a5
	moveq	#15,d7
set_sprite_loop:
	move.l	(a6)+,(a5)+
	dbra	d7,set_sprite_loop
	movem.l	(sp)+,a5-a6/d7
	rts



set_sprite_pos:
	move.l	a5,-(sp)
	lea	sprite_data(pc),a5
	asl.l	#7,d1
	add.l	d1,a5
	move.w	d0,(a5)
	move.w	d0,68(a5)
	and.w	#$ff00,d0
	add.w	#$1000,d0
	move.w	d0,2(a5)
	move.w	d0,70(a5)
	move.l	(sp)+,a5
	rts



half_rec:
	movem.l	d0-d6/a6,-(sp)
	movem.l	reg_clear(pc),d1-d3
	asl.l	#3,d0
	move.w	6(a6,d0.l),d3
	move.w	4(a6,d0.l),d2
	move.w	2(a6,d0.l),d1
	move.w	0(a6,d0.l),d0
	sub.l	d1,d3
	addq.l	#7,d0
	subq.l	#3,d2
	move.l	d0,-(sp)
	and.l	#7,d0
	subq.b	#7,d0
	neg.b	d0
	move.l	#128,d4
	asr.b	d0,d4
	subq.b	#7,d0
	neg.b	d0
	asr.w	d0,d4
	move.l	(sp),d0
	asr.l	#3,d0
	add.l	#$c800,d0
	add.l	scr_ptr(pc),d0
	mulu	#40,d1
	add.l	d1,d0
	move.l	d0,a6
	move.l	d2,-(sp)
	and.l	#7,d2
	move.l	#128,d5
	asr.b	d2,d5
	move.l	(sp)+,d2
	move.l	(sp)+,d0
	asr.l	#3,d0
	asr.l	#3,d2
	sub.l	d0,d2
	move.l	d2,d1
	tst.b	d6
	bne.b	hr_kp
	clr.l	d4
	clr.l	d5
hr_kp:	move.b	d4,(a6)+
hr_lp:	move.b	d6,(a6)+
	subq.l	#1,d2
	bne.b	hr_lp
	move.b	d5,(a6)+
	add.l	#38,a6
	sub.l	d1,a6
	move.l	d1,d2
	dbra	d3,hr_kp
	movem.l	(sp)+,d0-d6/a6
	rts

MoveRoomToScreen:

;a1-roombcg

	movem.l	d0-a6,-(sp)
	lea	Colors,a0

	move.w	(a1)+,d0

	moveq	#31,d7
MvCLrS:	move.w	(a1)+,2(a0)
	addq.l	#4,a0
	dbra	d7,MvCLrS

	lea	screen,a0
	waitblit
	move.l	#-1,$dff044
	move.l	#$09f00000,$dff040
	move.l	a1,$dff050
	move.l	a0,$dff054
	move.l	#0,$dff064
	move.w	d0,d1
	asr.w	#1,d1
	and.w	#%111111,d1
	or.w	#(150*5)<<6,d1
	move.w	d1,$dff058

	moveq	#ScrSzer,d1
	sub.w	d0,d1
	lea	CopperModulos,a0
	move.w	d1,2(a0)
	move.w	d1,6(a0)

	movem.l	(sp)+,d0-a6
	rts

PutItemToScreen:
	movem.l	d0-a6,-(sp)

	asl.l	#4,d2
	lea	ItemDatas,a0
	lea	ItemShapes,a1
	lea	ItemOutlines,a2


	add.l	d2,a0
	add.l	8(a0),a1	;a1-adres przedm

	move.w	CopperModulos+2,d3	;d3-modulo dla blitu
	add.w	#ScrSzer-2,d3
	sub.w	(a0),d3

	move.w	2(a0),d4
	asl.w	#6,d4
	move.w	(a0),d5
	asr.w	#1,d5
	addq.w	#1,d5
	or.w	d5,d4		;d4-bltsize

	add.l	12(a0),a2	;a2-adres maski

	move.l	Scr_Ptr(pc),a3	;a3-adres ekranu
	move.w	d0,d5
	asr.w	#4,d5
	lea	(a3,d5.w),a3
	move.w	d1,d5
	mulu.w	#ScrSzer,d5
	lea	(a3,d5.w),a3

	and.w	#$f,d0
	move.w	d0,d5
	asl.w	#2,d0
	asl.w	#8,d5
	asl.w	#4,d5

	waitblit
	move.w	d3,$dff060
	move.w	d3,$dff066
	move.w	#-2,$dff062
	move.w	#-2,$dff064
	move.l	#$ffff0000,$dff044

	move.w	d5,$dff042
	or.w	#$0fe2,d5
	move.w	d5,$dff040

	moveq	#4,d7
MvItmToSc:
	waitblit

	move.l	a2,$dff04c
	move.l	a1,$dff050
	move.l	a3,$dff048
	move.l	a3,$dff054
	move.w	d4,$dff058

	add.l	4(a0),a1
	add.l	#BplLen,a3
	dbra	d7,MvItmToSc
	movem.l	(sp)+,d0-a6
	rts



;	*** Start programu
run:
	lea	screen,a0
	lea	scr_ptr(pc),a1
	move.l	a0,(a1)

	move.l	a0,d0
	lea	bitplane_adr(pc),a1
	moveq	#5,d7
scaloop:swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#BplLen,d0
	dbra	d7,scaloop

	lea	sprite_adr,a1
	lea	sprite_data,a0
	move.l	a0,d0
	moveq	#7,d7
ssaloop:swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#128,d0
	dbra	d7,ssaloop

	lea	c_bufor(pc),a0
	lea	c_stary(pc),a1
	lea	vblk(pc),a2
	lea	next_vbl_adr(pc),a3

	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a
	move.l	$6c,(a1)
	move.l	a2,$6c
	move.l	c_stary(pc),$02(a3)
	
	move.w	(a0),d0
	or.w	#$8020,d0
	move.w	d0,$dff09a

	lea	copper(pc),a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	lea	mode(pc),a0
	clr.l	(a0)
	moveq	#4,d0
	moveq	#0,d1
	bsr.w	set_sprite
	move.l	#$ef70,d0
	moveq	#0,d1
	bsr.w	set_sprite_pos

	lea	RoomBcg,a1
	bsr.w	MoveRoomToScreen

	moveq	#8*10+0,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr.w	PutItemToScreen

mysz:	btst	#10,$dff016
	bne.b	mysz
	btst	#6,$bfe001
	bne.b	mysz
	
  	move.w	#$7fff,$dff09a
	move.l	c_stary(pc),$6c
	move.w	c_bufor(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff09a

exit3:	move.l	$4,a6
	lea	GRlib(pc),a1
	jsr	-408(a6)
	move.l	d0,a0
	move.l	$26(a0),$dff080
	move.w	d0,$dff088
	move.l	d0,a1
	jsr	-414(a6)
	move.w	#$83ff,$dff096
	rts


grlib:	dc.b	'graphics.library',0

even

c_bufor:	dc.w	0
c_stary:	dc.l	0
scr_ptr:	dc.l	0
mode:		dc.l	0
reg_clear:	blk.l	16,0

main_gadgets:	
	dc.w	43,147,43+40,147+16		;wez
	dc.w	82,147,82+40,147+16		;uzyj
	dc.w	120,147,120+34,147+16		;mow
	dc.w	152,147,152+50,147+16		;walcz
	dc.w	200,147,200+60,147+16		;zbadaj
	dc.w	46,166,45+16,165+14		;torba
	dc.w	-1

main_gadgets_j:
	bra	set_take_mode
	bra	set_use_mode
	bra	set_speak_mode
	bra	set_fight_mode
	bra	set_look_mode
	bra	set_look_mode

copper:	dc.l	$009683f0

	dc.l	$008e2c50,$00902cc1
	dc.l	$00920038,$009400d0
CopperModulos:
	dc.l	$01080000,$010a0000

sprite_adr:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0
	dc.w	$12e,0,$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0
	dc.w	$13c,0,$13e,0

colors:	dc.w	$0180
dfg:	dc.w	$0000,$0182,$0730,$0184,$0940,$0186,$0b60
	dc.w	$0188,$0d80,$018a,$0060,$018c,$0090,$018e,$00c0
	dc.w	$0190,$00f0,$0192,$0048,$0194,$006a,$0196,$008c
	dc.w	$0198,$00ae,$019a,$070c,$019c,$090d,$019e,$0b0e
	dc.w	$01a0,$0d0f,$01a2,$0888,$01a4,$0aaa,$01a6,$0ccc
	dc.w	$01a8,$0333,$01aa,$0444,$01ac,$0555,$01ae,$0666
	dc.w	$01b0,$0b00,$01b2,$0fc0,$01b4,$0f20,$01b6,$0aaa
	dc.w	$01b8,$0444,$01ba,$070c,$01bc,$0eee,$01be,$0fff


bitplane_adr:
	dc.l	$00e00000,$00e20000,$00e40000,$00e60000,$00e80000
	dc.l	$00ea0000,$00ec0000,$00ee0000,$00f00000,$00f20000
	dc.l	$00f40000,$00f60000


	dc.w	$0100,%0110000000000000
	dc.l	$fffffffe
sprite_data:
	blk.b	$400,0

sprite_bank:
dc.w	$3c00,$0000,$6300,$1c00,$c180,$2200,$8080,$4100
dc.w	$8080,$4100,$8080,$4100,$c180,$2200,$62c0,$1d00
dc.w	$1f60,$0080,$01b0,$0040,$00f0,$0000,$0070,$0000
dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
dc.w	$4000,$8000,$a000,$4000,$5000,$2000,$2800,$1000
dc.w	$1400,$0800,$0a00,$0400,$050c,$0200,$028e,$0100
dc.w	$0156,$0088,$00a8,$0050,$0050,$0020,$00a8,$0050
dc.w	$0356,$0088,$038b,$0004,$018f,$0000,$0007,$0000
dc.w	$1fc0,$0000,$7070,$0f80,$c018,$3fe0,$9b48,$64b0
dc.w	$8248,$7db0,$95a8,$6a50,$8818,$77e0,$4070,$3f80
dc.w	$4fc0,$3000,$5000,$2000,$6000,$0000,$6000,$0000
dc.w	$4000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
dc.w	$06c0,$0000,$3528,$0240,$2a94,$1120,$1496,$0920
dc.w	$1492,$0924,$8492,$4924,$c264,$2d98,$600c,$1ff0
dc.w	$3008,$0ff0,$1810,$07e0,$0630,$01c0,$0620,$01c0
dc.w	$0620,$01c0,$07e0,$0000,$0000,$0000,$0000,$0000
dc.w	$fe00,$0000,$9e00,$6000,$8c00,$7000,$8400,$7800
dc.w	$8600,$7800,$b300,$4c00,$c980,$0600,$04c0,$0300
dc.w	$0260,$0180,$0140,$0080,$0080,$0000,$0000,$0000
dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

RoomBcg:
	dc.w	40
	incbin	Room1.bcg


ItemDatas:
	dc.w	10,50		;porecz
	dc.l	10*50
	dc.l	0
	dc.l	0

ItemShapes:
	incbin	1.blt

ItemOutlines:
	incbin	1.out
aaa:	dc.l	0,0,0,0

SECTION	screen,bss_c
screen:	ds.b	6*bpllen
