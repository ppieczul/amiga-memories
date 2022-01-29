
WaitBlit:MACRO
	btst	#14,$dff002
	bne.s	*-8
	ENDM

waitframe:MACRO
\@1:	cmp.b	#$ff,$dff006
	bne.b	\@1
\@2:	tst.b	$dff006
	bne.b	\@2
	endm

waitframeZ:MACRO
\@1:	tst.b	FrameEnd
	beq.b	\@1
	clr.b	FrameEnd
	endm

waitframe0:MACRO
\@1:	cmp.b	#$ff,$dff006
	bne.b	\@1
	endm

waitframe2:MACRO
\@1:	cmp.b	#$ff,$dff006
	bne.b	\@1
\@2:	cmp.b	#$30,$dff006
	bne.b	\@2
	endm

lines0=254

	incdir	my:Incl/
	section code,code_p
start_abs:
	lea	Mod,a0
	move.l	a0,tp_data

	lea	vblk_ptr,a0
	lea	return_abs,a1
	move.l	a1,(a0)
	bsr.w	setvblk
	jsr	tp_init

	jsr	StartSeq
	jsr	DotsTyper
	jsr	Dotsy
	jsr	balls

	lea	Pic,a0
	move.l	a0,PicAdr
	lea	Pal0,a0
	move.l	a0,PalAdr

	jsr	Part
	jsr	PreCuCube
	jsr	PreCube
	jsr	PreCubePoints

	move.l	#200,cmper
	jsr	CuCube

	move.l	#150,cmper
	lea	Pic,a0
	move.l	a0,PicAdr
	lea	Pal0,a0
	move.l	a0,PalAdr
	jsr	Cube

	move.l	#300,cmper
	jsr	CubePoints
	move.l	#200,cmper
	jsr	CuCube

	move.l	#150,cmper
	lea	Pic2,a0
	move.l	a0,PicAdr
	lea	Pal1,a0
	move.l	a0,PalAdr
	jsr	Cube

	move.l	#300,cmper
	jsr	CubePoints

	move.l	#25,cmper
 	jsr	CuCube
	jsr	Cube
	jsr	CubePoints

	waitframe
	lea	copperLO,a0
	move.l	a0,$dff084
	lea	SprCopper0,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	waitframe
	lea	Change,a1
	move.l	a1,Vblk_Ptr

NoZZ:	tst.b	Zez+1
	beq.b	NoZZ

	lea	FreeGel,a0
	move.w	#$3ff<<6!63,d0
	jsr	clearscreen_abs
	jsr	gel_glenz

	lea	RamkaUp,a0
	move.w	#$3ff<<6!63,d0
	jsr	clearscreen_abs

	lea	RamkaUp+$1f782,a0
	move.w	#$3ff<<6!63,d0
	jsr	clearscreen_abs

;	lea	RamkaUp+$1f782*2,a0
;	move.w	#6<<6!63,d0
;	jsr	clearscreen_abs
	bsr	oldball
	bsr	RunJ
	bsr	RunED
	bsr.w	exitvblk
	rts

clearscreen_abs:
	waitblit
	move.l	#$01000000,$dff040
	move.w	#0,$dff066
	move.l	#0,$dff044
	move.l	a0,$dff054
	move.w	d0,$dff058
	waitblit
	rts


no=0
yes=1

pt1.1=no	;protracker v1.1 compatible (default=pt2.0)
syncs=no	;do you use vibrato or tremolo with sync ?
funk=no		;do you use the ef-comand ?
vbruse=no	;use vectortableoffset ?
volume=no	;use volumesliding ?
suck=yes	;das ya dick wanna b suckd ?
		;(sorry, not yet implementated)

tp_init:
	lea	$dff002,a5
	lea	tp_wait(pc),a0
	move	#1,(a0)
	clr	tp_pattcount-tp_wait(a0)
	move	#6,tp_speed-tp_wait(a0)
	move.l	tp_data(pc),a1
	lea	28(a1),a1
	move	(a1)+,d7
	lea	(a1,d7.w),a2
	lsr	#3,d7
	move	(a2)+,d0
	move.l	a2,tp_pattadr-tp_wait(a0)
	move.l	a2,tp_pattadr3-tp_wait(a0)
	moveq	#0,d1
	moveq	#0,d2
tp_initpattern:
	move	(a2)+,d1
	cmp	d1,d2
	bgt.s	tp_initpattok
	move	d1,d2
tp_initpattok:
	subq	#1,d0
	bne.s	tp_initpattern
	move.l	a2,tp_pattadr2-tp_wait(a0)
	move.l	a2,tp_pattlistadr-tp_wait(a0)
	lea	8(a2,d2.w),a2
	move	(a2)+,d0
	move.l	a2,tp_pattdataadr-tp_wait(a0)
	moveq	#30,d6
	sub	d7,d6
	subq	#1,d7
	lea	(a2,d0.w),a3
	move.l	a3,d5
	lea	tp_instlist(pc),a2
tp_initinst:
	moveq	#0,d0
	move.b	(a1)+,d0
	mulu	#72,d0
	add	#tp_notelist-tp_wait,d0
	move	d0,(a2)+
	moveq	#0,d0
	move.b	(a1)+,d0
	move	d0,(a2)+
	move.l	a3,(a2)+
	lea	(a3),a4
	moveq	#0,d0
	move	(a1)+,d0
	add	d0,a3
	add	d0,a3
	moveq	#0,d1
	move	(a1)+,d1
	add	d1,a4
	add	d1,a4
	move.l	a4,(a2)+
	move	d0,(a2)+
	move	(a1)+,(a2)+
	dbra	d7,tp_initinst
	tst	d6
	bmi.s	tp_initsamplesok
	moveq	#0,d0
	moveq	#1,d1
tp_sampleinitloop2:
	move.l	d0,(a2)+
	move.l	d5,(a2)+
	move.l	d5,(a2)+
	move.l	d1,(a2)+
	dbra	d6,tp_sampleinitloop2
tp_initsamplesok:
	moveq	#0,d0
	moveq	#63,d1
	lea	tp_voice0dat(pc),a1
	move.b	d0,51(a1)
	move	d1,52(a1)
	move.b	d0,51+58(a1)
	move	d1,52+58(a1)
	move.b	d0,51+116(a1)
	move	d1,52+116(a1)
	move.b	d0,51+174(a1)
	move	d1,52+174(a1)
	move	d0,$a6(a5)
	move	d0,$b6(a5)
	move	d0,$c6(a5)
	move	d0,$d6(a5)
	move	#$f,$94(a5)
	move	#$2000,$98(a5)
	lea	tp_mainint(pc),a2
	move.l	a2,tp_int1pon-tp_wait(a0)
	if	vbruse
	move.l	tp_vbr(pc),a1
	move.l	$78(a1),tp_oldint-tp_wait(a0)
	move.l	a2,$78(a1)
	else
	move.l	$78.w,tp_oldint-tp_wait(a0)
	move.l	a2,$78.w
	endc
	lea	tp_voiceloopint(pc),a2
	move.l	a2,tp_int3pon-tp_wait(a0)
	lea	$bfd000,a1
	ori.b	#2,$1001(a1)
	clr.b	$e00(a1)
	clr.b	$f00(a1)
	move.b	#$6b,$400(a1)
	move.b	#$37,$500(a1)
	move.b	#$6b,$600(a1)
	move.b	#1,$700(a1)
	move.b	#$7f,$d00(a1)
	move.b	#$83,$d00(a1)
	move.b	#$11,$e00(a1)
	move	#$e000,$98(a5)
	rts

tp_end:
	lea	$dff002,a5
	moveq	#0,d0
	move	d0,$a6(a5)
	move	d0,$b6(a5)
	move	d0,$c6(a5)
	move	d0,$d6(a5)
	move	#$f,$94(a5)
	move	#$2000,$98(a5)
	if	vbruse
	move.l	tp_vbr(pc),a1
	move.l	tp_oldint(pc),$78(a1)
	else
	move.l	tp_oldint(pc),$78.w
	endc
	rts

tp_mainint:
	movem.l	d0-a5,-(a7)
	lea	$dff002,a5
	tst.b	$bfdd00
	move	#$2000,$9a(a5)
	moveq	#0,d4
	lea	tp_wait(pc),a0
	clr.b	tp_dmaon-tp_wait+1(a0)
	subq	#1,(a0)
	beq	tp_newline
tp_playeffects:
	lea	tp_voice0dat+6(pc),a1
	move	(a1)+,d0
	beq.s	tp_novoice1
	lea	$9e(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice1:
	lea	tp_voice1dat+6(pc),a1
	move	(a1)+,d0
	beq.s	tp_novoice2
	lea	$ae(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice2:
	lea	tp_voice2dat+6(pc),a1
	move	(a1)+,d0
	beq.s	tp_novoice3
	lea	$be(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice3:
	lea	tp_voice3dat+6(pc),a1
	move	(a1)+,d0
	beq.s	tp_novoice4
	lea	$ce(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice4:
	move.b	tp_dmaon+1(pc),d4
	if	funk
	beq	tp_funkit
	bra	tp_initnewsamples
	else
	bne	tp_initnewsamples
	movem.l	(a7)+,d0-a5
	rte
	endc
tp_fxplaylist:
	bra	tp_voicefx1
	bra	tp_voicefx2
	bra	tp_voicefx3
	bra	tp_voicefx4
	bra	tp_voicefx5
	bra	tp_voicefx6
	bra	tp_voicefx7
	bra	tp_voicefx0
	bra	tp_voicefxe9do
	bra	tp_voicefxa
	bra	tp_voicefxecdo
	bra	tp_voicefxeddo

tp_newline:
	move	tp_speed(pc),(a0)
	tst	tp_pattdelay-tp_wait(a0)
	beq.s	tp_nopatterndelay
	subq	#1,tp_pattdelay-tp_wait(a0)
	bra	tp_playeffects
tp_nopatterndelay:
	tst	tp_pattrepeat-tp_wait(a0)
	bne.s	tp_repeatit
	subq	#1,tp_pattcount-tp_wait(a0)
	bpl	tp_playline
	move	#63,tp_pattcount-tp_wait(a0)
	move.l	tp_pattadr(pc),a1
	move	(a1)+,tp_pattadrpon-tp_wait(a0)
	cmp.l	tp_pattadr2(pc),a1
	bne.s	tp_pattadrok
	move.l	tp_pattadr3(pc),a1
tp_pattadrok:
	move.l	a1,tp_pattadr-tp_wait(a0)
tp_repeatit:
	clr	tp_pattrepeat-tp_wait(a0)
	move	tp_pattadrpon(pc),d0
	move.l	tp_pattlistadr(pc),a1
	movem	(a1,d0.w),d0-d3
	moveq	#-2,d4
	move.l	tp_pattdataadr(pc),a1
	move.b	d4,tp_voice0dat-tp_wait+1(a0)
	add.l	a1,d0
	move.l	d0,tp_voice0dat-tp_wait+2(a0)
	move.b	d4,tp_voice1dat-tp_wait+1(a0)
	add.l	a1,d1
	move.l	d1,tp_voice1dat-tp_wait+2(a0)
	move.b	d4,tp_voice2dat-tp_wait+1(a0)
	add.l	a1,d2
	move.l	d2,tp_voice2dat-tp_wait+2(a0)
	move.b	d4,tp_voice3dat-tp_wait+1(a0)
	add.l	a1,d3
	move.l	d3,tp_voice3dat-tp_wait+2(a0)

	move	tp_shitpon(pc),d0
	bne.s	tp_noshit
	moveq	#1,d0
	bra.s	tp_shit
tp_noshit:
	moveq	#0,d0
tp_shit:

	add	tp_newpattpos(pc),d0
	beq.s	tp_playline
	cmp.w	#64,d0
	bne.s	tp_pattinrange
	clr	tp_newpattpos-tp_wait(a0)
	clr	tp_pattcount-tp_wait(a0)
	moveq	#-1,d7
	move	d7,tp_shitpon-tp_wait(a0)
	bra	tp_nopatterndelay
tp_pattinrange:

	sub	d0,tp_pattcount-tp_wait(a0)
	clr	tp_newpattpos-tp_wait(a0)
	lea	tp_voice0dat+2(pc),a1
	subq	#1,d0
	moveq	#3,d7
tp_pattinitloop:
	move	d0,d6
	moveq	#0,d2
	move.l	(a1),a2
tp_pattsearchloop:
	move.b	(a2)+,d1
	bmi.s	tp_pattslab1
	moveq	#$f,d1
	and.b	(a2)+,d1
	beq.s	tp_pattslab3
	bra.s	tp_pattslab2
tp_pattslab1:
	add.b	d1,d1
	bpl.s	tp_pattslab2
	asr.b	#1,d1
	addq.b	#1,d1
	add.b	d1,d6
	bpl.s	tp_pattslab3
	add.b	d6,d6
	subq.b	#2,d6
	move	d6,d2
	moveq	#0,d6
	bra.s	tp_pattslab3
tp_pattslab2:
	addq.l	#1,a2
tp_pattslab3:
	dbra	d6,tp_pattsearchloop
	move.b	d2,-1(a1)
	move.l	a2,(a1)
	lea	58(a1),a1
	dbra	d7,tp_pattinitloop

tp_playline:
	move	#$1f0,d3
	moveq	#-1,d7
	move	d7,tp_shitpon-tp_wait(a0)
	lea	tp_voice0dat+1(pc),a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice0end
	moveq	#1,d4
	lea	$9e(a5),a3
	bsr	tp_playvoice
tp_playvoice0end:
	move	26(a1),$a4(a5)
	lea	tp_voice1dat+1(pc),a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice1end
	moveq	#2,d4
	lea	$ae(a5),a3
	bsr	tp_playvoice
tp_playvoice1end:
	move	26(a1),$b4(a5)
	lea	tp_voice2dat+1(pc),a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice2end
	moveq	#4,d4
	lea	$be(a5),a3
	bsr	tp_playvoice
tp_playvoice2end:
	move	26(a1),$c4(a5)
	lea	tp_voice3dat+1(pc),a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice3end
	moveq	#8,d4
	lea	$ce(a5),a3
	bsr.s	tp_playvoice
tp_playvoice3end:
	move	26(a1),$d4(a5)
	move.b	tp_dmaon+1(pc),d4
tp_initnewsamples:
	move	d4,$94(a5)
	lea	tp_dmaonint(pc),a1
	if	vbruse
	move.l	tp_vbr(pc),a2
	move.l	a1,$78(a2)
	else
	move.l	a1,$78.w
	endc
	move.b	#$19,$bfdf00
	if	funk
tp_funkit:
	lea	tp_voice0dat+48(pc),a1
	moveq	#3,d7
tp_funkloop:
	move.b	(a1)+,d4
	beq.s	tp_funkend
	move.b	tp_funklist-tp_wait(a0,d4.w),d4
	add.b	d4,(a1)
	bpl.s	tp_funkend
	clr.b	(a1)
	move.l	-31(a1),a2
	movem	-25(a1),d0-d1
	addq	#1,d1
	add	d0,d0
	cmp	d0,d1
	blo.s	tp_funkok
	moveq	#0,d1
tp_funkok:
	not.b	(a2,d1.w)
	move	d1,-23(a1)
tp_funkend:
	lea	57(a1),a1
	dbra	d7,tp_funkloop
	endc
	movem.l	(a7)+,d0-a5
	rte

tp_playvoice:
	move.l	(a1)+,a2
	moveq	#0,d0
	move.b	(a2)+,d0
	bmi	tp_playnonewnote
	moveq	#0,d1
	move.b	(a2)+,d1
	moveq	#$f,d2
	and.b	d1,d2
	beq.s	tp_noeffect
	move.b	(a2)+,3(a1)
	add	d2,d2
	add	d2,d2
tp_noeffect:
	move	d2,(a1)
	add.b	d0,d0
	bpl.s	tp_noupperinst
	eor.b	#$fe,d0
	bset	#8,d1
tp_noupperinst:
	and	d3,d1
	beq.s	tp_nonewinst
	movem.l	tp_instlist-tp_wait-16(a0,d1.w),d5-d7/a4
	movem.l	d5-d7/a4,4(a1)
	if	volume
	mulu	tp_volume(pc),d5
	lsr	#8,d5
	endc
	move	d5,8(a3)
	if	funk
	clr	20(a1)
	endc
tp_nonewinst:
	move.l	a2,-(a1)
	tst	d0
	beq.s	tp_newnoteend
	jsr	tp_fxinitlist(pc,d2.w)
	add	8(a1),d0
	move	-2(a0,d0.w),26(a1)
	or.b	d4,tp_dmaon-tp_wait+1(a0)
	if	syncs
	tst.b	32(a1)
	beq.s	tp_novibnoc
	clr.b	35(a1)
tp_novibnoc:
	tst.b	38(a1)
	beq.s	tp_notremnoc
	clr.b	41(a1)
tp_notremnoc:
	endc
	move.l	12(a1),(a3)+
	move	20(a1),(a3)
	rts
tp_playnonewnote:
	add.b	d0,d0
	bmi.s	tp_donothing
	move	d0,(a1)
	move.b	(a2)+,3(a1)
	move.l	a2,-(a1)
	move	d0,d2
	moveq	#0,d0
tp_newnoteend:
	jmp	tp_fxinitlist(pc,d2.w)
tp_donothing:
	clr	(a1)
	move.l	a2,-(a1)
	if	pt1.1
	move.b	d0,-(a1)
	addq.l	#6,(a7)
	else
	move.b	d0,-1(a1)
	endc
tp_fxinitlist:
	rts
	nop
	rts
	nop
	rts
	nop
	bra	tp_voicefx3init
	bra	tp_voicefx4init
	bra	tp_voicefx5init
	rts
	nop
	bra	tp_voicefx7init
	bra	tp_voicefx0init
	bra	tp_voicefx9
	rts
	nop
	bra	tp_voicefxb
	bra	tp_voicefxc
	bra	tp_voicefxd
	bra	tp_voicefxeinit
tp_voicefxf:
	clr	4(a1)
	move	6(a1),d1
	cmp	#32,d1
	bge.s	tp_voicefxcia
	move	d1,tp_speed-tp_wait(a0)
	move	d1,(a0)
	rts
tp_voicefxcia:
	move.l	#1773447,d2
	divu	d1,d2
	move.b	d2,$bfd400
	lsr	#8,d2
	move.b	d2,$bfd500
	rts


tp_voicefx0init:
	tst	d0
	beq.s	tp_voicefx0initlab1
	cmp	#70,d0
	beq.s	tp_voicefx0end
	add	8(a1),d0
	lea	-2(a0,d0.w),a4
	move.l	a4,52(a1)
	addq.l	#4,(a7)
	rts
tp_voicefx0initlab1:
	move	8(a1),d2
	lea	70(a0,d2.w),a4
	move.l	a4,d2
	lea	-34(a4),a4
	move	26(a1),d1
	cmp	(a4),d1
	bhs.s	.high18
	lea	18(a4),a4
	cmp	(a4),d1
	bhs.s	.high10
.low8:
	addq	#8,a4
	cmp	(a4),d1
	bhs.s	.high6
.low4:
	addq	#4,a4
	cmp	(a4),d1
	bhs.s	.high2
.low2:
	addq	#4,a4
	cmp	(a4),d1
	bhs.s	.high2
.low0:
	addq	#2,a4
	cmp	(a4),d1
	bhs.s	.found
	subq	#2,a4
	bra.s	.found
.high18:
	lea	-18(a4),a4
	cmp	(a4),d1
	blt.s	.low8
.high10:
	lea	-10(a4),a4
	cmp	(a4),d1
	blt.s	.low4
.high6:
	subq	#6,a4
	cmp	(a4),d1
	blt.s	.low2
.high2:
	cmp	-(a4),d1
	blt.s	.low0
.found:
	cmp.l	a4,d2
	beq.s	tp_voicefx0end
	move.l	a4,52(a1)
	rts
tp_voicefx0end:
	clr	4(a1)
	rts

	dc.b	1,0,-1,1,0,-1,1,0,-1,1,0,-1,1,0,-1,1
	dc.b	0,-1,1,0,-1,1,0,-1,1,0,-1,1,0,-1,1,0
tp_voicefx0:
	move	(a1)+,d1
	move	18(a1),d0
	move	(a0),d2
	sub	tp_speed(pc),d2
	move.b	tp_voicefx0-1(pc,d2.w),d2
	beq.s	tp_arp0
	bmi.s	tp_arp2
	lsr	#4,d1
	bra.s	tp_arp1
tp_arp2:
	and	#$f,d1
tp_arp1:
	move.l	44(a1),a4
	add	d1,d1
	move	(a4,d1.w),6(a3)
	rts
tp_arp0:
	move	d0,6(a3)
	rts

tp_voicefx1:
	move	20(a1),d1
	sub	(a1),d1
	and	#$fff,d1
	moveq	#113,d2
	cmp	d2,d1
	bpl.s	tp_voicefx1lab1
	move	d2,d1			;and #$f000,d0;or d1,d0 ???
tp_voicefx1lab1:
	move	d1,20(a1)
	move	d1,6(a3)
	rts

tp_voicefx2:
	move	20(a1),d1
	add	(a1),d1
	cmp	#856,d1
	bmi.s	tp_voicefx2lab1
	move	#856,d1
	clr	-2(a1)
tp_voicefx2lab1:
	move	d1,20(a1)
	move	d1,6(a3)
	rts

tp_voicefx3init:
	move	6(a1),d1
	beq.s	tp_voicefx5init
	tst	30(a1)
	bpl.s	tp_fx3initnochange
	neg	d1
tp_fx3initnochange:
	move	d1,30(a1)
tp_voicefx5init:
	tst	d0
	beq.s	tp_voicefx3initlab6
	addq.l	#4,a7
	addq.l	#6,(a7)
	move	8(a1),d2
;	cmp	#72*8+(tp_notelist-tp_wait),d2
;	blt.s	tp_voicefx3initlab3
;	subq	#2,d0
;	bgt.s	tp_voicefx3initlab3
;	moveq	#2,d0
tp_voicefx3initlab3:
	add	d0,d2
	move	-2(a0,d2.w),d0
	move	d0,28(a1)
	sub	26(a1),d0
	bpl.s	tp_voicefx3initlab5
	tst	30(a1)
	bmi.s	tp_voicefx3initlab4
	neg	30(a1)
tp_voicefx3initlab4:
	rts
tp_voicefx3initlab5:
	tst	30(a1)
	bpl.s	tp_voicefx3initlab6
	neg	30(a1)
tp_voicefx3initlab6:
	rts

tp_voicefx3:
	move	22(a1),d2
	beq.s	tp_voicefx3end
	move	24(a1),d1
	bmi.s	tp_voicefx3sub
	add	20(a1),d1
	cmp	d2,d1
	blt.s	tp_voicefx3ok
	bra.s	tp_voicefx3setok
tp_voicefx3sub:
	add	20(a1),d1
	cmp	d2,d1
	bgt.s	tp_voicefx3ok
tp_voicefx3setok:
	move	d2,d1
	clr	22(a1)
	clr	-2(a1)
tp_voicefx3ok:
	move	d1,20(a1)
	tst.b	42(a1)
	beq.s	tp_voicefx3skip
	move	2(a1),d2
	lea	(a0,d2.w),a4
	moveq	#35,d2
tp_voicefx3search:
	cmp	(a4)+,d1
	bhs.s	tp_voicefx3notefound
	dbra	d2,tp_voicefx3search
tp_voicefx3notefound:
	move	-2(a4),d1
tp_voicefx3skip:
	move	d1,6(a3)
tp_voicefx3end:
	rts

tp_voicefx5:
	bsr.s	tp_voicefx3
	bra.s	tp_voicefxa

tp_voicefx4init:
	move	6(a1),d1
	beq.s	tp_voicefx4initend
	moveq	#$f,d2
	and	d1,d2
	beq.s	tp_voicefx4initlab1
	move	d2,36(a1)
tp_voicefx4initlab1:
	and	#$f0,d1
	beq.s	tp_voicefx4initend
	lsr	#2,d1
	move.b	d1,34(a1)
tp_voicefx4initend:
	rts

tp_voicefx4:
	moveq	#$7f,d0
	and.b	29(a1),d0
	move.b	27(a1),d2
	beq.s	tp_voicefx4sine
	add	d0,d0
	subq.b	#1,d2
	beq.s	tp_voicefx4rampdown
	st	d0
	bra.s	tp_voicefx4set
tp_voicefx4rampdown:
	tst.b	29(a1)
	bpl.s	tp_voicefx4set
	not.b	d0	
	bra.s	tp_voicefx4set
tp_voicefx4sine:
	lsr	#2,d0
	move.b	tp_vibratolist-tp_wait(a0,d0.w),d0
tp_voicefx4set:
	mulu	30(a1),d0
	lsr	#7,d0
	tst.b	29(a1)
	bpl.s	tp_voicefx4nosub
	neg	d0
tp_voicefx4nosub:
	add	20(a1),d0
	move	d0,6(a3)
	move.b	28(a1),d0
	add.b	d0,29(a1)
	rts

tp_voicefx6:
	bsr.s	tp_voicefx4
tp_voicefxa:
	move	(a1),d1
	add.b	5(a1),d1
	bmi.s	tp_voicefxalab1
	moveq	#$40,d2
	cmp.b	d2,d1
	bcs.s	tp_voicefxaend
	move	d2,d1
	clr	-2(a1)
	bra.s	tp_voicefxaend
tp_voicefxalab1:
	moveq	#0,d1
	clr	-2(a1)
tp_voicefxaend:
	move	d1,4(a1)
	if	volume
	mulu	tp_volume(pc),d1
	lsr	#8,d1
	endc
	move	d1,8(a3)
	rts

tp_voicefx7init:
	move	6(a1),d1
	beq.s	tp_voicefx7initend
	moveq	#$f,d2
	and	d1,d2
	beq.s	tp_voicefx7initlab1
	move	d2,42(a1)
tp_voicefx7initlab1:
	and	#$f0,d1
	beq.s	tp_voicefx7initend
	lsr	#2,d1
	move.b	d1,40(a1)
tp_voicefx7initend:
	rts

tp_voicefx7:
	moveq	#$7f,d0
	and.b	35(a1),d0
	move.b	33(a1),d2
	beq.s	tp_voicefx7sine
	add	d0,d0
	subq.b	#1,d2
	beq.s	tp_voicefx7rampdown
	st	d0
	bra.s	tp_voicefx7set
tp_voicefx7rampdown:
	tst.b	35(a1)
	bpl.s	tp_voicefx7set
	not.b	d0	
	bra.s	tp_voicefx7set
tp_voicefx7sine:
	lsr	#2,d0
	move.b	tp_vibratolist-tp_wait(a0,d0.w),d0
tp_voicefx7set:
	mulu	36(a1),d0
	lsr	#7,d0
	tst.b	35(a1)
	bpl.s	tp_voicefx7nosub
	neg	d0
tp_voicefx7nosub:
	add	4(a1),d0
	bpl.s	tp_voicefx7noneg
	clr	d0
	bra.s	tp_voicefx7ok
tp_voicefx7noneg:
	moveq	#40,d1
	cmp	d1,d0
	bls.s	tp_voicefx7ok
	move	d1,d0
tp_voicefx7ok:
	if	volume
	mulu	tp_volume(pc),d0
	lsr	#8,d0
	endc
	move	d0,8(a3)
	move.b	34(a1),d0
	add.b	d0,35(a1)
	rts

tp_voicefx9:
	tst	d0
	beq.s	tp_voicefx9normal

	if	funk
	moveq	#0,d1
	move.b	46(a1),d1
	beq.s	tp_voicefx9funkend
	move.b	tp_funklist-tp_wait(a0,d1.w),d1
	add.b	d1,47(a1)
	bpl.s	tp_voicefx9funkend
	clr.b	47(a1)
	move.l	16(a1),a2
	movem	22(a1),d1-d2
	addq	#1,d2
	add	d1,d1
	cmp	d1,d2
	blo.s	tp_voicefx9funkok
	moveq	#0,d2
tp_voicefx9funkok:
	not.b	(a2,d2.w)
	move	d2,24(a1)
tp_voicefx9funkend:
	endc

	move.l	(a7),-(a7)
	lea	tp_voicefx9after(pc),a4
	move.l	a4,4(a7)
tp_voicefx9normal:
	clr	4(a1)
	moveq	#0,d1
	move	6(a1),d1
	beq.s	tp_voicefx9after
	lsl	#7,d1
	move	d1,44(a1)
tp_voicefx9after:
	move	44(a1),d1
	sub	d1,20(a1)
	ble.s	tp_voicefx9skip
	add	d1,d1
	add.l	d1,12(a1)
	rts
tp_voicefx9skip:
	move	#1,20(a1)
	rts

tp_voicefxb:
	clr	4(a1)
	clr	tp_pattcount-tp_wait(a0)
	move	6(a1),d1
	move.l	tp_pattadr3(pc),a1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,tp_pattadr-tp_wait(a0)
	rts

tp_voicefxc:
	move	6(a1),d1
	move	d1,10(a1)
	if	volume
	mulu	tp_volume(pc),d1
	lsr	#8,d1
	endc
	move	d1,8(a3)
	clr	4(a1)
	rts

tp_voicefxd:
	clr	4(a1)
	clr	tp_pattcount-tp_wait(a0)
	move	6(a1),tp_newpattpos-tp_wait(a0)
	clr.b	tp_shitpon-tp_wait(a0)
	rts

tp_voicefxeinit:
	moveq	#-$10,d1
	and	6(a1),d1
	lsr	#2,d1
	jmp	tp_voicefxeinitlist(pc,d1.w)
tp_voicefxeinitlist:
	bra	tp_voicefxe0
	bra	tp_voicefxe1
	bra	tp_voicefxe2
	bra	tp_voicefxe3
	bra	tp_voicefxe4
	bra	tp_voicefxe5
	bra	tp_voicefxe6
	bra	tp_voicefxe7
	rts
	nop
	bra	tp_voicefxe9
	bra	tp_voicefxea
	bra	tp_voicefxeb
	bra	tp_voicefxec
	bra	tp_voicefxed
	bra	tp_voicefxee
tp_voicefxef:
	clr	4(a1)
	if	funk
	moveq	#$f,d2
	and	6(a1),d2
	move.b	d2,46(a1)
	endc
	rts

tp_voicefxe0:
	clr	4(a1)
	moveq	#1,d2
	and	6(a1),d2
	bne.s	tp_voicefxe0clr
	bclr	#1,$bfe001
	rts
tp_voicefxe0clr:
	bset	d2,$bfe001
	rts

tp_voicefxe1:
	tst	d0
	beq.s	tp_voicefxe1ok
	move	8(a1),d1
	add	d0,d1
	move	-2(a0,d1.w),26(a1)
	moveq	#10,d0
	add.l	d0,(a7)
tp_voicefxe1ok:
	addq.l	#4,a1
	clr	(a1)+
	and	#$f,(a1)
	bsr	tp_voicefx1
	subq.l	#6,a1
	rts

tp_voicefxe2:
	tst	d0
	beq.s	tp_voicefxe2ok
	move	8(a1),d1
	add	d0,d1
	move	-2(a0,d1.w),26(a1)
	moveq	#10,d0
	add.l	d0,(a7)
tp_voicefxe2ok:
	addq.l	#4,a1
	clr	(a1)+
	and	#$f,(a1)
	bsr	tp_voicefx2
	subq.l	#6,a1
	rts

tp_voicefxe3:
	clr	4(a1)
	moveq	#$f,d2
	and	6(a1),d2
	move.b	d2,48(a1)
	rts

tp_voicefxe4:
	clr	4(a1)
	moveq	#$3,d2
	and	6(a1),d2
	move.b	d2,33(a1)
	btst	#2,6(a1)
	beq.s	tp_voicefxe4ok
	st	32(a1)
	rts
tp_voicefxe4ok:
	clr.b	32(a1)
	rts

tp_voicefxe5:
	clr	4(a1)
	moveq	#$f,d2
	and	6(a1),d2
	mulu	#72,d2
	add	#tp_notelist-tp_wait,d2
	move	d2,8(a1)
	rts

tp_voicefxe6:
	clr	4(a1)
	moveq	#$f,d2
	and	6(a1),d2
	beq.s	tp_voicefxe6start
	subq.b	#1,49(a1)
	beq.s	tp_voicefxe6end
	bpl.s	tp_voicefxe6doloop
	move.b	d2,49(a1)
tp_voicefxe6doloop:
	moveq	#63,d2
	move	d2,tp_pattcount-tp_wait(a0)
	sub	50(a1),d2
	move	d2,tp_newpattpos-tp_wait(a0)
	st	tp_pattrepeat-tp_wait(a0)
tp_voicefxe6end:
	rts
tp_voicefxe6start:
	move	tp_pattcount(pc),50(a1)
	rts

tp_voicefxe7:
	clr	4(a1)
	moveq	#$f,d2
	and	6(a1),d2
	move.b	d2,39(a1)
	btst	#2,6(a1)
	beq.s	tp_voicefxe7ok
	st	38(a1)
	rts
tp_voicefxe7ok:
	clr.b	38(a1)
	rts

tp_voicefxe9:
	move	#$9*4,4(a1)
	and	#$f,6(a1)
	beq.s	tp_voicefxe9clear
	tst	d0
	bne.s	tp_voicefxe9end
tp_voicefxe9clear:
	clr	4(a1)
tp_voicefxe9end:
	rts
tp_voicefxe9do:
	moveq	#0,d1
	move	tp_speed(pc),d1
	sub	(a0),d1
	divu	(a1),d1
	swap	d1
	tst	d1
	bne.s	tp_voicefxe9end
tp_voicefxe9play:
	move.b	-8(a1),d1
	or.b	d1,tp_dmaon-tp_wait+1(a0)
	move.l	6(a1),(a3)+
	move	14(a1),(a3)
	rts

tp_voicefxea:
	addq.l	#4,a1
	clr	(a1)+
	and	#$f,(a1)
	bsr	tp_voicefxa
	subq.l	#6,a1
	rts

tp_voicefxeb:
	addq.l	#4,a1
	clr	(a1)+
	and	#$f,(a1)
	neg.b	1(a1)
	bsr	tp_voicefxa
	subq.l	#6,a1
	rts

tp_voicefxec:
	move	#$b*4,4(a1)
	and	#$f,6(a1)
	bne.s	tp_voicefxecend
	clr	4(a1)
	clr	10(a1)
	clr	8(a3)
tp_voicefxecend:
	rts
tp_voicefxecdo:
	subq	#1,(a1)
	bne.s	tp_voicefxecend
	clr	-(a1)
	clr	6(a1)
	clr	8(a3)
	rts

tp_voicefxed:
	move	#$c*4,4(a1)
	tst	d0
	beq.s	tp_voicefxednoinit
	and	#$f,6(a1)
	beq.s	tp_voicefxednoinit
	add	8(a1),d0
	move	-2(a0,d0.w),26(a1)
	addq	#4,a7
	addq.l	#6,(a7)
	rts
tp_voicefxednoinit:
	clr	4(a1)
tp_voicefxedend:
	rts
tp_voicefxeddo:
	subq	#1,(a1)
	bne.s	tp_voicefxedend
	clr	-2(a1)
	move	20(a1),6(a3)
	bra	tp_voicefxe9play

tp_voicefxee:
	clr	4(a1)
	moveq	#$f,d1
	and	6(a1),d1
	move	d1,tp_pattdelay-tp_wait(a0)
	clr.b	tp_shitpon-tp_wait+1(a0)
	rts

tp_dmaonint:
	tst.b	$bfdd00
	move.b	#$19,$bfdf00
	move	tp_dmaon(pc),$dff096
	if	vbruse
	move.l	a0,-(a7)
	move.l	tp_vbr(pc),a0
	move.l	tp_int3pon(pc),$78(a0)
	move.l	(a7)+,a0
	else
	move.l	tp_int3pon(pc),$78.w
	endc
	move	#$2000,$dff09c
	rte

tp_voiceloopint:
	tst.b	$bfdd00
	move.l	tp_voice0dat+18(pc),$dff0a0
	move	tp_voice0dat+24(pc),$dff0a4
	move.l	tp_voice1dat+18(pc),$dff0b0
	move	tp_voice1dat+24(pc),$dff0b4
	move.l	tp_voice2dat+18(pc),$dff0c0
	move	tp_voice2dat+24(pc),$dff0c4
	move.l	tp_voice3dat+18(pc),$dff0d0
	move	tp_voice3dat+24(pc),$dff0d4
	if	vbruse
	move.l	a0,-(a7)
	move.l	tp_vbr(pc),a0
	move.l	tp_int1pon(pc),$78(a0)
	move.l	(a7)+,a0
	else
	move.l	tp_int1pon(pc),$78.w
	endc
	move	#$2000,$dff09c
	rte

tp_shitpon:dc		-1
tp_pattcount:dc		1
tp_wait:dc		1
tp_pattadr:dc.l		0
tp_pattadr2:dc.l	0
tp_pattadr3:dc.l	0
tp_pattlistadr:dc.l	0
tp_pattdataadr:dc.l	0
tp_oldint:dc.l		0
tp_int1pon:dc.l		0
tp_int3pon:dc.l		0
tp_newpattpos:dc	0
tp_pattdelay:dc		0
tp_pattrepeat:dc	0
tp_pattadrpon:dc	0
tp_data:dc.l		0
tp_dmaon:dc		$8000
tp_funklist:
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
tp_vibratolist:
	dc.b	0,24,49,74,97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,97,74,49,24
tp_instlist:blk.b	31*16,0
tp_speed:dc		6
	if	vbruse
tp_vbr:dc.l		0
	endc
	if	volume
tp_volume:dc		255		;0=off,255=max. volume
	endc
tp_notelist:
	dc	856,808,762,720,678,640,604,570,538,508,480,453
	dc	428,404,381,360,339,320,302,285,269,254,240,226
	dc	214,202,190,180,170,160,151,143,135,127,120,113

	dc	850,802,757,715,674,637,601,567,535,505,477,450
	dc	425,401,379,357,337,318,300,284,268,253,239,225
	dc	213,201,189,179,169,159,150,142,134,126,119,113

	dc	844,796,752,709,670,632,597,563,532,502,474,447
	dc	422,398,376,355,335,316,298,282,266,251,237,224
	dc	211,199,188,177,167,158,149,141,133,125,118,112

	dc	838,791,746,704,665,628,592,559,528,498,470,444
	dc	419,395,373,352,332,314,296,280,264,249,235,222
	dc	209,198,187,176,166,157,148,140,132,125,118,111

	dc	832,785,741,699,660,623,588,555,524,495,467,441
	dc	416,392,370,350,330,312,294,278,262,247,233,220
	dc	208,196,185,175,165,156,147,139,131,124,117,110

	dc	826,779,736,694,655,619,584,551,520,491,463,437
	dc	413,390,368,347,328,309,292,276,260,245,232,219
	dc	206,195,184,174,164,155,146,138,130,123,116,109

	dc	820,774,730,689,651,614,580,547,516,487,460,434
	dc	410,387,365,345,325,307,290,274,258,244,230,217
	dc	205,193,183,172,163,154,145,137,129,122,115,109

	dc	814,768,725,684,646,610,575,543,513,484,457,431
	dc	407,384,363,342,323,305,288,272,256,242,228,216
	dc	204,192,181,171,161,152,144,136,128,121,114,108

	dc	907,856,808,762,720,678,640,604,570,538,508,480
	dc	453,428,404,381,360,339,320,302,285,269,254,240
	dc	226,214,202,190,180,170,160,151,143,135,127,120

	dc	900,850,802,757,715,675,636,601,567,535,505,477
	dc	450,425,401,379,357,337,318,300,284,268,253,238
	dc	225,212,200,189,179,169,159,150,142,134,126,119

	dc	894,844,796,752,709,670,632,597,563,532,502,474
	dc	447,422,398,376,355,335,316,298,282,266,251,237
	dc	223,211,199,188,177,167,158,149,141,133,125,118

	dc	887,838,791,746,704,665,628,592,559,528,498,470
	dc	444,419,395,373,352,332,314,296,280,264,249,235
	dc	222,209,198,187,176,166,157,148,140,132,125,118

	dc	881,832,785,741,699,660,623,588,555,524,494,467
	dc	441,416,392,370,350,330,312,294,278,262,247,233
	dc	220,208,196,185,175,165,156,147,139,131,123,117

	dc	875,826,779,736,694,655,619,584,551,520,491,463
	dc	437,413,390,368,347,328,309,292,276,260,245,232
	dc	219,206,195,184,174,164,155,146,138,130,123,116

	dc	868,820,774,730,689,651,614,580,547,516,487,460
	dc	434,410,387,365,345,325,307,290,274,258,244,230
	dc	217,205,193,183,172,163,154,145,137,129,122,115

	dc	862,814,768,725,684,646,610,575,543,513,484,457
	dc	431,407,384,363,342,323,305,288,272,256,242,228
	dc	216,203,192,181,171,161,152,144,136,128,121,114

tp_voice0dat:
	dc.b	1
	blk.b	57,0
tp_voice1dat:
	dc.b	2
	blk.b	57,0
tp_voice2dat:
	dc.b	4
	blk.b	57,0
tp_voice3dat:
	dc.b	8
	blk.b	57,0


SEC:	lea	EmptyCopper,a0
	move.l	a0,$dff080
	clr.w	$dff088
	rts
vblk_abs:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$dff01e,d0
	and.w	#$0020,d0
	beq.s	wrong_abs

	move.b	#-1,FrameEnd
	addq.l	#1,Counter

	move.l	vblk_ptr,a0
	jsr	(a0)

	move.w	#$0020,$dff09c
	movem.l	(sp)+,d0-d7/a0-a6
	jmp	stary_abs-2

wrong_abs:
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	jmp	stary_abs-2
return_abs:
	rts

SetVblk:lea	bufor_abs,a0
	lea	stary_abs,a1
	lea	vblk_abs,a2

	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a
	move.l	$6c,(a1)
	move.l	a2,$6c

;	move.w	(a0),d0
	move.w	#$c030,d0
	move.w	d0,$dff09a
	rts
ExitVblk:
 	move.w	#$7fff,$dff09a
	move.l	stary_Abs,$6c
	move.w	bufor_Abs,d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	jmp	tp_end
	rts


		dc.l	$4ef9
Stary_Abs:	dc.l	0
Bufor_Abs:	dc.l	0
Vblk_Ptr:	dc.l	0
Module:		dc.l	0
FrameEnd:	dc.w	0

*************************************************************************

SinSPP:	dc.l	0
Zez:	dc.w	0
Counter:dc.l	0

Change:	cmp.w	#$407,CopperLO+2
	beq.b	Qwrer
	
	lea	CopperLO+2,a0
	moveq	#1,d7
ADH:	move.w	(a0),d1
	move.w	#$407,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,ADH

	lea	SPD+6,a0
	moveq	#1,d7
BDH:	move.w	(a0),d1
	move.w	#$607,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,BDH

	rts
Qwrer:
	tst.w	XPos0
	ble.b	MKop1
	bsr.w	SetPos0
	subq.w	#2,Xpos0
	rts
Mkop1:	move.b	#-1,Zez+1
	cmp.l	#EndSp-SinSp,SinSPP
	bge.b	Eqrt
	addq.l	#1,SinSPP
	move.l	SinSPP,d7
	lea	SinSp,a0
	move.b	(a0,d7.l),SpD
	rts
Eqrt:	move.b	#-1,zez
	rts

Gel_Glenz:bra.w	runG

ampl=120

krzG:	MACRO
	move.w	\3(a4),d2
	sub.w	#152,d2
	bpl.b	\@1
	neg.w	d2
\@1:	muls.w	plaskG,d2
	swap	d2
	muls.w	#ampl*2,d2
	bpl.b	\@5
	neg.w	d2
	lea	(a6,d2.w),a1
	cmp.w	#152,\3(a4)
	bgt.b	\@4
	lea	(a3,d2.w),a1
	bra.b	\@4
\@5:	lea	(a3,d2.w),a1
	cmp.w	#152,\3(a4)
	bgt.b	\@4
	lea	(a6,d2.w),a1
\@4:	move.w	\1(a4),d7
	move.w	\2(a4),d6
	sub.w	d6,d7
	bpl.b	\@2
	move.w	\1(a4),d6
	neg.w	d7
\@2:	subq.w	#1,d7
	asl.w	#6,d6
	lea	(a5,d6.w),a2
	move.l	#[YgrekG-[Ampl/2]]<<8,d5
	divu.w	d7,d5
	moveq	#0,d3
\@3:	add.w	d5,d3
	move.w	d3,d4
	asr.w	#7,d4
	and.b	#$fe,d4
	move.w	(a1,d4.w),d0
	add.w	\3(a4),d0
	move.w	d0,d1
	asr.w	#3,d1
	not.b	d0
	bchg.b	d0,(a2,d1.w)
	lea	64(a2),a2
	dbf	d7,\@3
	ENDM


lineG:
	cmp.w	d3,d1
	beq.w	l_quitg
	bhi.w	l_noychg
	exg.l	d0,d2
	exg.l	d1,d3

l_noychG:subq.w	#1,d1

	moveq	#0,d4
	move.w	d1,d4
	asl.w	#6,d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a5,d4

	moveq	#0,d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.b	y2Gy1G
	neg.w	d3
y2Gy1G:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx1G
	neg.w	d2
x2Gx1G:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdxg
	exg.l	d2,d3
dyGdxG:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsFG(pc,d5.w),d5

WBlitG:	btst.b	#14,$dff002
	bne.b	WBlitG

	move.w	d2,$dff062
	sub.w	d3,d2
	bge.b	SignNlG
	or.b	#$40,d5
SignNlG:
	move.w	d2,$dff052
	sub.w	d3,d2
	move.w	d2,$dff064
	move.l	#$ffff8000,$dff072
	move.l	#$ffffffff,$dff044
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0b4a,d0
	move.w	d0,$dff040
	move.w	d5,$dff042
	move.l	d4,$dff048
	move.l	d4,$dff054
	move.w	#64,$dff060
	move.w	#64,$dff066

	addq.w	#1,d3
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$dff058
l_quitG:
	rts
OctantsFG:
	dc.b	3,19,11,23,7,27,15,31

zxG=8
pointsG:

dc.w	26*zxG,-160,26*zxG
dc.w	26*zxG,-160,26*zxG
dc.w	26*zxG,26*zxG,26*zxG
dc.w	26*zxG,26*zxG,26*zxG
dc.w	26*zxG,-160,-26*zxG
dc.w	26*zxG,-160,-26*zxG
dc.w	26*zxG,26*zxG,-26*zxG
dc.w	26*zxG,26*zxG,-26*zxG
pointsendG:

destpG:	blk.b	[pointsendG-pointsG],0

setscrG:move.l	singleG+8,d0
	lea	c11G,a1
clopG:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1b80,d0
	dbra	d1,clopG
	rts


setspradrFL:
	lea	manysprFL,a0
	move.l	(a0),d0
	swap	d0
	move.w	d0,2(a6)
	swap	d0
	move.w	d0,6(a6)
	add.l	#$48,d0
	swap	d0
	move.w	d0,10(a6)
	swap	d0
	move.w	d0,14(a6)
	rts
FadeItBB:
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$00f,d2
	and.w	#$00f,d3
	cmp.w	d2,d3
	beq.b	Equal1BB
	bgt.b	Greater1BB

	addq.w	#$001,d1
	moveq	#1,d6
	bra.b	Equal1BB
Greater1BB:
	moveq	#1,d6
	subq.w	#$001,d1
Equal1BB:
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$0f0,d2
	and.w	#$0f0,d3
	cmp.w	d2,d3
	beq.b	Equal2BB
	bgt.b	Greater2BB

	moveq	#1,d6
	add.w	#$010,d1
	bra.b	Equal2BB
Greater2BB:
	moveq	#1,d6
	sub.w	#$010,d1
Equal2BB:
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$f00,d2
	and.w	#$f00,d3
	cmp.w	d2,d3
	beq.b	Equal3BB
	bgt.b	Greater3BB

	moveq	#1,d6
	add.w	#$100,d1
	bra.b	Equal3BB
Greater3BB:
	moveq	#1,d6
	sub.w	#$100,d1
Equal3BB:
	rts


spriteposFL:
	lea	manysprFL,a0
	move.l	(a0),a0
	lea	sprFL,a1
	move.w	(a1),d0
	move.w	d0,(a0)
	move.w	d0,$44(a0)
	move.w	d0,$48(a0)
	move.w	d0,$8c(a0)
	and.w	#$ff00,d0
	add.w	#$1000,d0
	move.w	d0,$02(a0)
	move.w	d0,$46(a0)
	bset.l	#7,d0
	move.w	d0,$4a(a0)
	move.w	d0,$8e(a0)
	rts

OkeyG:	lea	singleG,a0
	move.l	8(a0),d0
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	moveq	#3,d1
	bsr.w	setscrG

	WaitBlit
	move.l	singleG,a6
	addq.l	#8,a6
	move.l	a6,$dff054
	move.l	#%00000001000000000000000000000000,$dff040
	move.w	#18+24,$dff066
	move.w	#%110111000001011,$dff058

	lea	obrotG,a0
	lea	sinusG,a6
	
	move.w	alfaG,d0
	add.w	d0,d0
	move.w	(a6,d0.w),(a0)
	add.w	#180,d0
	move.w	(a6,d0.w),2(a0)

	lea	pointsG,a5
	lea	destpG,a4

	moveq	#[pointsendG-pointsG]/6-1,d7
	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

cpr2G:	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5

	add.w	d0,d0
	add.w	d5,d5
	move.w	d0,d2
	move.w	d5,d3
	muls.w	2(a0),d0
	swap	d0
	muls.w	(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	(a0),d2
	swap	d2
	muls.w	2(a0),d5
	swap	d5
	add.w	d2,d5

leftyG:	move.l	#$3080,d6
	asl.l	#3,d5
	sub.l	d5,d6
	muls.w	d6,d0
	muls.w	d6,d1
	swap	d0
	swap	d1
	
	add.w	#152,d0
	add.w	#64,d1

	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2G

	lea	destpG,a4

	move.l	singleG,a5

	move.l	sinuses1p,a3
	move.l	sinuses2p,a6

	WaitBlit
	move.w	#64,$dff060
	move.w	#64,$dff066
	move.l	#$ffff8000,$dff072
	move.l	#$ffffffff,$dff044

	move.w	(a4),d0
	move.w	2(a4),d1
	move.w	4(a4),d2
	move.w	6(a4),d3
	bsr.w	lineG

	KrzG	10,6,8,4

	move.w	8(a4),d0
	move.w	10(a4),d1
	move.w	12(a4),d2
	move.w	14(a4),d3
	bsr.w	lineG

	KrzG	2,14,0,12

	add.l	#$1b80,a5

	move.w	20(a4),d0
	move.w	22(a4),d1
	move.w	16(a4),d2
	move.w	18(a4),d3
	bsr.w	lineG

	KrzG	18,30,16,28

	move.w	28(a4),d0
	move.w	30(a4),d1
	move.w	24(a4),d2
	move.w	26(a4),d3
	bsr.w	lineG

	KrzG	26,22,24,20

	add.l	#$1b80,a5

	move.w	4(a4),d0
	move.w	6(a4),d1
	move.w	20(a4),d2
	move.w	22(a4),d3
	bsr.w	lineG

	KrzG	22,26,20,24

	move.w	24(a4),d0
	move.w	26(a4),d1
	move.w	8(a4),d2
	move.w	10(a4),d3
	bsr.w	lineG

	KrzG	10,6,8,4

	add.l	#$1b80,a5

	move.w	12(a4),d0
	move.w	14(a4),d1
	move.w	28(a4),d2
	move.w	30(a4),d3
	bsr.w	lineG

	KrzG	30,18,28,16

	move.w	16(a4),d0
	move.w	18(a4),d1
	move.w	(a4),d2
	move.w	2(a4),d3
	bsr.w	lineG

	KrzG	2,14,0,12
quityG:	move.l	singleG+4,d0
	add.l	#$1b80*4-12-24,d0
	WaitBlit
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#18+24,$dff064
	move.w	#18+24,$dff066
	move.w	#%110111000001011,$dff058

	lea	alfaG,a0
	lea	dodajG,a1

addlv2G:move.w	(a1),d1
	add.w	d1,(a0)
rep1G:	cmp.w	#360,(a0)
	bmi.b	nookr2G
	sub.w	#360,(a0)
	bra.b	Rep1G

nookr2G:tst.w	(a0)
	bge.b	nookrG
	add.w	#360,(a0)
	bra.b	nookr2G
nookrG:

	lea	plasktabpG,a1
	move.w	(a1),d0
	lea	balltabyG,a2
	move.w	(a2,d0.w),d0

	lea	sprFL,a3
	move.b	d0,(a3)
	move.b	#$88,1(a3)
	lea	SpradG,a6

	jsr	SpritePosFL
	jsr	SetSprAdrFL

	lea	plaskG,a0
	lea	plasktabpG,a1
	lea	plasktabG,a2
	move.w	(a1),d0
	move.w	(a2,d0.w),(a0)

	lea	zezwolG,a3
	btst.b	#0,(a3)
	beq.b	NoyetG

	lea	pointsG,a0
	lea	plasktabyG,a2
	move.w	(a2,d0.w),d0
	move.w	d0,2(a0)
	move.w	d0,8(a0)
	move.w	d0,26(a0)
	move.w	d0,32(a0)

	addq.w	#4,(a1)
	cmp.w	#[endingG-plasktabG],(a1)
	blt.b	noyetG
	clr.w	(a1)

noyetG:
	btst	#1,(a3)
	bne.b	NoShowG
	lea	pointsG,a0
	cmp.w	#-26*zxg,(a0)
	beq.b	ShowedG
	subq.w	#4,(a0)
	subq.w	#4,18(a0)
	subq.w	#4,24(a0)
	subq.w	#4,42(a0)

	lea	PipcikG,a0
	bchg	#0,(a0)
	beq.b	NoShowG
	bchg	#1,(a0)
	beq.b	NoShowG

	lea	colorsG+6,a0
	lea	setcolG,a1
	moveq	#15,d7
FadG:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	FadeItBB
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbra	d7,FadG

	lea	colors2G+6,a0
	lea	setcolG,a1
	moveq	#14,d7
Fad2G:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	FadeItBB
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbra	d7,Fad2G


	bra.b	NoShowG
ShowedG:
	bset	#1,(a3)
	bset	#0,(a3)
NoShowG:
	lea	czasG,a0
	lea	AlarmG,a1
	addq.w	#1,(a0)
	move.w	AlarmG,d0
	cmp.w	(a0),d0
	bne.b	WaitStillG

	lea	scriptposG,a0
	cmp.w	#endscriptG-scriptG,(a0)
	beq.b	waitstillG
	addq.w	#4,(a0)

	move.w	(a0),d0
	lea	DodajG,a1
	move.w	ScriptG-ScriptPosG(a0,d0.w),(a1)
	move.w	ScriptG-ScriptPosG+2(a0,d0.w),AlarmG-ScriptPosG(a0)
	clr.w	CzasG-ScriptPosG(a0)

WaitStillG:
	lea	scriptposG,a0
	cmp.w	#endscriptG-scriptG,(a0)
	bne.b	NoFadeDnG

	lea	PipcikG,a0
	bchg	#0,(a0)
	beq.b	NoFadeDnG
	bchg	#1,(a0)
	beq.b	NoFadeDnG

	moveq	#0,d6
	lea	colorsG+2,a0
	moveq	#31,d7
Fad3G:	move.w	(a0),d1
	move.w	#$fff,d0
	bsr.w	FadeItBB
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbra	d7,Fad3G

	move.b	d6,d5
	moveq	#0,d6
	lea	colors2G+2,a0
	moveq	#15,d7
Fad4G:	move.w	(a0),d1
	move.w	#$fff,d0
	bsr.w	FadeItBB
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbra	d7,Fad4G
	asl.w	#8,d5
	or.w	d5,d6
	tst.w	d6
	bne.w	NoFadeDnG
	move.b	#-1,EndSeq
	rts

NoFadeDnG:
	rts
runG:	lea	FreeGel,a0
	lea	Sinuses1P,a1
	move.l	a0,(a1)
	lea	Sinuses2P,a1
	add.l	#2*ampl*[YgrekG-[Ampl/2]],a0
	move.l	a0,(a1)
	add.l	#2*ampl*[YgrekG-[Ampl/2]],a0

	lea	singleG,a1
	move.l	a0,(a1)
	add.l	#$1b80*4,a0
	move.l	a0,4(a1)
	add.l	#$1b80*4,a0
	move.l	a0,8(a1)

	move.l	sinuses1p,a0
	move.l	sinuses2p,a1

	moveq	#0,d7
tab2G:	lea	sinusfG,a2
	lea	sinusf2G,a3

	move.l	#YgrekG-[Ampl/2]-1,d6

tab1G:	move.w	(a2)+,d0
	muls.w	d7,d0
	divs.w	#ampl,d0
	move.w	d0,(a0)+

	move.w	(a3)+,d0
	muls.w	d7,d0
	divs.w	#ampl,d0
	move.w	d0,(a1)+

	dbra	d6,tab1G
	addq.l	#1,d7
	cmp.l	#ampl,d7
	bne.b	tab2G

	moveq	#3,d1
	bsr.w	setscrG

	lea	SpradG,a6
	bsr.w	SetUpSprites

Waitw:	tst.b	Zez
	beq.b	Waitw

	waitframe
WQW:	cmp.b	#$40,$dff006
	bne.b	WQW

	lea	copperG,a0
	move.l	a0,$dff080
	move.w	d0,$dff088
	waitframe
	lea	OkeyG,a1
	move.l	a1,Vblk_Ptr
myszG:;	waitframe
	tst.b	EndSeq
	bne.b	QuitG
	bra.w	myszG
quitG:	waitframe
	moveq	#0,d6
	lea	colorsG+2,a0
	moveq	#31,d7
Fad5G:	move.w	(a0),d1
	moveq	#0,d0
	bsr.w	FadeItBB
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbra	d7,Fad5G

	move.b	d6,d5
	moveq	#0,d6
	lea	colors2G+2,a0
	moveq	#15,d7
Fad6G:	move.w	(a0),d1
	moveq	#0,d0
	bsr.w	FadeItBB
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbra	d7,Fad6G
	asl.w	#8,d5
	or.w	d5,d6
	tst.w	d6
	bne.w	QuitG

	waitframe
	lea	Vblk_Ptr,a0
	lea	Return_Abs,a1
	move.l	a1,(a0)
	rts

SetUpSprites:
	lea	posFL,a0
	move.w	#270,(a0)
	
	lea	manysprFL,a0
	lea	spr1FL+$3f0,a1
	moveq	#7,d7
crmspFL:
	move.l	a1,(a0)+
	sub.l	#$90,a1
	dbra	d7,crmspFL

	move.w	#$0000,sprFL-posFL(a0)
	jsr	spriteposFL
	jsr	setspradrFL
	rts



*********************************************************************


Fade:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$00f,d2
	and.w	#$00f,d3
	cmp.w	d2,d3
	beq.b	Equal1
	bgt.b	Greater1

	addq.w	#$001,d1
	moveq	#1,d6
	bra.b	Equal1
Greater1:
	moveq	#1,d6
	subq.w	#$001,d1
Equal1:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$0f0,d2
	and.w	#$0f0,d3
	cmp.w	d2,d3
	beq.b	Equal2
	bgt.b	Greater2

	moveq	#1,d6
	add.w	#$010,d1
	bra.b	Equal2
Greater2:
	moveq	#1,d6
	sub.w	#$010,d1
Equal2:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$f00,d2
	and.w	#$f00,d3
	cmp.w	d2,d3
	beq.b	Equal3
	bgt.b	Greater3

	moveq	#1,d6
	add.w	#$100,d1
	bra.b	Equal3
Greater3:
	moveq	#1,d6
	sub.w	#$100,d1
Equal3:	rts

SetPos0:
	lea	SprDat0,a0
	move.w	XPos0,d0
	or.w	#$2c00,d0
	move.w	#$2d82,d1

	move.w	d0,(a0)
	move.w	d1,2(a0)	
	move.w	d0,$408(a0)
	move.w	d1,$40a(a0)

	add.w	#$8,d0
	lea	$810(a0),a0
	move.w	d0,(a0)
	move.w	d1,2(a0)	
	move.w	d0,$408(a0)
	move.w	d1,$40a(a0)

	add.w	#$8,d0
	lea	$810(a0),a0
	move.w	d0,(a0)
	move.w	d1,2(a0)	
	move.w	d0,$408(a0)
	move.w	d1,$40a(a0)
	rts


Whitex:	lea	Cox0+2,a0
	move.w	#$fff,d0
	move.w	d0,(a0)
	move.w	d0,4(a0)
	move.w	d0,8(a0)
	move.w	d0,12(a0)
	rts

CuCube:	bsr.b	Whitex
	clr.l	Counter

	waitframe
	lea	Okey0,a1
	move.l	a1,Vblk_Ptr
	
	waitframe
	lea	copper0,a0
	move.l	a0,$dff084
	lea	SprCopper0,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

mysz0:	move.l	Cmper,d0
	cmp.l	Counter,d0
	blt.b	Quit0

	bra.s	mysz0
	
quit0:	bsr.w	Whitex

	waitframe
	lea	Return_Abs,a1
	move.l	a1,Vblk_Ptr
	rts

PreCuCube:
	lea	destpm,a0
	move.w	#600<<6!63,d0
	jsr	clearscreen_abs
	lea	destpm+600*126,a0
	move.w	#600<<6!63,d0
	jsr	clearscreen_abs

	lea	SprDatFast,a0
	lea	SprDat0,a1
	move.l	#[SprDatEnd-SprDatFast]/4-1,d7
mvspf:	move.l	(a0)+,(a1)+
	dbra	d7,mvspf


	lea	SprDat0,a1
	lea	AdrSpr0,a0
	move.l	a1,d0
	moveq	#5,d7
CSp0:	swap	d0
	move.w	d0,2(a0)
	move.w	d0,2+AdrSpr1-AdrSpr0(a0)
	swap	d0
	move.w	d0,6(a0)
	move.w	d0,6+AdrSpr1-AdrSpr0(a0)
	add.l	#$408,d0
	addq.l	#8,a0
	dbra	d7,CSp0

	lea	EmptySprite0,a1
	move.l	a1,d0
	moveq	#1,d7
CAp0:	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	addq.l	#8,a0
	dbra	d7,CAp0

	bsr.w	SetPos0

	lea	pstr0,a0
	moveq	#[pstrend0-pstr0]/2-1,d7
stilp0:	move.w	(a0)+,d0
	bmi.b	stil0
	asl.w	#2,d0
	move.w	d0,-2(a0)
stil0:	dbra	d7,stilp0

	lea	mul400,a0
	moveq	#0,d0
lopklop0:move.l	d0,d1
	mulu.w	#40,d1
	move.w	d1,(a0)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.b	lopklop0

	lea	single0,a1
	lea	screen0,a0
	move.l	a0,(a1)
	add.l	#$4fb0,a0
	move.l	a0,4(a1)
	add.l	#$4fb0,a0
	move.l	a0,8(a1)
	add.l	#$4fb0,a0
	move.l	a0,12(a1)

	moveq	#1,d1
	bsr.w	setscr0
	move.l	single0+12,a0
	
qw0=31
	lea	face00,a3
	move.l	#[pointsend0-points0]/6-1,d7
setout0:
	move.w	#qw0*vx0,4(a3)
	move.w	#-qw0*vx0,face10-face00+4(a3)
	move.w	#-qw0*vx0,face20-face00+2(a3)
	move.w	#qw0*vx0,face30-face00+2(a3)
	move.w	#qw0*vx0,face40-face00(a3)
	move.w	#-qw0*vx0,face50-face00(a3)
	addq.l	#6,a3
	dbra	d7,setout0
	rts


okey0:	lea	Cox0+2,a0
	lea	Pax,a1
	moveq	#3,d7
FDG:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FDG

	cmp.w	#EndSX0-SinX0,PPos0
	beq.b	Mkop0
	lea	SinX0,a0
	move.w	Ppos0,d0
	move.w	(a0,d0.w),Xpos0
	bsr.w	SetPos0
	addq.w	#2,Ppos0
Mkop0:
	lea	single0,a0
	move.l	8(a0),d0
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	moveq	#1,d1
	bsr.w	setscr0

	bsr.w	clear0

	lea	destp0,a4
	lea	points0,a5
	moveq	#[pointsend0-points0]/6-1,d7
	lea	sinus0,a6
	lea	alfowe0,a0

	move.w	alfa0,d2
	add.w	d2,d2
	move.w	(a6,d2.w),(a0)
	add.w	#180,d2
	move.w	(a6,d2.w),2(a0)	

	move.w	alfa0+2,d2
	add.w	d2,d2
	move.w	(a6,d2.w),4(a0)
	add.w	#180,d2
	move.w	(a6,d2.w),6(a0)	

	move.w	alfa0+4,d2
	add.w	d2,d2
	move.w	(a6,d2.w),8(a0)
	add.w	#180,d2
	move.w	(a6,d2.w),10(a0)	

cpr20:
	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5

	add.w	d0,d0
	move.w	d0,d2
	add.w	d5,d5
	move.w	d5,d3
	muls.w	2(a0),d0
	swap	d0
	muls.w	(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	(a0),d2
	swap	d2
	muls.w	2(a0),d5
	swap	d5
	add.w	d2,d5

	add.w	d5,d5
	move.w	d5,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	6(a0),d5
	swap	d5
	muls.w	4(a0),d3
	swap	d3
	sub.w	d3,d5
	muls.w	4(a0),d2
	swap	d2
	muls.w	6(a0),d1
	swap	d1
	add.w	d2,d1

	add.w	d0,d0
	move.w	d0,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	10(a0),d0
	swap	d0
	muls.w	8(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	8(a0),d2
	swap	d2
	muls.w	10(a0),d1
	swap	d1
	add.w	d2,d1

	move.w	d5,d4
	move.w	#$3000,d6
	asl.w	#3,d4
	sub.w	d4,d6
	muls.w	d6,d0
	muls.w	d6,d1
	swap	d0
	swap	d1

	move.w	d0,(a4)+
	move.w	d1,(a4)+

	dbra	d7,cpr20


	lea	face00,a3
	lea	destx0,a4
	lea	points0,a5
	moveq	#[pointsend0-points0]/6-1,d7
	lea	sinus0,a6
	lea	alfowe20,a0

	move.w	alfa20,d2
	add.w	d2,d2
	move.w	(a6,d2.w),(a0)
	add.w	#180,d2
	move.w	(a6,d2.w),2(a0)	

	move.w	alfa20+2,d2
	add.w	d2,d2
	move.w	(a6,d2.w),4(a0)
	add.w	#180,d2
	move.w	(a6,d2.w),6(a0)	

	move.w	alfa20+4,d2
	add.w	d2,d2
	move.w	(a6,d2.w),8(a0)
	add.w	#180,d2
	move.w	(a6,d2.w),10(a0)	

cprx20:	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5

	add.w	d0,d0
	move.w	d0,d2
	add.w	d5,d5
	move.w	d5,d3
	muls.w	2(a0),d0
	swap	d0
	muls.w	(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	(a0),d2
	swap	d2
	muls.w	2(a0),d5
	swap	d5
	add.w	d2,d5

	add.w	d5,d5
	move.w	d5,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	6(a0),d5
	swap	d5
	muls.w	4(a0),d3
	swap	d3
	sub.w	d3,d5
	muls.w	4(a0),d2
	swap	d2
	muls.w	6(a0),d1
	swap	d1
	add.w	d2,d1

	add.w	d0,d0
	move.w	d0,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	10(a0),d0
	swap	d0
	muls.w	8(a0),d3
	swap	d3
	sub.w	d3,d0
	muls.w	8(a0),d2
	swap	d2
	muls.w	10(a0),d1
	swap	d1
	add.w	d2,d1

	move.w	d5,d4
	move.w	#$2a00,d6
	asl.w	#3,d4
	sub.w	d4,d6
	muls.w	d6,d0
	muls.w	d6,d1
	swap	d0
	swap	d1

	move.w	d0,(a4)+
	move.w	d1,(a4)+

	asl.w	#2,d0
	asl.w	#2,d1

	move.w	d0,(a3)
	move.w	d1,2(a3)

	move.w	d0,face10-face00(a3)
	move.w	d1,face10-face00+2(a3)

	move.w	d0,face20-face00(a3)
	move.w	d1,face20-face00+4(a3)

	move.w	d0,face30-face00(a3)
	move.w	d1,face30-face00+4(a3)

	move.w	d0,face40-face00+2(a3)
	move.w	d1,face40-face00+4(a3)

	move.w	d0,face50-face00+2(a3)
	move.w	d1,face50-face00+4(a3)
	addq.l	#6,a3

	dbra	d7,cprx20

	lea	destx0,a0
	lea	hideptr20,a3
	clr.b	(a3)
	bsr.w	checkhiding0
	move.l	a3,a2

	lea	destp0,a0
	lea	hideptr0,a3
	clr.b	(a3)
	bsr.w	checkhiding0

	waitblit
	move.w	#40,$dff060
	move.w	#40,$dff066
	move.l	#$ffff8000,$dff072
	move.l	#$ffffffff,$dff044


	btst	#0,(a3)
	beq.b	xhide000
	lea	dest00,a0
	lea	face00,a1
	bsr.w	rotatnij0
	lea	dest00,a0
	bsr.w	drawnij0
xhide000:

	btst	#1,(a3)
	beq.b	xhide010
	lea	dest00,a0
	lea	face10,a1
	bsr.w	rotatnij0
	lea	dest00,a0
	bsr.w	drawnij0
xhide010:
	btst	#2,(a3)
	beq.b	xhide020
	lea	dest00,a0
	lea	face20,a1
	bsr.w	rotatnij0
	lea	dest00,a0
	bsr.w	drawnij0
xhide020:

	btst	#3,(a3)
	beq.b	xhide030
	lea	dest00,a0
	lea	face30,a1
	bsr.w	rotatnij0
	lea	dest00,a0
	bsr.w	drawnij0
xhide030:

	btst	#4,(a3)
	beq.b	xhide040
	lea	dest00,a0
	lea	face40,a1
	bsr.w	rotatnij0
	lea	dest00,a0
	bsr.w	drawnij0
xhide040:

	btst	#5,(a3)
	beq.b	xhide050
	lea	dest00,a0
	lea	face50,a1
	bsr.w	rotatnij0
	lea	dest00,a0
	bsr.w	drawnij0
xhide050:

	lea	destp0,a0
	move.l	a3,a2
	bsr.w	drawnij0

quity0:
	lea	alfa0,a0
	lea	dodaj0,a1
	moveq	#5,d0
addlv20:	move.w	(a1),d1
	add.w	d1,(a0)
	cmp.w	#360,(a0)
	blt.b	nookr20
	sub.w	#360,(a0)
nookr20:	tst.w	(a0)
	bpl.b	nookr30
	add.w	#360,(a0)
nookr30:
	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,addlv20
	bsr.w	fill0

	addq.w	#1,timer0
	move.w	alarm0,d0
	cmp.w	timer0,d0
	bne.b	notyeti0

oncem0:	lea	script0,a0
	add.l	#14,scriptpos0
	add.l	scriptpos0,a0
	move.w	(a0)+,alarm0
	bne.b	nozero0
	clr.l	scriptpos0
	bra.b	oncem0
nozero0:	move.w	(a0)+,dodaj0
	move.w	(a0)+,dodaj0+2
	move.w	(a0)+,dodaj0+4
	move.w	(a0)+,dodaj20
	move.w	(a0)+,dodaj20+2
	move.w	(a0)+,dodaj20+4
	clr.w	timer0

notyeti0:
	rts

drawnij0:
	lea	mul400,a4
	move.l	single0+4,a5
	lea	$dff000,a6


	btst.b	#0,(a2)
	beq.w	hide000

	movem.w	(a0),d0-d3
	bsr.w	line0
	move.w	4(a0),d0
	move.w	6(a0),d1
	move.w	12(a0),d2
	move.w	14(a0),d3
	bsr.w	line0
	move.w	12(a0),d0
	move.w	14(a0),d1
	move.w	8(a0),d2
	move.w	10(a0),d3
	bsr.w	line0
	move.w	8(a0),d0
	move.w	10(a0),d1
	move.w	(a0),d2
	move.w	2(a0),d3
	bsr.w	line0

	add.l	#$1770,a5
	movem.w	(a0),d0-d3
	bsr.w	line0
	move.w	4(a0),d0
	move.w	6(a0),d1
	move.w	12(a0),d2
	move.w	14(a0),d3
	bsr.w	line0
	move.w	12(a0),d0
	move.w	14(a0),d1
	move.w	8(a0),d2
	move.w	10(a0),d3
	bsr.w	line0
	move.w	8(a0),d0
	move.w	10(a0),d1
	move.w	(a0),d2
	move.w	2(a0),d3
	bsr.w	line0

hide000:

	btst.b	#1,(a2)
	beq.w	hide010

	move.l	single0+4,a5

	move.w	6*4(a0),d0
	move.w	6*4+2(a0),d1
	move.w	7*4(a0),d2
	move.w	7*4+2(a0),d3
	bsr.w	line0
	move.w	7*4(a0),d0
	move.w	7*4+2(a0),d1
	move.w	5*4(a0),d2
	move.w	5*4+2(a0),d3
	bsr.w	line0
	move.w	5*4(a0),d0
	move.w	5*4+2(a0),d1
	move.w	4*4(a0),d2
	move.w	4*4+2(a0),d3
	bsr.w	line0
	move.w	4*4(a0),d0
	move.w	4*4+2(a0),d1
	move.w	6*4(a0),d2
	move.w	6*4+2(a0),d3
	bsr.w	line0

	add.l	#$1770,a5

	move.w	6*4(a0),d0
	move.w	6*4+2(a0),d1
	move.w	7*4(a0),d2
	move.w	7*4+2(a0),d3
	bsr.w	line0
	move.w	7*4(a0),d0
	move.w	7*4+2(a0),d1
	move.w	5*4(a0),d2
	move.w	5*4+2(a0),d3
	bsr.w	line0
	move.w	5*4(a0),d0
	move.w	5*4+2(a0),d1
	move.w	4*4(a0),d2
	move.w	4*4+2(a0),d3
	bsr.w	line0
	move.w	4*4(a0),d0
	move.w	4*4+2(a0),d1
	move.w	6*4(a0),d2
	move.w	6*4+2(a0),d3
	bsr.w	line0

hide010:
	btst.b	#2,(a2)
	beq.b	hide020

	move.l	single0+4,a5

	move.w	4*4(a0),d0
	move.w	4*4+2(a0),d1
	move.w	5*4(a0),d2
	move.w	5*4+2(a0),d3
	bsr.w	line0
	move.w	5*4(a0),d0
	move.w	5*4+2(a0),d1
	move.w	1*4(a0),d2
	move.w	1*4+2(a0),d3
	bsr.w	line0
	move.w	1*4(a0),d0
	move.w	1*4+2(a0),d1
	move.w	0*4(a0),d2
	move.w	0*4+2(a0),d3
	bsr.w	line0
	move.w	0*4(a0),d0
	move.w	0*4+2(a0),d1
	move.w	4*4(a0),d2
	move.w	4*4+2(a0),d3
	bsr.w	line0

hide020:

	btst.b	#3,(a2)
	beq.b	hide030

	move.l	single0+4,a5

	move.w	2*4(a0),d0
	move.w	2*4+2(a0),d1
	move.w	3*4(a0),d2
	move.w	3*4+2(a0),d3
	bsr.w	line0
	move.w	3*4(a0),d0
	move.w	3*4+2(a0),d1
	move.w	7*4(a0),d2
	move.w	7*4+2(a0),d3
	bsr.w	line0
	move.w	7*4(a0),d0
	move.w	7*4+2(a0),d1
	move.w	6*4(a0),d2
	move.w	6*4+2(a0),d3
	bsr.w	line0
	move.w	6*4(a0),d0
	move.w	6*4+2(a0),d1
	move.w	2*4(a0),d2
	move.w	2*4+2(a0),d3
	bsr.w	line0

hide030:

	btst.b	#4,(a2)
	beq.b	hide040

	move.l	single0+4,a5
	add.l	#$1770,a5

	move.w	1*4(a0),d0
	move.w	1*4+2(a0),d1
	move.w	5*4(a0),d2
	move.w	5*4+2(a0),d3
	bsr.w	line0
	move.w	5*4(a0),d0
	move.w	5*4+2(a0),d1
	move.w	7*4(a0),d2
	move.w	7*4+2(a0),d3
	bsr.w	line0
	move.w	7*4(a0),d0
	move.w	7*4+2(a0),d1
	move.w	3*4(a0),d2
	move.w	3*4+2(a0),d3
	bsr.w	line0
	move.w	3*4(a0),d0
	move.w	3*4+2(a0),d1
	move.w	1*4(a0),d2
	move.w	1*4+2(a0),d3
	bsr.w	line0

hide040:
	btst.b	#5,(a2)
	beq.b	hide050

	move.l	single0+4,a5
	add.l	#$1770,a5

	move.w	0*4(a0),d0
	move.w	0*4+2(a0),d1
	move.w	2*4(a0),d2
	move.w	2*4+2(a0),d3
	bsr.w	line0
	move.w	2*4(a0),d0
	move.w	2*4+2(a0),d1
	move.w	6*4(a0),d2
	move.w	6*4+2(a0),d3
	bsr.w	line0
	move.w	6*4(a0),d0
	move.w	6*4+2(a0),d1
	move.w	4*4(a0),d2
	move.w	4*4+2(a0),d3
	bsr.w	line0
	move.w	4*4(a0),d0
	move.w	4*4+2(a0),d1
	move.w	0*4(a0),d2
	move.w	0*4+2(a0),d3
	bsr.w	line0

hide050:
	rts


rotatnij0:
	move.l	#[pointsend0-points0]/6-1,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5
	lea	sinus0,a6
	lea	alfowe0,a5

xcpr20:	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d5

	add.w	d0,d0
	move.w	d0,d2
	add.w	d5,d5
	move.w	d5,d3
	muls.w	2(a5),d0
	swap	d0
	muls.w	(a5),d3
	swap	d3
	sub.w	d3,d0
	muls.w	(a5),d2
	swap	d2
	muls.w	2(a5),d5
	swap	d5
	add.w	d2,d5

	add.w	d5,d5
	move.w	d5,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	6(a5),d5
	swap	d5
	muls.w	4(a5),d3
	swap	d3
	sub.w	d3,d5
	muls.w	4(a5),d2
	swap	d2
	muls.w	6(a5),d1
	swap	d1
	add.w	d2,d1

	add.w	d0,d0
	move.w	d0,d2
	add.w	d1,d1
	move.w	d1,d3
	muls.w	10(a5),d0
	swap	d0
	muls.w	8(a5),d3
	swap	d3
	sub.w	d3,d0
	muls.w	8(a5),d2
	swap	d2
	muls.w	10(a5),d1
	swap	d1
	add.w	d2,d1

	move.w	d5,d4
	move.w	#$2600,d6
	asl.w	#2,d4
	sub.w	d4,d6
	muls.w	d6,d0
	muls.w	d6,d1
	swap	d0
	swap	d1

	move.w	d0,(a0)+
	move.w	d1,(a0)+

	dbra	d7,xcpr20

	rts

checkhiding0:
	move.w	(a0),d0
	sub.w	4(a0),d0
	move.w	8+2(a0),d1
	sub.w	4+2(a0),d1
	mulu.w	d1,d0
	move.w	4(a0),d1
	sub.w	8(a0),d1
	move.w	4+2(a0),d2
	sub.w	2(a0),d2
	mulu.w	d2,d1
	cmp.w	d1,d0
	ble.w	nhide000
	bset.b	#0,(a3)
nhide000:
	move.w	6*4(a0),d0
	sub.w	5*4(a0),d0
	move.w	7*4+2(a0),d1
	sub.w	5*4+2(a0),d1
	mulu.w	d1,d0
	move.w	5*4(a0),d1
	sub.w	7*4(a0),d1
	move.w	5*4+2(a0),d2
	sub.w	6*4+2(a0),d2
	mulu.w	d2,d1
	cmp.w	d1,d0
	bpl.w	nhide010
	bset.b	#1,(a3)
nhide010:

	move.w	4*4(a0),d0
	sub.w	1*4(a0),d0
	move.w	5*4+2(a0),d1
	sub.w	1*4+2(a0),d1
	mulu.w	d1,d0
	move.w	1*4(a0),d1
	sub.w	5*4(a0),d1
	move.w	1*4+2(a0),d2
	sub.w	4*4+2(a0),d2
	mulu.w	d2,d1
	cmp.w	d1,d0
	bpl.w	nhide020
	bset.b	#2,(a3)
nhide020:
	move.w	2*4(a0),d0
	sub.w	7*4(a0),d0
	move.w	3*4+2(a0),d1
	sub.w	7*4+2(a0),d1
	mulu.w	d1,d0
	move.w	7*4(a0),d1
	sub.w	3*4(a0),d1
	move.w	7*4+2(a0),d2
	sub.w	2*4+2(a0),d2
	mulu.w	d2,d1
	cmp.w	d1,d0
	bpl.w	nhide030
	bset.b	#3,(a3)
nhide030:

	move.w	1*4(a0),d0
	sub.w	7*4(a0),d0
	move.w	5*4+2(a0),d1
	sub.w	7*4+2(a0),d1
	mulu.w	d1,d0
	move.w	7*4(a0),d1
	sub.w	5*4(a0),d1
	move.w	7*4+2(a0),d2
	sub.w	1*4+2(a0),d2
	mulu.w	d2,d1
	cmp.w	d1,d0
	bpl.w	nhide040
	bset.b	#4,(a3)
nhide040:
	move.w	0*4(a0),d0
	sub.w	6*4(a0),d0
	move.w	2*4+2(a0),d1
	sub.w	6*4+2(a0),d1
	mulu.w	d1,d0
	move.w	6*4(a0),d1
	sub.w	2*4(a0),d1
	move.w	6*4+2(a0),d2
	sub.w	0*4+2(a0),d2
	mulu.w	d2,d1
	cmp.w	d1,d0
	bpl.w	nhide050
	bset.b	#5,(a3)
nhide050:

	rts

line0:
	add.w	#155,d0
	add.w	#155,d2
	add.w	#120,d1
	add.w	#120,d3
	cmp.w	d3,d1
	bne.b	l_quit0
	rts
l_quit0:
	bhi.b	l_noych0
	exg.l	d0,d2
	exg.l	d1,d3

l_noych0:subq.w	#1,d1

	moveq	#0,d4
	move.w	d1,d4
	add.w	d4,d4
	move.w	(a4,d4.w),d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a5,d4

	moveq	#0,d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.b	y2Gy10
	neg.w	d3
y2Gy10:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx10
	neg.w	d2
x2Gx10:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdx0
	exg.l	d2,d3
dyGdx0:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsF0(pc,d5.w),d5

WBlit0:	btst.b	#14,$02(a6)
	bne.b	WBlit0

	move.w	d2,$62(a6)
	sub.w	d3,d2
	bge.b	SignNl0
	or.b	#$40,d5
SignNl0:
	move.w	d2,$52(a6)
	sub.w	d3,d2
	move.w	d2,$64(a6)
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0b4a,d0
	move.w	d0,$40(a6)
	move.w	d5,$42(a6)
	move.l	d4,$48(a6)
	move.l	d4,$54(a6)

	addq.w	#1,d3
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$58(a6)
	rts

OctantsF0:
	dc.b	3,19,11,23,7,27,15,31



clear0:	waitblit
	move.l	single0,a6
	add.l	#8+40*40,a6
	move.l	a6,$dff054
	move.l	#%00000001000000000000000000000000,$dff040
	move.w	#18,$dff066
	move.w	#[160*2<<6]!11,$dff058
	rts

fill0:	move.l	single0+4,d0
	add.l	#$1770*2+40*40-12,d0
	waitblit
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#18,$dff064
	move.w	#18,$dff066
	move.w	#[160*2<<6]!11,$dff058
	rts


setscr0:move.l	single0+8,d0
	add.l	#40*44-2,d0
	lea	c110,a1
clop0:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1770,d0
	dbra	d1,clop0
	rts



**************************************************************************

fig:	dc.l	0
CHGR:	dc.w	0

okey:	tst.w	Copper+[Col0-PCopper]+2
	beq.b	NoFC0

	lea	Copper+[col0-PCopper]+2,a0
	move.w	(a0),d1
	move.w	Bcgra,d0
	bsr.w	fade
	move.w	d1,(a0)
	move.w	d1,4(a0)
	move.w	d1,8(a0)
	move.w	d1,12(a0)
	move.w	d1,16(a0)
	move.w	d1,20(a0)
	move.w	d1,24(a0)
NoFC0:	lea	Copper+[col1-PCopper]+2,a0
	move.l	PalAdr,a1
	moveq	#6,d7
FDH:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FDH

	add.l	#32,shrinker
	cmp.l	#PosY2-PosY1,shrinker
	blt.b	NoZer
	clr.l	shrinker
NoZer:
	lea	Copper+[make-PCopper]+$50,a0
	move.l	picadr,a1
	lea	40*20(a1),a1
	lea	data,a3
	lea	dane2,a4
	lea	mul40,a5
	lea	PosY1,a6

	move.l	shrinker,d0
	move.w	(a6,d0.l),d1
	move.w	d1,d2

	mulu.w	#40,d1
	neg.w	d1
	lea	(a1,d1.w),a1
	move.l	a1,d1
	swap	d1
	move.w	d1,Copper+[c11-Pcopper]+2
	swap	d1
	move.w	d1,Copper+[c11-Pcopper]+6
	add.l	#$1f40,d1
	swap	d1
	move.w	d1,Copper+[c11-Pcopper]+2+8
	swap	d1
	move.w	d1,Copper+[c11-Pcopper]+6+8
	add.l	#$1f40,d1
	swap	d1
	move.w	d1,Copper+[c11-Pcopper]+2+16
	swap	d1
	move.w	d1,Copper+[c11-Pcopper]+6+16

	mulu.w	#$50,d2
	lea	(a0,d2.w),a0

	move.w	2(a6,d0.l),d0
	ext.l	d0

	beq.w	SkipFace
	move.l	d0,d7

	moveq	#112,d6
	sub.w	d0,d6
	move.w	d6,d5

	clr.w	-6(a0)
	clr.w	-6-4(a0)

	divu.w	#7,d6
	cmp.w	#7,d6
	ble.b	leb2
	moveq	#7,d6
Leb2:	asl.w	#8,d6
	lea	(a4,d6.w),a4

	move.l	#112<<8,d1
	divu.w	d0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

Fuck:	add.w	d1,d2
	move.w	d2,d3
	asr.w	#8,d3
 	sub.w	d3,d4
	neg.w	d4
	add.w	d4,d4
	lea	(a4,d4.w),a4

	move.w	(a5,d4.w),d4	
	move.w	(a4),d5
	lea	(a3,d5.w),a2

	moveq	#15,d5
makel:	addq.l	#2,a0
	move.w	(a2)+,(a0)+
	dbra	d5,makel

	move.w	d4,6(a0)
	move.w	d4,10(a0)	
	move.w	d3,d4
	lea	16(a0),a0
	dbra	d7,Fuck

	move.w	#-40*112,-16+6(a0)
	move.w	#-40*112,-16+10(a0)
SkipFace:
	lea	pic,a1
	lea	data,a3
	lea	dane,a4
	lea	mul40,a5
	lea	PosY2,a6

	move.l	shrinker,d0
	move.w	2(a6,d0.l),d0

	beq.w	SkipFace2
	move.l	d0,d7

	moveq	#112,d6
	sub.w	d0,d6

	move.w	d6,d5

	divu.w	#7,d6
	cmp.w	#7,d6
	ble.b	leb
	move.w	#7,d6
Leb:	asl.w	#8,d6
	lea	(a4,d6.w),a4

	move.l	#112<<8,d1
	divu.w	d0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

Fuck2:	add.w	d1,d2
	move.w	d2,d3
	asr.w	#8,d3
 	sub.w	d3,d4
	neg.w	d4
	add.w	d4,d4
	lea	(a4,d4.w),a4
	move.w	(a5,d4.w),d4	

	move.w	(a4),d5
	lea	(a3,d5.w),a2

	moveq	#15,d5
makel2:	addq.l	#2,a0
	move.w	(a2)+,(a0)+
	dbra	d5,makel2

	move.w	d4,6(a0)
	move.w	d4,10(a0)	
	move.w	d3,d4
	lea	16(a0),a0
	dbra	d7,Fuck2
	clr.w	$50-16+6(a0)
	clr.w	$50-16+10(a0)
	move.w	#120,-16+6(a0)
	move.w	#120,-16+10(a0)

SkipFace2:
	rts


Whiten0:move.w	#$fff,d1
	moveq	#6,d7
	lea	Copper+[col1-PCopper],a0
wh1:	move.w	d1,2(a0)
	addq.l	#4,a0
	dbra	d7,wh1

	moveq	#7,d7
	lea	Copper+[col0-PCopper],a0
wh2:	move.w	d1,2(a0)
	addq.l	#4,a0
	dbra	d7,wh2

	rts

lines=240

Cube:	bsr.w	Whiten0
	lea	Copper+[c11-Pcopper],a0
	move.l	picadr,d0
	moveq	#4,d7
crw:	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	addq.l	#8,a0
	add.l	#$1f40,d0
	dbra	d7,crw

	clr.l	Counter
	waitframe
	lea	copper,a0
	move.l	a0,$dff084
	lea	sprcopper0,a0
	move.l	a0,$dff080
	clr.w	$dff088

	waitframe
	lea	Okey,a1
	move.l	a1,Vblk_Ptr

main:	move.l	Cmper,d0
	cmp.l	Counter,d0
	blt.b	QuitM
	bra.w	main

QuitM:	
	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr
	rts

PreCube:
	lea	Copper,a0
	lea	Pcopper,a1
	move.l	#[Make-PCopper]/2-1,d7
MVCO:	move.w	(a1)+,(a0)+
	dbra	d7,MVCO

	lea	mulm40,a0
	move.l	#-$101,d0
muluj:	move.l	d0,d1
	muls.w	#40,d1
	move.w	d1,(a0)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.b	muluj

	lea	Copper+[make-Pcopper],a0
	moveq	#95,d7
makek2:	moveq	#15,d6
makek:	move.l	#$01020000,(a0)+
	dbra	d6,makek

	move.l	#$01020000,(a0)+
	move.l	#$01080000,(a0)+
	move.l	#$010a0000,(a0)+
	move.b	d7,(a0)+
	move.b	#$79,(a0)+
	move.w	#$fffe,(a0)+
	addq.w	#1,d7
	cmp.w	#$ff,d7
	bne.b	makek2

	move.l	#$00902c00,(a0)+
	move.l	#-2,(a0)+
	rts


*********************************************************************
linesM=230
color0M=$246
color1M=$9db
color2M=$7b9
color3M=$597

CubePoints:
	bsr.w	WhitenM
	waitframe
	lea	copperM,a0
	move.l	a0,$dff080
	move.w	d0,$dff088
	waitframe
	lea	AdderM,a1
	move.l	a1,Vblk_Ptr

	clr.l	CounterM

	wAITFRAME
myszM:	move.l	Cmper,d0
	cmp.l	CounterM,d0
	blt.w	QuitAM
	tst.w	PipaM
	beq.b	apapM
	bsr.w	OkeyM
apapM:
	waitframe0
	bra.s	myszM
QuitAM:	bsr.b	WhitenM
	lea	Return_Abs,a1
	move.l	a1,Vblk_Ptr
	rts

AdderM:	addq.l	#1,CounterM
	tst.w	PipaM
	bne.b	lubek
	bsr.w	OkeyM
lubek:	rts
PipaM:	dc.w	0

WhitenM:move.w	#$0fff,d0
	move.w	d0,ColM+2
	move.w	d0,ColM+2+4
	move.w	d0,ColM+2+8
	move.w	d0,ColM+2+12
	move.w	d0,ColM+2+16
	move.w	d0,ColrM+2
	move.w	d0,ColrM+2+4
	move.w	d0,ColrM+2+8
	move.w	d0,ColrM+2+12
	rts

PreCubePoints:
	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr
	waitframe

	lea	SinXM,a0
	move.l	#$270/4-1,d7
CVBM:	clr.l	(a0)+
	dbra	d7,CVBM
	lea	crM,a0
	moveq	#0,d0
creM:	move.l	d0,(a0)+
	addq.l	#1,d0
	cmp.l	#50,d0
	bne.b	CreM

cre2M:	move.l	d0,(a0)+
	subq.l	#1,d0
	bne.b	Cre2M
	bsr.w	setobjM

	lea	pstrM,a0
	moveq	#[pstrendM-pstrM]/2-1,d7
stilpM:	move.w	(a0)+,d0
	bmi.b	stilM
	asl.w	#2,d0
	move.w	d0,-2(a0)
stilM:	dbra	d7,stilpM

	lea	pstr2M,a0
	moveq	#[pstrend2M-pstr2M]/2-1,d7
stilp2M:move.w	(a0)+,d0
	bmi.b	stil2M
	asl.w	#2,d0
	move.w	d0,-2(a0)
stil2M:	dbra	d7,stilp2M

	lea	pstr3M,a0
	moveq	#[pstrend3M-pstr3M]/2-1,d7
stilp3M:move.w	(a0)+,d0
	bmi.b	stil3M
	asl.w	#2,d0
	move.w	d0,-2(a0)
stil3M:	dbra	d7,stilp3M

	lea	mul40M,a0
	moveq	#0,d0
lopklopM:move.l	d0,d1
	mulu.w	#40,d1
	move.w	d1,(a0)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.b	lopklopM

	lea	singleM,a1
	lea	screenM,a0
	move.l	a0,(a1)
	add.l	#$4fb0,a0
	move.l	a0,4(a1)
	add.l	#$4fb0,a0
	move.l	a0,8(a1)
	add.l	#$4fb0,a0
	move.l	a0,12(a1)

	moveq	#1,d1
	bsr.w	setscrM
	move.l	singleM+12,a0

	moveq	#0,d3
bs4M:	moveq	#0,d2
	moveq	#19,d1
bs2M:	moveq	#0,d0
bs1M:	subq.w	#1,d2
	bpl.b	bs3M
	move.w	d3,d2
	bset.b	d0,(a0,d1.w)
bs3M:	addq.b	#1,d0
	cmp.b	#8,d0
	bne.b	bs1M
	dbra	d1,bs2M
	add.l	#40,a0
	addq.w	#1,d3
	cmp.w	#100,d3
	bne.b	bs4M

	move.l	singleM+12,a0
	add.l	#19,a0
	moveq	#0,d3
ba4M:	moveq	#7,d2
	moveq	#0,d1
ba2M:	moveq	#7,d0
ba1M:	subq.w	#1,d2
	bpl.b	ba3M
	move.w	d3,d2
	bset.b	d0,(a0,d1.w)
ba3M:	dbra	d0,ba1M
	addq.w	#1,d1
	cmp.w	#20,d1
	bne.b	ba2M
	add.l	#40,a0
	addq.w	#1,d3
	cmp.w	#100,d3
	bne.b	ba4M

	lea	makeM,a0
	moveq	#$41,d6
	move.l	#linesM-1,d7
ccopM:	cmp.w	#$0102,d6
	bne.b	nylM
	move.l	#$ffddfffe,(a0)+
nylM:	move.l	#$01860000,(a0)+
	move.l	#$018c0000,(a0)+
	move.l	#$018e0000,(a0)+
	move.b	d6,(a0)+
	move.b	#$07,(a0)+
	move.w	#$fffe,(a0)+
	addq.w	#1,d6
	dbra	d7,ccopM
	rts

zetM:	MACRO
	moveq	#0,d4
	move.w	d5,d4
leftyM:	move.l	#$1000,d6
	asl.l	#3,d4
	sub.l	d4,d6
	muls.w	d6,d0
	muls.w	d6,d1
	swap	d0
	swap	d1
	exg	d4,d5
	ENDM

rotateM:MACRO
	add.w	d2,d2
	lea	sinusM,a6
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
	
okeyM:	cmp.w	#Color0M,ColM+2
	beq.b	NoFDM

	move.w	ColM+2,d1
	move.w	#Color0M,d0
	bsr.w	Fade
	move.w	d1,ColM+2
	move.w	d1,ColM+2+4
	move.w	d1,ColM+2+8
	move.w	d1,ColM+2+12
	move.w	d1,ColM+2+16

	move.w	ColrM+2,d1
	move.w	#Color1M,d0
	bsr.w	Fade
	move.w	d1,ColrM+2
	move.w	ColrM+6,d1
	move.w	#Color2M,d0
	bsr.w	Fade
	move.w	d1,ColrM+6
	move.w	ColrM+10,d1
	move.w	#Color3M,d0
	bsr.w	Fade
	move.w	d1,ColrM+10
	move.w	ColrM+14,d1
	move.w	#Color0M,d0
	bsr.w	Fade
	move.w	d1,ColrM+14

NoFDM:	lea	singleM,a0
	move.l	8(a0),d0
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	moveq	#1,d1
	bsr.w	setscrM
	bsr.w	clearM

	lea	destpM,a4
	move.l	pointspM,a5
	move.l	pointslM,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

cpr2M:	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5
	move.w	alfaM,d2
	exg	d1,d5
	ROTATEM
	exg	d1,d5
	move.w	alfaM+2,d2
	exg	d0,d5
	ROTATEM
	exg	d0,d5
	move.w	alfaM+4,d2
	ROTATEM
	ZETM
	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2M

	lea	y1M,a0
	lea	dodpM,a1
	lea	bplpM,a2
	lea	hideM,a3
	lea	destpM,a4
	lea	scractM,a5
	move.l	singleM,(a5)
	move.l	pstrpM,a6

	move.w	(a6)+,d0
	move.w	d0,(a1)
	move.w	d0,2(a1)

reptM:	tst.l	(a3)
	bne.b	rept2M

	move.w	(a1),d3
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
	bpl.b	rept2M

waitM:	move.w	(a6)+,d0
	bpl.b	waitM	
	cmp.b	#-4,d0
	beq.b	waitM
	subq.l	#2,a6

rept2M:	move.w	(a6)+,d0
	bpl.b	plukM
	cmp.b	#-1,d0
	beq.b	quityM
	move.w	d0,d6
	moveq	#0,d7
	move.w	(a6)+,d7
	move.l	(a2,d7.w),d7
	add.l	singleM,d7
	move.w	2(a1),d0
	move.w	(a1),d1
	move.w	d0,(a1)
	move.w	(a4,d0.w),4(a0)
	move.w	2(a4,d0.w),(a0)
	move.w	(a4,d1.w),6(a0)
	move.w	2(a4,d1.w),2(a0)
	bsr.w	lineM
	move.w	(a6),(a1)
	move.w	(a6)+,2(a1)
	move.l	d7,(a5)
	cmp.b	#-4,d6
	beq.b	rept2M
	bra.w	reptM

plukM:	move.w	(a1),d1
	move.w	d0,(a1)
	move.w	(a4,d0.w),4(a0)
	move.w	2(a4,d0.w),(a0)
	move.w	(a4,d1.w),6(a0)
	move.w	2(a4,d1.w),2(a0)
	bsr.w	lineM
	bra.b	rept2M
	rts
	
quityM:
	bsr.w	fillM
	lea	posxM,a0
	addq.b	#1,3(a0)
	cmp.b	#[CrM-SinXM]/4,3(a0)
	bne.b	NoChM
	move.b	#-1,PipaM
NoChM:	tst.b	3(a0)
	bne.b	NoChM2
	clr.b	PipaM
NoChM2:	cmp.b	#[maximumM-SinXM]/4,3(a0)
	bne.b	noobjcgM
	bsr.w	setobjM

noobjcgM:lea	sinxM,a1
	lea	posxM,a0
	move.l	(a0),d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	(a1,d0.w),d0
	move.l	d0,d1
	mulu.w	#$300,d1
	add.l	#$2a00,d1
	cmp.l	#$5000,d1
	blt.b	ltrtM
	move.l	#$5000,d1
ltrtM:	lea	leftyM,a2
	move.l	d1,2(a2)		
	move.l	d0,d1
	mulu.w	#40,d0
	bsr.w	setxM
	bsr.w	setyM

	lea	alfaM,a0
	lea	dodajM,a1
	moveq	#2,d0
addlv2M:move.w	(a1),d1
	add.w	d1,(a0)
	cmp.w	#360,(a0)
	bmi.b	nookr2M
	clr.w	(a0)
nookr2M:tst.w	(a0)
	bpl.b	nookr3M
	clr.w	(a0)
nookr3M:addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,addlv2M
	rts

lineM:	movem.l	a4/a6,-(sp)
	lea	$dff000,a6
	lea	mul40M,a4
	move.w	4(a0),d0
	move.w	(a0),d1
	move.w	6(a0),d2
	move.w	2(a0),d3

	add.w	#160,d0
	add.w	#160,d2
	add.w	#128,d1
	add.w	#128,d3
	cmp.w	d3,d1
	beq.w	lquitM
	bhi.b	l_noychM
	exg.l	d0,d2
	exg.l	d1,d3

l_noychM:subq.w	#1,d1

	moveq	#0,d4
	move.w	d1,d4
	add.w	d4,d4
	move.w	(a4,d4.w),d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	scractM,d4

	moveq	#0,d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.b	y2Gy1M
	neg.w	d3
y2Gy1M:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx1M
	neg.w	d2
x2Gx1M:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdxM
	exg.l	d2,d3
dyGdxM:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsFM(pc,d5.w),d5

WBlitM:	btst.b	#14,$02(a6)
	bne.b	WBlitM

	move.w	#40,$60(a6)
	move.w	#40,$66(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	#$ffffffff,$44(a6)

	move.w	d2,$62(a6)
	sub.w	d3,d2
	bge.b	SignNlM
	or.b	#$40,d5
SignNlM:
	move.w	d2,$52(a6)
	sub.w	d3,d2
	move.w	d2,$64(a6)
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0b4a,d0
	move.w	d0,$40(a6)
	move.w	d5,$42(a6)
	move.l	d4,$48(a6)
	move.l	d4,$54(a6)
	addq.w	#1,d3
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$58(a6)

lQUitM:	movem.l	(sp)+,a4/a6
	rts
OctantsFM:
	dc.b	3,19,11,23,7,27,15,31

clearM:
	waitblit
	move.l	singleM,d0
	addq.l	#4,d0
	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#8,$dff066
	move.l	d0,$dff054
	move.w	#[510<<6]!16,$dff058
	rts

fillM:	move.l	singleM+4,d0
	add.l	#$27d8*2-4,d0
	waitblit
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#8,$dff064
	move.w	#8,$dff066
	move.w	#%111111110010000,$dff058
	rts

setobjM:movem.l	a0/a1/a2/a6,-(sp)
	lea	objectM,a0
	addq.l	#1,(a0)
	cmp.l	#2,(a0)
	bne.b	nononoM
	clr.l	(a0)
nononoM:move.l	(a0),d0
	lea	scrtM,a6
	asl.l	#4,d0
	add.l	d0,a6
	lea	pointspM,a1
	lea	pointsM,a2
	move.l	a2,(a1)
	move.l	(a6)+,d0
	add.l	d0,(a1)

	lea	pstrpM,a1
	lea	pstrM,a2
	move.l	a2,(a1)
	move.l	(a6)+,d0
	add.l	d0,(a1)

	lea	pointslM,a1
	move.l	(a6)+,(a1)

	lea	hideM,a1
	move.l	(a6)+,(a1)
	movem.l	(sp)+,a0/a1/a2/a6
	rts

setscrM:move.l	singleM+8,d0
	lea	c11M,a1
clopM:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$27d8,d0
	dbra	d1,clopM
	rts

setxM:	add.l	singleM+12,d0
	lea	c12M,a0
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	rts

setyM:	lea	makeM+[[linesM/2]*4*4],a0
	move.l	a0,a1
	moveq	#[linesM/2]-1,d7

colrM:	move.w	#$0fff,d2
	move.w	#$0fff,d3
	move.w	#$0fff,d4
	move.w	#$0fff,d5

	moveq	#0,d0
sy2M:	subq.w	#1,d0
	bge.b	sy1M
	move.w	d1,d0
	move.w	d2,2(a0)
	move.w	d3,6(a0)
	move.w	d4,10(a0)
	move.w	d2,2(a1)
	move.w	d3,6(a1)
	move.w	d4,10(a1)
	bra.b	sy3M

sy1M:	move.w	d5,2(a0)
	move.w	d5,6(a0)
	move.w	d5,10(a0)
	move.w	d5,2(a1)
	move.w	d5,6(a1)
	move.w	d5,10(a1)

sy3M:
	lea	16(a0),a0
	lea	-16(a1),a1
	cmp.b	#$ff,(a0)
	bne.b	hyaM
	addq.l	#4,a0
hyaM:	dbra	d7,sy2M
	rts

Part:
ilepts=6000
	bsr.w	run1
	jsr	PreFala
	jsr	Fala
	move.w	#$aaa,d0
	move.w	#0,d1
	bsr.w	Rect2
WaiqRC2:tst.b	EndRC2
	beq.b	WaiqRC2
	bsr.w	Ninja
	rts

okeyA:	tst.b	Oki
	bne.w	QuitA
	bsr.w	PutRamki
	addq.w	#2,Size
	cmp.w	#80,Size
	bne.w	Quitab
	move.b	#-1,Oki
	bra.w	QuitAb

QuitA:	tst.b	ctl1
	beq.b	QuitB
	subq.w	#2,Size
	tst.w	Size
	bge.b	Quitba
	clr.w	Size
	clr.b	Ctl1
	move.b	#-1,Ctl1+1
	moveq	#$28,d0
	add.b	d0,m1
	add.b	d0,m2
	add.b	d0,m3
	move.b	#$70,m4
	move.b	#$74,m5
	move.b	#$ea,m9
	move.b	#$ec,m6
	move.b	#$fe,m7
	move.l	#$01be0000,m8
	move.l	#$01be0000,m8+4

	bra.b	QuitAb
QuitBA:	bsr.b	PutRamki
	bra.b	QuitAb
QuitB:
	tst.b	ctl1+1
	beq.b	QuitC

	addq.l	#1,Tim
	cmp.l	#50,Tim
	ble.b	QuitAb
	bsr.b	PutRamki
	addq.w	#2,Size
	cmp.w	#80,Size
	blt.b	QuitAb
	clr.b	Ctl1+1
	bra.w	QuitAb
QuitC:
QuitAb:	rts
	nop
PutRamki:
	waitblit
	lea	RamkaUpX,a0
	lea	RamkaUp,a1
	lea	$dff000,a6
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)

	tst.w	Size
	beq.b	Az1

	move.w	size,d0
	sub.w	#80,d0
	neg.w	d0
	lea	(a0,d0.w),a0
	move.w	d0,$64(a6)
	move.w	d0,$66(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	Size,d0
	asr.w	#1,d0
	or.w	#[15*4<<6],d0
	move.w	d0,$58(a6)

Az1:	cmp.w	#80,Size
	beq.b	Cz1
	move.w	Size,d0
	move.l	#15*4,d7
Czy1:	clr.l	(a1,d0.w)
	lea	80(a1),a1
	dbra	d7,Czy1
Cz1:
	lea	RamkaDownX,a0
	lea	RamkaDown,a1
	move.w	size,d0
	neg.w	d0
	lea	(a1,d0.w),a1
	move.w	size,d0
	sub.w	#80,d0
	neg.w	d0
	tst.w	Size
	beq.b	Az2
	waitblit
	move.w	d0,$64(a6)
	move.w	d0,$66(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	Size,d0
	asr.w	#1,d0
	or.w	#[18*4<<6],d0
	move.w	d0,$58(a6)
Az2:	cmp.w	#80,Size
	beq.b	Cz2

	move.l	#18*4,d7
Czy2:	clr.l	-4(a1)
	lea	80(a1),a1
	dbra	d7,Czy2
Cz2:
	rts

frag:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
endfrag:



setscr:	move.l	screenn+4,d0
	add.l	#40*48,d0
	lea	c11b,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

run:	lea	RamkiFast,a0
	lea	RamkaUpX,a1
	move.l	#[EndRamkiX-RamkaUpX]/4-1,d7
MvRamk:	move.l	(a0)+,(a1)+
	dbra	d7,MvRamk

	lea	RamkaUp,a0
	move.l	a0,d0
	lea	c10,a1
	moveq	#3,d7
SetUp:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$4b0,d0
	dbra	d7,Setup

	lea	RamkaDown,a0
	move.l	a0,d0
	lea	c13,a1
	moveq	#3,d7
SetUp2:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$5a0,d0
	dbra	d7,Setup2

	lea	screen,a0
	lea	screenn,a1
	move.l	a0,(a1)+
	add.l	#$1db0*2,a0
	move.l	a0,(a1)+
	add.l	#$1db0*2,a0
	move.l	a0,(a1)+

	bsr.w	setscr

	lea	OkeyA,a0
	move.l	a0,vblk_ptr
	waitframe
	lea	copperX,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	clr.l	Counter
	lea	SphPP,a0
	lea	Tabl1,a1
	move.l	#EndSphPP-SphPP,d0
	bsr.w	Decrunch

WaiCq1:	cmp.l	#100,Counter
	blt.b	WaiCq1

	lea	tabl1,a0
	lea	tabl1p,a1
	move.l	#[tabl1p-tabl1]/4-1,d7
mvt1:	move.l	(a0)+,(a1)+
	dbra	d7,mvt1

	lea	tabl2,a0
	lea	tabl2p,a1
	move.l	#[tabl2p-tabl2]/4-1,d7
mvt2:	move.l	(a0)+,(a1)+
	dbra	d7,mvt2

	lea	PutPoints,a0
	lea	picendB,a6

	move.l	#171,d7	

	moveq	#0,d2
	moveq	#0,d3
PutPrg:	moveq	#0,d5

NextBit:
	btst	d5,(a6)
	bne.b	PointH
	addq.l	#1,d2
	bra.b	EndNext

PointH:	move.w	#$43e9,(a0)+
	move.w	d2,(a0)+
	add.w	d2,d2
	move.w	#$41e8,(a0)+
	move.w	d2,(a0)+	
	moveq	#0,d2

put2:	moveq	#[endfrag-frag]/2-1,d6
	lea	Frag,a1
putone1:move.w	(a1)+,(a0)+
	dbra	d6,putone1

EndNext:addq.b	#1,d3
	cmp.b	#90,d3
	beq.b	NextLine
	addq.b	#1,d5
	cmp.b	#8,d5
	bne.b	NextBit
	subq.l	#1,a6
	bra.b	PutPrg

NextLine:
	subq.l	#1,a6
	moveq	#0,d3
	dbra	d7,putprg
	move.w	#$4e75,(a0)+

mysz:	bsr.w	setscr
	movem.l	screenn,d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,screenn

	waitblit
	move.l	#$01000000,$dff040
	clr.l	$dff044
	move.l	screenn,$dff054
	move.w	#0,$dff066
	move.w	#[380<<6]!20,$dff058

	addq.l	#2,adder1
	cmp.l	#EndSin1-Sin1,adder1
	blt.b	noway1
	clr.l	adder1
noway1:
	addq.l	#2,adder2
	cmp.l	#EndSin2-Sin2,adder2
	blt.b	noway2
	clr.l	adder2
noway2:

	move.l	screenn+4,a5

	move.l	a5,a4

	lea	tabl1,a0
	lea	tabl2,a1
	lea	Sin1,a2
	lea	Sin2,a3
	add.l	Adder1,a2
	add.l	Adder2,a3
	move.w	(a2),d0
	add.w	(a3),d0
	lea	(a1,d0.w),a1
	add.w	d0,d0
	lea	(a0,d0.w),a0

	moveq	#0,d0
	moveq	#0,d1

	lea	PutPoints,a6
	jsr	(a6)

	addq.l	#1,Tim2
	cmp.l	#50,Tim2
	bgt.b	No1F

	lea	cols+2,a0
	moveq	#2,d7
	moveq	#0,d6
FUF:	move.w	(a0),d1
	move.w	#$0cc,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUF
	bra.b	ConI
No1F:	cmp.l	#50*5,Tim2
	blt.b	ConI
	lea	cols+2,a0
	moveq	#2,d7
	moveq	#0,d6
FUF2:	move.w	(a0),d1
	move.w	#$203,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUF2
	tst.b	d6
	beq.b	Proce
ConI:

waitfr:	cmp.b	#$ff,$dff006
	bne.b	waitfr

	bra.w	mysz
Proce:	bsr.w	Rot

	lea	Return_abs,a0
	move.l	a0,vblk_ptr

	move.w	#$0203,d0
	bsr.w	NormCop
	move.w	#$203,d0
	move.w	#$036,d1
	bsr.w	RecT1
Wai2e:	tst.b	EndRC1
	beq.b	Wai2e
	move.w	#$36,d0
	bsr.w	NormCop
aasqw:	waitframe
	waitframe
	waitframe
	waitframe
	moveq	#0,d6
	move.w	ncco,d1
	moveq	#0,d0
	bsr	fade
	move.w	d1,ncco
	tst.b	d6
	bne.b	aasqw

	rts

NormCop:
	move.w	d0,NCCo
	lea	NormCopper,a0
	waitframe2
	move.l	a0,$dff080
	move.w	a0,$dff088
	rts

*************************************************************
ileptsL=30000

frag1L:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
endfrag1L:

frag2L:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
	bset.b	d0,(a4,d1.w)
endfrag2L:

frag3L:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a4,d1.w)
endfrag3L:


setscrL:move.l	screennL+4,d0
	lea	c11b,a1
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

Rot:	clr.w	MvB
	move.b	#-1,Ctl1

	lea	screen,a0
	lea	screennL,a1
	move.l	a0,(a1)+
	add.l	#$1f40*2,a0
	move.l	a0,(a1)+
	add.l	#$1f40*2,a0
	move.l	a0,(a1)+

	bsr.w	setscrL

	clr.l	Counter
	lea	tablica1L,a0
	lea	tabl1L,a1
	move.l	#endtabl1L-tablica1L,d0
	bsr.w	Decrunch

Wcnj:	cmp.l	#100,Counter
	ble.b	WCnj

	clr.l	Counter
	lea	tabl1L,a0
	lea	ttabl1L,a1
	move.l	#60000/4-1,d7
mvitrL:	move.l	(a0)+,(a1)+
	dbra	d7,mvitrL

	lea	tabl2L,a0
	lea	ttabl2L,a1
	move.l	#30000/4-1,d7
mvitr2L:move.l	(a0)+,(a1)+
	dbra	d7,mvitr2L

	clr.l	Counter
	lea	PicPPL,a0
	lea	PicL,a1
	move.l	#endpicL-picppL,d0
	bsr.w	Decrunch
OKOL:	cmp.l	#10,Counter
	ble.b	OKOL

	lea	PutPoints,a0
	lea	tabl1L,a6
	lea	picL+14+40*50,a5
	lea	picL+14+40*50+$1f40,a4
	lea	tabl2L,a3
	lea	tabl3L,a2
	move.l	#ileptsL-1,d7	
	moveq	#0,d5
	moveq	#-1,d4

putprgL:move.b	(a3)+,d0
	move.w	(a6)+,d1

	addq.l	#1,d4
	move.w	d4,d3
	asr.w	#3,d3
	btst.b	d4,(a2,d3.w)
	beq.w	NowL
	addq.l	#1,d5
	bra.b	quitpL

NowL:	btst.b	d0,(a5,d1.w)
	beq.b	ptxL

	btst.b	d0,(a4,d1.w)
	beq.b	no2bpl2L

	bsr.w	emptpL
	moveq	#[endfrag2L-frag2L]/2-1,d6
	lea	Frag2L,a1
putone1L:move.w	(a1)+,(a0)+
	dbra	d6,putone1L
	bra.b	quitpL

no2bpl2L:bsr.w	emptpL
	moveq	#[endfrag1L-frag1L]/2-1,d6
	lea	Frag1L,a1
putoneL:move.w	(a1)+,(a0)+
	dbra	d6,putoneL
	bra.b	quitpL

ptxL:	btst.b	d0,(a4,d1.w)
	beq.b	no2bplL
	bsr.w	emptpL
	moveq	#[endfrag3L-frag3L]/2-1,d6
	lea	Frag3L,a1
putone3L:move.w	(a1)+,(a0)+
	dbra	d6,putone3L
	bra.b	quitpL


no2bplL:addq.l	#1,d5
quitpL:	dbra	d7,putprgL
	move.w	#$4e75,(a0)+

	clr.l	Tim2

WaiCqx:	cmp.l	#50,Counter
	blt.b	WaiCqx

	waitframe
	lea	copperX,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr

myszL:	bsr.w	setscrL
	movem.l	screennL,d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,screennL

	waitblit
	move.l	#$01000000,$dff040
	clr.l	$dff044
	move.l	screennL,d0
	add.l	#10,d0
	move.l	d0,$dff054
	move.w	#20,$dff066
	move.w	#[400<<6]!10,$dff058

	addq.l	#1,timerL
	move.l	alarmL,d0
	cmp.l	timerL,d0
	bgt.b	notimeL
oncemL:	move.l	scriptposL,d0
	addq.l	#8,scriptposL
	lea	scriptL,a0
	add.l	d0,a0
	move.l	(a0)+,alarmL
	cmp.l	#-1,alarmL
	bne.b	NoSEndL
	clr.l	scriptposL
	bra.b	oncemL
NoSEndL:	clr.l	timerL
	move.l	(a0)+,addikL
notimeL:
	move.l	addikL,d0
	add.l	d0,adderL
	cmp.l	#30000,adderL
	blt.b	noway1L
	sub.l	#30000,adderL
noway1L:

	move.l	screennL+4,a5
	add.l	#14,a5
	move.l	a5,a4
	add.l	#$1f40,a4

	lea	tabl1L,a0
	lea	tabl2L,a1
	move.l	adderL,d1
	add.l	d1,a1
	asl.l	#1,d1
	add.l	d1,a0

	moveq	#0,d0
	moveq	#0,d1

	lea	PutPoints,a6
	jsr	(a6)

	addq.l	#1,Tim2
	cmp.l	#1000,Tim2
	blt.b	Faq
	cmp.l	#5,Tim2
	blt.b	Faq2
	lea	cols+2,a0
	moveq	#2,d7
	moveq	#0,d6
FUF3:	move.w	(a0),d1
	move.w	#$203,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUF3
	tst.b	d6
	beq.b	QuitPa
	bra.b	Faq2

Faq:	lea	cols+2,a0
	lea	Pale,a1
	moveq	#2,d7
	moveq	#0,d6
FUF6:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUF6
Faq2:
	waitframeZ

	bra.w	myszL
QuitPa:
	waitframe
	subq.w	#2,Size
	bsr.w	PutRamki
	tst.w	Size
	bgt.b	QuitPa
	rts

emptpL:
	tst.l	d5
	beq.b	okiyL
	move.w	#$43e9,(a0)+	
	move.w	d5,(a0)+
	asl.l	#1,d5
	move.w	#$41e8,(a0)+
	move.w	d5,(a0)+
	moveq	#0,d5
okiyL:	rts

AdY1=4

waitblit1:macro
	btst	#14,$dff002
	bne.b	*-8
	endm

waitframe1:macro
\@11:	cmp.b	#$ff,$dff006
	bne.b	\@11
\@21:	cmp.b	#$3,$dff006
	bne.b	\@21
	endm


Wait1:	moveq	#14,d7
W21:	waitframe1
	dbra	d7,W21
	rts

PutLet1:waitblit1
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#$00760026,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#[16*3<<6]!1,$58(a6)
	addq.l	#2,a1
	rts

run1:	lea	Return_Abs,a0
	move.l	a0,vblk_ptr
	waitblit
	move.l	#$01000000,$dff040
	clr.l	$dff044
	lea	Screen21,a0
	move.l	a0,$dff054
	move.w	#0,$dff066
	move.w	#[270<<6]!63,$dff058

	lea	FontFast,a0
	lea	Font,a1
	move.l	#[SignsFastEnd-FontFast]/4-1,d7
mvfn:	move.l	(a0)+,(a1)+
	dbra	d7,mvfn

	lea	Screen21,a0
	move.l	a0,d0
	lea	C101,a1

	moveq	#3,d7
SetQ1:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#40*61,d0
	dbra	d7,SetQ1

	lea	Screen21+40*61*4,a0
	move.l	a0,d0
	lea	C91,a1
	moveq	#2,d7
SetA1:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#40*16,d0
	dbra	d7,SetA1

	waitframe1
	lea	Copper21,a0
	move.l	a0,$dff080
	clr.w	$dff088

	waitblit1
	lea	Screen21+40*61*4+10,a1
	lea	font,a2
	lea	$dff000,a6

	lea	['A'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['N'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['D'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	[' '-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['N'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['O'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['W'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['.'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['.'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['.'-32]*2(a2),a0
	bsr.w	PutLet1

FUX01:	waitframe1
	waitframe1
	waitframe1
	waitframe1
	waitframe1
	lea	col1b+2,a0
	lea	pal11,a1
	moveq	#7,d7
	moveq	#0,d6
FUX1:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade1
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUX1
	tst.b	d6
	bne.w	FUX01
	bsr.w	wait1

	lea	Signs1,a0
	lea	Screen21+10,a1
	lea	$dff000,a6
	waitblit1
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)

	move.l	#$00100024,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#[61*4<<6]!2,$58(a6)
	addq.l	#4,a0
	addq.l	#4,a1

	bsr.w	wait1
	waitblit1
	move.l	#$000e0022,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#[61*4<<6]!3,$58(a6)
	addq.l	#6,a0
	addq.l	#6,a1

	bsr.w	wait1
	waitblit1
	move.l	#$00100024,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#[61*4<<6]!2,$58(a6)
	addq.l	#4,a0
	addq.l	#4,a1

	bsr.w	wait1
	waitblit1
	move.l	#$000e0022,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#[61*4<<6]!3,$58(a6)

	bsr.w	wait1
	waitblit1

FUa01:	waitframe1
	lea	col1b+2,a0
	moveq	#7,d7
	moveq	#0,d6
FUa1:	move.w	(a0),d1
	moveq	#0,d0
	bsr.w	fade1
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUa1
	tst.b	d6
	bne.w	FUa01

	lea	Screen21+40*61*4+10,a1
	lea	font,a2

	lea	[' '-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['W'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['H'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['A'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['T'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	[' '-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['?'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['?'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	['?'-32]*2(a2),a0
	bsr.w	PutLet1
	lea	[' '-32]*2(a2),a0
	bsr.w	PutLet1

FUb01:	waitframe1
	lea	col1b+2,a0
	lea	pal11,a1
	moveq	#7,d7
	moveq	#0,d6
FUb1:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade1
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUb1
	tst.b	d6
	bne.w	FUb01

	clr.l	Counter
	lea	PicPP1,a0
	lea	Screen1,a1
	move.l	#PicEnd1-PicPP1,d0
	bsr.w	Decrunch
DFGH:	cmp.l	#50,Counter
	ble.b	DFGH

FUc01:	waitframe1
	lea	col21+2,a0
	moveq	#15,d7
	moveq	#0,d6
FUc1:	move.w	(a0),d1
	moveq	#0,d0
	bsr.w	fade1
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUc1
	tst.b	d6
	bne.w	FUc01

FUd01:	waitframe1
	lea	col1b+2,a0
	moveq	#7,d7
	moveq	#0,d6
FUd1:	move.w	(a0),d1
	moveq	#0,d0
	bsr.w	fade1
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUd1
	tst.b	d6
	bne.w	FUd01

	lea	screen1,a0
	move.l	a0,d0
	lea	c111,a1

	moveq	#4,d7
SetC1:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1c22,d0
	dbra	d7,SetC1


	lea	make1,a0
	moveq	#$22,d0

CMa1:	move.l	#$0108ffe6,(a0)+
	move.l	#$010affe6,(a0)+
	move.b	d0,(a0)+
	move.b	#7,(a0)+
	move.w	#$fffe,(a0)+

	addq.l	#1,d0
	cmp.l	#$0101,d0
	bne.b	NoFF1
	move.l	#$ffddfffe,(a0)+
NoFF1:	cmp.l	#$143,d0
	blt.b	CMa1
	move.l	#$0100000,(a0)+
	move.l	#$ffffffe,(a0)

	lea	copper1,a0
	move.l	a0,$dff080
	move.w	d0,$dff088


Show1:	addq.l	#AdY1,SizeY1
	cmp.l	#$129,SizeY1
	bge.w	Wait21
	bsr.w	SetMod1
	waitframe1
	bra.b	Show1


Wait21:

	move.l	#50*3,d7
wt71:	waitframe1
	dbra	d7,wt71

Hide1:	subq.l	#AdY1,SizeY1
	bgt.w	Nor1
	move.l	#2,SizeY1
	bsr.w	SetMod1
	bra.b	Quit1

Nor1:	bsr.w	SetMod1
	waitframe1
	bra.b	Hide1

Quit1:

	bsr.w	PreRect2
	move.w	#$0,d1
	move.w	#$203,d0
	bsr.w	Rect2
WaitRC2:tst.b	EndRC2
	beq.b	WaitRC2
	bra.w	run

Fade1:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$00f,d2
	and.w	#$00f,d3
	cmp.w	d2,d3
	beq.b	Equal11
	bgt.b	Greater11

	addq.w	#$001,d1
	moveq	#1,d6
	bra.b	Equal11
Greater11:
	moveq	#1,d6
	subq.w	#$001,d1
Equal11:move.w	d0,d2
	move.w	d1,d3
	and.w	#$0f0,d2
	and.w	#$0f0,d3
	cmp.w	d2,d3
	beq.b	Equal21
	bgt.b	Greater21

	moveq	#1,d6
	add.w	#$010,d1
	bra.b	Equal21
Greater21:
	moveq	#1,d6
	sub.w	#$010,d1
Equal21:move.w	d0,d2
	move.w	d1,d3
	and.w	#$f00,d2
	and.w	#$f00,d3
	cmp.w	d2,d3
	beq.b	Equal31
	bgt.b	Greater31

	moveq	#1,d6
	add.w	#$100,d1
	bra.b	Equal31
Greater31:
	moveq	#1,d6
	sub.w	#$100,d1
Equal31:rts

SetMod1:
	lea	make1,a0
	move.l	#10,d7
	moveq	#-26,d6
	moveq	#0,d0

	move.l	#$129<<8,d3
	move.l	SizeY1,d4
	divu.w	d4,d3
	and.l	#$ffff,d3
	moveq	#0,d5

	add.l	d3,d5
	move.l	d5,d7
	asr.l	#8,d7

PutMod1:cmp.l	d7,d0
	bne.b	Lon1
	
	add.l	d3,d5
	move.l	d5,d7
	asr.l	#8,d7

	clr.w	2(a0)
	clr.w	6(a0)
	bra.w	Shr1

Lon1:	move.w	d6,2(a0)
	move.w	d6,6(a0)

Shr1:	addq.l	#8,a0
	addq.l	#4,a0

	cmp.w	#$ffdd,(a0)
	bne.b	NoFFR1
	addq.l	#4,a0
NoFFR1:
	addq.l	#1,d0
	cmp.l	#$120,d0
	blt.b	PutMod1
	rts

*****************************************************************
rotateRC1:MACRO
	add.w	d2,d2
	lea	sinusg,a6
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

ReCt1:	move.w	d0,ColRC1+2
	move.w	d1,ColRC1+6
	cmp.w	#4,2+Pstrrc1
	beq.b	NolllRC1
	lea	pstrRC1,a0
	moveq	#[pstrendRC1-pstrRC1]/2-1,d7
stilpRC1:move.w	(a0)+,d0
	bmi.b	stilRC1
	asl.w	#2,d0
	move.w	d0,-2(a0)
stilRC1:dbra	d7,stilpRC1
NoLLLRC1:
	clr.w	EndRC1
	clr.w	adecrc1
	clr.w	alfarc1+4
	clr.l	leftyrc1+2

	lea	singleRC1,a1
	lea	screenRC1,a0
	move.l	a0,(a1)
	add.l	#$6400,a0
	move.l	a0,4(a1)
	add.l	#$6400,a0
	move.l	a0,8(a1)

	moveq	#1,d1
	bsr.w	setscrRC1
	move.l	singleRC1+12,a0
	
	clr.w	EndRC1
	waitframe
	lea	MainRC1,a0
	move.l	a0,vblk_ptr
	waitframe
	waitframe
	lea	copperRC1,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	rts

MainRC1:
	waitblit1
	lea	singleRC1,a0
	move.l	4(a0),d0
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	moveq	#1,d1
	bsr.w	setscrRC1

	waitblit1
	move.l	singleRC1,a6
	add.l	#$c80+10,a6
	move.l	a6,$dff054
	move.l	#%00000001000000000000000000000000,$dff040
	move.w	#10,$dff066
	move.w	#[300<<6]!27,$dff058

	lea	destpRC1,a4
	lea	pointsRC1,a5
	move.l	#[pointsendRC1-pointsRC1]/6-1,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

cpr2RC1:move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5
	move.w	alfaRC1,d2
	exg	d1,d5
	ROTATERC1
	exg	d1,d5
	move.w	alfaRC1+2,d2
	exg	d0,d5
	ROTATERC1
	exg	d0,d5
	move.w	alfaRC1+4,d2
	ROTATERC1

	moveq	#0,d4
	move.w	d5,d4
leftyRC1:move.l	#0,d6
	asl.l	#4,d4
	sub.l	d4,d6
	muls.w	d6,d0
	muls.w	d6,d1
	swap	d0
	swap	d1
	exg	d4,d5

	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2RC1

	cmp.l	#$7a00,leftyRC1+2
	bge.b	EguaRC1
	add.l	#$d4,LeftyRC1+2
EguaRC1:
	cmp.w	#2,AdecRC1
	bne.w	auitRc1
	move.b	#-1,EndRC1
	rts
auitRC1:
	addq.w	#5,AlfaRC1+4
	cmp.w	#360,AlfaRC1+4
	ble.b	EwqRC1
	addq.w	#1,AdecRC1
	clr.w	AlfaRC1+4
EwqRC1:

	lea	y1RC1,a0
	lea	dodpRC1,a1
	lea	bplpRC1,a2
	lea	hideRC1,a3
	lea	destpRC1,a4
	lea	scractRC1,a5
	move.l	singleRC1,(a5)
	lea	pstrRC1,a6

	move.w	(a6)+,d0
	move.w	d0,(a1)
	move.w	d0,2(a1)

reptRC1:	tst.l	(a3)
	bne.b	rept2RC1

	move.w	(a1),d3
	move.w	(a6),d4
	move.w	2(a6),d5


rept2RC1:move.w	(a6)+,d0
	bpl.b	plukRC1
	cmp.w	#-1,d0
	beq.b	quityRC1
	move.w	d0,d6
	moveq	#0,d7
	move.w	(a6)+,d7
	move.l	(a2,d7.w),d7
	add.l	singleRC1,d7
	move.w	2(a1),d0
	move.w	(a1),d1
	bsr.b	drawRC1
	move.w	(a6),(a1)
	move.w	(a6)+,2(a1)
	move.l	d7,(a5)
	cmp.b	#-4,d6
	beq.b	rept2RC1
	bra.w	reptRC1

plukRC1:	move.w	(a1),d1
	move.w	d0,(a1)
	bsr.b	drawRC1
	bra.b	rept2RC1

drawRC1:	move.w	d0,d2
	move.w	d1,d3
	move.w	(a4,d2.w),4(a0)
	move.w	2(a4,d2.w),(a0)
	move.w	(a4,d3.w),6(a0)
	move.w	2(a4,d3.w),2(a0)
	bsr.b	lineRC1
	rts
	
quityRC1:move.l	singleRC1,d0
	add.l	#$5780-2,d0
	waitblit1
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#10,$dff064
	move.w	#10,$dff066
	move.w	#[300<<6]!27,$dff058

	waitblit1
	rts
	

lineRC1:movem.l	d0-d7/a0-a6,-(sp)
	add.w	#256,4(a0)
	add.w	#256,6(a0)
	add.w	#200,(a0)
	add.w	#200,2(a0)

	lea	$dff000,a5

	move.w	(a0),d0
	cmp.w	2(a0),d0
	beq.w	l_quitRC1
	bhi.b	l_noychRC1
	move.w	2(a0),(a0)
	move.w	d0,2(a0)
	move.w	4(a0),d0
	move.w	6(a0),4(a0)
	move.w	d0,6(a0)
l_noychRC1:subq.w #1,(a0)

	move.w	4(a0),d0
	move.w	(a0),d1
	move.w	6(a0),d2
	move.w	2(a0),d3
	move.l	scractRC1,a6


	moveq	#0,d4
	move.w	d1,d4
	asl.w	#6,d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a6,d4

	moveq	#0,d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.b	y2Gy1RC1
	neg.w	d3
y2Gy1RC1:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx1RC1
	neg.w	d2
x2Gx1RC1:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdxRC1
	exg.l	d2,d3
dyGdxRC1:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsFRC1(pc,d5.w),d5

WBlitRC1:	btst.b	#14,$02(a5)
	bne.b	WBlitRC1

	move.w	d2,$62(a5)
	sub.w	d3,d2
	bge.b	SignNlRC1
	or.b	#$40,d5
SignNlRC1:
	move.w	d2,$52(a5)
	sub.w	d3,d2
	move.w	d2,$64(a5)
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0b4a,d0
	move.l	#$ffff8000,$72(a5)
	move.l	#$ffffffff,$44(a5)
	move.w	#64,$60(a5)
	move.w	#64,$66(a5)
	move.w	d0,$40(a5)
	move.w	d5,$42(a5)
	move.l	d4,$48(a5)
	move.l	d4,$54(a5)

	addq.w	#1,d3
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$58(a5)

l_quitRC1:	movem.l	(sp)+,d0-d7/a0-a6
	rts

OctantsNRC1:
	dc.b	1,17,09,21,5,25,13,29
OctantsFRC1:
	dc.b	3,19,11,23,7,27,15,31

setscrRC1:move.l	singleRC1+4,d0
	add.l	#10+$c80,d0
	lea	c11RC1,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

******************************************************************
PreRect2:
	lea	pstrRC2,a0
	moveq	#[pstsendRC2-pstrRC2]/2-1,d7
stilpRC2:move.w	(a0)+,d0
	bmi.b	stilRC2
	asl.w	#2,d0
	move.w	d0,-2(a0)
stilRC2:dbra	d7,stilpRC2
	rts

ReCt2:	move.w	d0,ColRC+2
	move.w	d1,COlRC+6
	exg.l	d0,d1
	bsr.w	NormCop

	clr.w	ADECRC2
	lea	PoRC,a0
	lea	PointsRC2,a1
	moveq	#[pointsendRC2-pointsRC2]/2-1,d7
ASRC2:	move.w	(a0)+,(a1)+
	dbra	d7,ASRC2

	lea	singleRC2,a1
	lea	screenRC2,a0
	move.l	a0,(a1)
	add.l	#$9600*2,a0
	move.l	a0,4(a1)

	moveq	#1,d1
	bsr.w	setscrRC2
	move.l	singleRC2+12,a0
	clr.w	EndRC2
	waitframe
	lea	MainRC2,a0
	move.l	a0,vblk_ptr
	waitframe2
	waitframe2
	lea	copperRC2,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	rts

MainRC2:
	waitblit
	cmp.w	#10*vxRC2,AB1
	bge.b	ABC1
	add.w	#xxRC2,AB1
	add.w	#xxRC2,AB2

	add.w	#-xxRC2,AB3+6
	add.w	#-xxRC2,AB4+6


	add.w	#xxRC2,AB5
	add.w	#xxRC2,AB6+6

	add.w	#-xxRC2,AB7
	add.w	#-xxRC2,AB8

ABC1:
	lea	singleRC2,a0
	move.l	4(a0),d0
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	moveq	#1,d1
	bsr.w	setscrRC2

	waitblit
	move.l	singleRC2,a6
	add.l	#$c80*3*2+38+4,a6
	move.l	a6,$dff054
	move.l	#%00000001000000000000000000000000,$dff040
	move.w	#68,$dff066
	move.w	#[300<<6]!30,$dff058

	lea	destpRC2,a4
	lea	pointsRC2,a5
	move.l	#[pointsendRC2-pointsRC2]/6-1,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

cpr2RC2:move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a5)+,d5
	move.w	alfaRC2+4,d2
	ROTATERC1

	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2RC2

	cmp.w	#2,AdecRC2
	blt.w	NQuitRC2
	move.b	#-1,EndRC2
	rts
NQuitRC2:
	addq.w	#5,AlfaRC2+4
	cmp.w	#360,AlfaRC2+4
	ble.b	EwqRC2
	addq.w	#1,AdecRC2
	clr.w	AlfaRC2+4
EwqRC2:

	lea	y1RC2,a0
	lea	dodpRC2,a1
	lea	bplpRC2,a2
	lea	hideRC2,a3
	lea	destpRC2,a4
	lea	scractRC2,a5
	move.l	singleRC2,(a5)

	lea	pstrRC2,a6
	tst.w	AB1
	blt.b	BCE1
	lea	pstsRC2,a6
BCE1:
	move.w	(a6)+,d0
	move.w	d0,(a1)
	move.w	d0,2(a1)

reptRC2:tst.l	(a3)
	bne.b	rept2RC2

	move.w	(a1),d3
	move.w	(a6),d4
	move.w	2(a6),d5


rept2RC2:move.w	(a6)+,d0
	bpl.b	plukRC2
	cmp.w	#-1,d0
	beq.b	quityRC2
	move.w	d0,d6
	moveq	#0,d7
	move.w	(a6)+,d7
	move.l	(a2,d7.w),d7
	add.l	singleRC2,d7
	move.w	2(a1),d0
	move.w	(a1),d1
	bsr.b	drawRC2
	move.w	(a6),(a1)
	move.w	(a6)+,2(a1)
	move.l	d7,(a5)
	cmp.b	#-4,d6
	beq.b	rept2RC2
	bra.w	reptRC2

plukRC2:move.w	(a1),d1
	move.w	d0,(a1)
	bsr.b	drawRC2
	bra.b	rept2RC2

drawRC2:move.w	d0,d2
	move.w	d1,d3
	move.w	(a4,d2.w),4(a0)
	move.w	2(a4,d2.w),(a0)
	move.w	(a4,d3.w),6(a0)
	move.w	2(a4,d3.w),2(a0)
	bsr.b	lineRC2
	rts
	
quityRC2:move.l	singleRC2,d0
	add.l	#$6400*2+$c80*2-28,d0
	waitblit
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#68,$dff064
	move.w	#68,$dff066
	move.w	#[300<<6]!30,$dff058
	rts


lineRC2:movem.l	d0-d7/a0-a6,-(sp)

	move.w	4(a0),d0
	move.w	(a0),d1
	move.w	6(a0),d2
	move.w	2(a0),d3

	add.w	#512,d0
	add.w	#512,d2
	add.w	#300,d1
	add.w	#300,d3


	lea	$dff000,a5

	cmp.w	d1,d3
	beq.w	l_quitRC2
	bhi.b	l_noychRC2
	exg.l	d1,d3
	exg.l	d0,d2
l_noychRC2:
	subq.w	#1,d3

	move.l	scractRC2,a6


	moveq	#0,d4
	move.w	d1,d4
	asl.w	#7,d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a6,d4

	moveq	#0,d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.b	y2Gy1RC2
	neg.w	d3
y2Gy1RC2:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx1RC2
	neg.w	d2
x2Gx1RC2:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdxRC2
	exg.l	d2,d3
dyGdxRC2:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsFRC2(pc,d5.w),d5

WBlitRC2:	btst.b	#14,$02(a5)
	bne.b	WBlitRC2

	move.w	d2,$62(a5)
	sub.w	d3,d2
	bge.b	SignNlRC2
	or.b	#$40,d5
SignNlRC2:
	move.w	d2,$52(a5)
	sub.w	d3,d2
	move.w	d2,$64(a5)
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0b4a,d0
	move.l	#$ffff8000,$72(a5)
	move.l	#$ffffffff,$44(a5)
	move.w	#2*64,$60(a5)
	move.w	#2*64,$66(a5)
	move.w	d0,$40(a5)
	move.w	d5,$42(a5)
	move.l	d4,$48(a5)
	move.l	d4,$54(a5)

	addq.w	#1,d3
	lsl.w	#6,d3
	addq.b	#2,d3
	move.w	d3,$58(a5)

l_quitRC2:	movem.l	(sp)+,d0-d7/a0-a6
	rts
OctantsFRC2:
	dc.b	3,19,11,23,7,27,15,31

setscrRC2:move.l singleRC2+4,d0
	add.l	#42+$c80*3*2,d0
	lea	c11RC2,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

*****************************************************************

Ninja:	move.w	#$aaa,d0
	bsr.w	NormCop

	lea	Cop_Down,a0
	move.l	a0,vblk_ptr
	lea	NinjaScr,a0
	move.l	a0,d0
	lea	c11N,a1

	moveq	#4,d7
setcN:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$2800,d0
	dbra	d7,SetcN

	clr.l	counter
	lea	NinjaPP,a0
	lea	NinjaScr,a1
	move.l	#EndNPP-NinjaPP,d0
	bsr.w	Decrunch
WNIas:	cmp.l	#70,counter
	ble.b	WNIas

	lea	SprN,a0
	move.l	a0,d0
	swap	d0
	move.w	d0,SprAdrN+2
	swap	d0
	move.w	d0,SprAdrN+6

	lea	SprAdrN+8,a0
	lea	EmptySpr,a1
	move.l	a1,d0
	moveq	#6,d7
SSPN:	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	addq.l	#8,a0
	dbra	d7,SSPN

	waitframe
	lea	copperN,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

FGN:	waitframe
	waitframe
	waitframe
	lea	colorsN+6,a0
	lea	PalN+2,a1
	moveq	#30,d7
	moveq	#0,d6
FG1N:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FG1N
	tst.b	d6
	bne.b	FGN

	lea	NinOkey,a0
	move.l	a0,Vblk_Ptr	

	lea	Cpic1PP,a0
	lea	Pic,a1
	move.l	#CPic2PP-CPic1PP,d0
	bsr.w	Decrunch

	lea	Cpic2PP,a0
	lea	Pic2,a1
	move.l	#CPicEndPP-CPic2PP,d0
	bsr.w	Decrunch

QuitN:	tst.b	NinEnd
	beq.b	QuitN

FG2N:	waitframe
	waitframe
	waitframe
	lea	colorsN+6,a0
	moveq	#30,d7
	moveq	#0,d6
FG12N:	move.w	(a0),d1
	moveq	#0,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FG12N
	tst.b	d6
	bne.b	FG2N
	rts

NinEnd:	dc.w	0
NinOkey:addq.l	#2,posN
	cmp.l	#$42,posN
	bne.b	NoChN
	move.w	#$20,PriorN
NoChN:	cmp.l	#endtabN-tabN,posN
	blt.b	NQuitN
	move.b	#-1,NinEnd
	rts
NQuitN:	lea	TabN,a0
	add.l	posN,a0
	move.b	(a0),d0
	subq.b	#3,d0
	move.b	d0,sprN+1
	move.b	1(a0),d0
	subq.b	#4,d0
	move.b	d0,sprN
	add.b	#16,d0
	move.b	d0,sprN+2
	rts
Cop_Down:
	bchg.b	#0,chgn
	beq.b	QCOPD
	bchg.b	#1,chgn
	beq.b	QCOPD
	tst.w	NCCo
	beq.b	QCOPD
	sub.w	#$111,NCCo
QCOPD:	rts

*************************************************
RamRead		=0
BplBB		=129*16
bplsizeBB	=256*64


OldBall:clr.l	Counter
	lea	SeqPicPP,a0
	lea	SeqPic,a1
	move.l	#[endseqPP-SeqPicPP]/4-1,d0
Mpis:	move.l	(a0)+,(a1)+
	dbra	d0,MpiS

	lea	copperBC,a0
	lea	copperBB,a1
	move.l	#MakeBC-CopperBC-1,d7
adfg:	move.b	(a0)+,(a1)+
	dbra	d7,adfg

	lea	cax,a1
	lea	Seqpic,a0
	move.l	a0,d0
	moveq	#4,d7
caxz:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$2800,d0
	dbra	d7,caxz

	waitframe
	lea	copperax,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	waitframe
	lea	jezyk,a0
	move.l	a0,Vblk_Ptr

	lea	FrogPic,a0
	lea	PaletteBB,a2
	lea	colortableBB+160+128+32,a3
	lea	colortableBB+160+128+32+256*2*128,a4
	bsr.w	copyBB

CBNM:	cmp.l	#400,Counter
	blt.b	CBNM

	lea	Jezyk2,a0
	move.l	a0,Vblk_Ptr

Shitr:	tst.b	EndJe
	beq.b	Shitr

	bra.w	runBB

copyBB:	move.l	#129-1,d7
LO9:	moveq	#16-1,d5
LO2:	moveq	#7,d6
	move.l	a0,a1
	add.l	#bplBB*4,a1
LO1:	moveq	#0,d0
	btst.b	d6,(a0)
	beq.b	NB1
	bset.l	#1,d0
NB1:	btst.b	d6,BplBB(a0)
	beq.b	NB2
	bset.l	#2,d0
NB2:	btst.b	d6,BplBB*2(a0)
	beq.b	NB3
	bset.l	#3,d0
NB3:	btst.b	d6,BplBB*3(a0)
	beq.b	NB4
	bset.l	#4,d0
NB4:	btst.b	d6,(a1)
	beq.b	NB5
	bset.l	#5,d0
NB5:
	move.w	(a2,d0.w),(a4)+
	move.w	(a2,d0.w),16*2*8-2(a4)
	move.w	(a2,d0.w),(a3)+
	move.w	(a2,d0.w),16*2*8-2(a3)

	dbra	d6,LO1
	addq.l	#1,a0
	dbra	d5,LO2
	add.l	#256*2-16*2*8,a3
	add.l	#256*2-16*2*8,a4
	dbra	d7,LO9
	rts

PaletteBB:
	dc.w $0000,$0aca,$0010,$0020
	dc.w $0030,$0040,$0141,$0151
	dc.w $0332,$04b4,$0494,$0474
	dc.w $0373,$0363,$0262,$0252
	dc.w $0221,$0110,$0330,$0fca
	dc.w $0333,$0444,$0555,$0666
	dc.w $0220,$0888,$0999,$0aaa
	dc.w $0ccc,$0ddd,$0eee,$0fff


Jezyk:	lea	colh+2,a0
	lea	Colhx,a1
	moveq	#31,d7
jezz:	move.w	(a1)+,d0
	move.w	(a0),d1
	bsr	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,jezz

	cmp.b	#$28,XXC+2
	beq.b	MMNq
	subq.b	#1,XXC+2
MMNq:
	cmp.b	#$28,XXC+6
	beq.b	MMNq2
	addq.b	#1,XXC+6
MMNq2:	rts

Jezyk2:	lea	colh+2,a0
	moveq	#31,d7
jezz2:	move.w	#0,d0
	move.w	(a0),d1
	bsr	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,jezz2

	cmp.b	#$40,XXC+2
	bne.b	MMNa
	move.b	#-1,EndJe
	rts
MMNa:	addq.b	#1,XXC+2
	cmp.b	#$0,XXC+6
	beq.b	MMNa2
	subq.b	#1,XXC+6
MMNa2:	rts
EndJe:	dc.w	0

okeyBB:	lea	rtBB,a0
	cmp.l	#100,(a0)
	beq.b	asssBB
	addq.l	#1,(a0)
	rts

asssBB:	lea	kierBB,a1
	btst	#6,(a1)
	bne.w	quitvBB
	btst	#0,(a1)
	bne.b	prt2BB
	lea	ypBB,a0
	addq.b	#4,3(a0)
	addq.b	#4,9(a0)
	cmp.b	#$e6,3(a0)
	bne.b	not2BB
	bset	#0,(a1)
	bset	#1,(a1)
not2BB:	bra.w	noty2BB

prt2BB:	lea	kierBB,a1
	btst	#7,(a1)
	beq.b	prt9BB
	lea	czasBB,a0
	addq.l	#1,(a0)
	cmp.l	#200,(a0)
	blt.b	prt9bb

	lea	ypBB,a0
	subq.b	#4,3(a0)
	subq.b	#4,9(a0)
	cmp.b	#$2,3(a0)
	bgt.b	notaBB
	bclr	#7,(a1)
	clr.b	3(a0)
notabb:	cmp.b	#$2,9(a0)
	bgt.b	not9bb
	bclr	#7,(a1)
	clr.b	9(a0)

not9BB:	bra.b	noty2BB

prt9BB:	btst	#1,(a1)
	beq.b	prt3BB
	lea	ypBB,a0
	lea	czas2BB,a2
	addq.l	#1,(a2)
	cmp.l	#250,(a2)
	bne.b	noty2BB
	clr.l	(a2)
	bset	#2,(a1)
	bclr	#1,(a1)

prt3BB:	btst	#2,(a1)
	beq.b	prt4BB
	lea	ypBB,a0
	subq.b	#4,3(a0)
	cmp.b	#$42,3(a0)
	bne.b	noty2BB
	bclr	#2,(a1)

prt4BB:	lea	czasBB,a0
	addq.l	#1,(a0)
	lea	ypBB,a0
	addq.b	#1,3+4(a0)
	lea	sinusmoveBB,a1
	move.l	4(a0),d0
	move.b	(a1,d0.w),3(a0)
	addq.b	#2,8+3(a0)
	move.w	8+2(a0),d0
	move.b	32(a1,d0.w),9(a0)

noty2BB:move.w	8(a0),d7
	asr.w	#2,d7

	lea	colortableBB+2,a3
	move.l	12+4(a0),d1
	add.l	d1,12(a0)
	cmp.l	#256*2-64,12(a0)
	blt.b	cnr1BB
	neg.l	12+4(a0)
cnr1BB:	tst.l	12(a0)
	bpl.b	cnr2BB
	neg.l	12+4(a0)
cnr2BB:	add.l	12(a0),a3

	move.l	dup,d0
	add.l	d0,fuje
	cmp.l	#2*256*128,fuje
	blt.b	hha
	neg.l	dup
hha:	tst.l	fuje
	bgt.b	hha2
	neg.l	dup
hha2:

	add.l	fuje,a3


	move.l	#128*8,d2
	move.l	#$ff00,d5
	move.l	ypBB,d6
	divu	d6,d5
	asl.l	#8,d5
	moveq	#0,d3

	move.l	makepBB,a0
	move.l	#$ff,d1
	sub.l	ypBB,d1
	asr.l	#1,d1
	and.b	#$fe,d1
	mulu.w	#152/2,d1
	add.l	d1,a0

	sub.l	#152*4,a0

	WaitBlit

	move.l	#$0,$dff044
	move.l	#$01000000,$dff040
	move.w	#$2,$dff066

	moveq	#5,d0
clea2BB:move.l	a0,d4
	addq.l	#2,d4
	WaitBlit
	move.l	d4,$dff054
	move.w	#%101000001,$dff058

	add.l	#152,a0
	dbra	d0,clea2BB

	WaitBlit

	move.l	#$ffffffff,$dff044
	move.l	#$09f00000,$dff040
	move.w	#$1,$dff064
	move.w	#$2,$dff066

	lea	sinusBB,a1
	lea	sinusBB+135*8,a2
lopzaBB:move.l	(a1),d1
	asr.l	#8,d1
	mulu.w	d7,d1
	and.b	#$c0,d1

clopBB:	cmp.b	#$ff,(a0)
	bne.b	okloBB
	addq.l	#4,a0

okloBB:	WaitBlit
	move.l	a3,$dff050
	move.l	a0,d4
	add.l	#26,d4
	move.l	d4,$dff054
	move.w	#%11111000001,$dff058
	
	move.w	d1,2(a0)

	add.w	#bplsizeBB,d1
	move.w	d1,6(a0)
	add.w	#bplsizeBB,d1
	move.w	d1,10(a0)
	add.w	#bplsizeBB,d1
	move.w	d1,14(a0)
	add.w	#bplsizeBB,d1
	move.w	d1,18(a0)

	add.l	#152,a0

	add.l	d5,d6
	move.l	d6,d4
	swap	d4
	and.w	#$ff,d4
	sub.b	d3,d4
	add.b	d4,d3
	subq.b	#1,d4
popBB:	addq.l	#8,a1
	cmp.l	a2,a1
	bge.b	shitBB
	add.l	#2*256,a3
	dbra	d4,popBB
stillBB:bra.w	lopzaBB
shitBB:	WaitBlit

	move.l	#$0,$dff044
	move.l	#$01000000,$dff040
	move.w	#$2,$dff066

	moveq	#5,d0
clea21BB:
	cmp.b	#$ff,(a0)
	bne.b	nooooBB
	addq.l	#4,a0
nooooBB:move.l	a0,d4
	addq.l	#2,d4
	WaitBlit
	move.l	d4,$dff054
	move.w	#%101000001,$dff058

	add.l	#152,a0
	dbra	d0,clea21BB
quitvBB:
	rts

runBB:	lea	singleBB,a1
	lea	screenBB,a0
	move.l	a0,d0
	swap	d0
	addq.w	#1,d0
	swap	d0
	and.l	#$ffff0000,d0
	move.l	d0,(a1)
	swap	d0
	lea	c11BB,a1
	move.w	d0,2(a1)
	move.w	d0,6(a1)
	move.w	d0,10(a1)
	move.w	d0,14(a1)
	addq.w	#1,d0
	move.w	d0,18(a1)

	move.l	singleBB,a0
	move.w	#[700<<6]!63,d0
	bsr.w	clearscreen_Abs

	lea	sinusBB,a0
	move.l	#[[endsinBB-sinusBB]/4]-1,d7
dureaBB:move.l	#255,d0
	sub.l	(a0),d0
	asl.w	#8,d0
	move.l	d0,(a0)+
	dbra	d7,dureaBB

	lea	makeBB,a0
	moveq	#44,d7

makkBB:	move.l	#$00e20000,(a0)+
	move.l	#$00e60000,(a0)+
	move.l	#$00ea0000,(a0)+
	move.l	#$00ee0000,(a0)+
	move.l	#$00f20000,(a0)+

	move.w	#$0180,(a0)+
	move.w	#$fff,(a0)+

	move.l	#$01be0000,d0
	moveq	#30,d6
creaitBB:
	move.l	d0,(a0)+
	sub.l	#$00020000,d0
	dbra	d6,creaitBB

	move.b	d7,(a0)+
	move.b	#7,(a0)+
	move.w	#$fffe,(a0)+
	addq.w	#2,d7
	cmp.w	#$fe+4,d7
	bne.b	dupBB
	move.l	#$ffddfffe,(a0)+
dupBB:	cmp.w	#344,d7
	blt.b	makkBB
	move.l	#$01000000,(a0)+
	move.l	#-2,(a0)+

	lea	copperBB,a0
	add.l	#[makeBB-copperBB],a0
	lea	makepBB,a1
	move.l	a0,(a1)

	lea	scractBB,a5
	move.l	singleBB,(a5)
	lea	pl1BB,a4

	lea	x1BB,a2
	lea	x2BB,a3
	lea	y1BB,a0
	lea	y2BB,a1

	moveq	#4,d7

asawBB:	move.l	#160,d0
	move.l	#160-128,d1

lopezBB:move.w	d0,(a2)
	move.w	d1,(a3)
	move.w	#0,(a0)
	move.w	#255,(a1)
		
	bsr.w	lineBB

	add.l	pl1BB,d1
	cmp.l	#160+128,d1
	blt.b	lopezBB

	add.l	#bplsizeBB,(a5)

	move.l	(a4),d0
	add.l	d0,(a4)

	dbra	d7,asawBB

	lea	kulsadrBB,a0
	lea	sinusBB+19*4,a1
	move.l	a1,(a0)

	lea	OkeyBB,a5
	move.l	a5,Vblk_Ptr
	
	move.w	(a0),d0
	or.w	#$8020,d0
	move.w	d0,$dff09a

	bsr.w	fillBB
	WaitBlit

	lea	copperBB,a0
	move.l	a0,$dff080
	move.w	d0,$dff088


RepFadeBB:
	lea	makeBB+$16,a0
	lea	bcgrBB,a1
	moveq	#0,d6
	move.l	#140,d7
FadeBBZ:
	move.w	(a1)+,d0
	move.w	(a0),d1
	bsr.w	FadeItBBA

	dbra	d7,FadeBBZ
	waitframe
	waitframe
	tst.b	d6
	bne.w	RepFadeBB

myszBB:	move.l	#$ff,d7
	lea	sinusBB,a0
	lea	dodajnikBB,a2
	lea	czasBB,a3
	lea	kulsadrBB,a4
	lea	ktoryBB,a6
	move.l	(a4),a1

lokqBB:	move.l	(a1)+,d0
	move.l	(a2)+,d1
	move.l	(a0),d2
	cmp.l	d2,d0
	ble.b	lessBB
	add.l	d1,(a0)
	bra.b	okaBB
lessBB:
	sub.l	d1,(a0)
okaBB:	addq.l	#4,a0
	cmp.l	#200,(a3)
	bne.b	finishBB

	addq.l	#1,(a6)
	cmp.l	#5,(a6)
	beq.b	quitPRBB
	clr.l	(a3)
	add.l	#1024,(a4)

	bsr.w	setaddBB
	bra.b	hahaBB
finishBB:
	dbra	d7,lokqBB

hahaBB:	bra.s	myszBB

quitPRBB:
	lea	czasBB,a0
	clr.l	(a0)

	lea	kierBB,a0
	bset	#7,(a0)
m2BB:	btst	#7,(a0)
	beq.b	totuBB
	bra.b	m2bb
ToTuBB:
	bset	#6,(a0)
RepFadeBBt:
	lea	makeBB+$16,a0
	moveq	#0,d6
	move.l	#140,d7
FadeBBt:
	move.w	#$f00,d0
	move.w	(a0),d1
	bsr.w	FadeItBBA

	dbra	d7,FadeBBt
	waitframe
	waitframe
	tst.b	d6
	bne.w	RepFadeBBt

RepFadeBBx:
	lea	makeBB+$16,a0
	moveq	#0,d6
	move.l	#140,d7
FadeBBx:
	moveq	#0,d0
	move.w	(a0),d1
	bsr.w	FadeItBBA

	dbra	d7,FadeBBx
	waitframe
	waitframe
	tst.b	d6
	bne.w	RepFadeBBx

quitBB:	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr
	rts

setaddBB:
	move.l	#$ff,d7
	lea	sinusBB,a0
	move.l	kulsadrBB,a1
	lea	dodajnikBB,a2
lokiqBB:move.l	(a0)+,d0
	move.l	(a1)+,d1
	sub.l	d0,d1
	bpl.b	plusikBB
	neg.l	d1
plusikBB:
	divu.w	#100,d1
	and.l	#$ffff,d1
	move.l	d1,(a2)+
	dbra	d7,lokiqBB
	rts
FadeItBBA:
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$00f,d2
	and.w	#$00f,d3
	cmp.w	d2,d3
	beq.b	Equal1BBA
	bgt.b	Greater1BBA

	addq.w	#$001,d1
	moveq	#1,d6
	bra.b	Equal1BBA
Greater1BBA:
	moveq	#1,d6
	sub.w	#$001,d1
Equal1BBA:
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$0f0,d2
	and.w	#$0f0,d3
	cmp.w	d2,d3
	beq.b	Equal2BBA
	bgt.b	Greater2BBA

	moveq	#1,d6
	add.w	#$010,d1
	bra.b	Equal2BBA
Greater2BBA:
	moveq	#1,d6
	sub.w	#$010,d1
Equal2BBA:
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$f00,d2
	and.w	#$f00,d3
	cmp.w	d2,d3
	beq.b	Equal3BBA
	bgt.b	Greater3BBA

	moveq	#1,d6
	add.w	#$100,d1
	bra.b	Equal3BBA
Greater3BBA:
	moveq	#1,d6
	sub.w	#$100,d1
Equal3BBA:
	move.w	d1,(a0)
	lea	$98(a0),a0

	cmp.w	#$ffdd,-$16(a0)
	bne.b	noskipBBA
	addq.l	#4,a0
NoSkipBBA:
	rts
lineBB:	movem.l	d0-d6,-(sp)
	move.w	(a0),d0
	cmp.w	(a1),d0
	beq.w	l_quitBB
	bhi.b	l_noychBB
	move.w	(a1),(a0)
	move.w	d0,(a1)
	move.w	(a2),d0
	move.w	(a3),(a2)
	move.w	d0,(a3)
l_noychBB:
	subq.w	#1,(a0)
l_nodecBB:
	move.w	(a2),d0
	sub.w	(a3),d0
	bpl.s	l_xplus1BB
	move.w	(a0),d1
	sub.w	(a1),d1
	add.w	d0,d1
	bpl.s	l_zplus2BB
	moveq	#%11001,d5
	bra.s	l_endoBB
l_zplus2BB:
	moveq	#%00101,d5
	bra.s	l_endoBB
l_xplus1BB:
	move.w	(a0),d1
	sub.w	(a1),d1
	sub.w	d0,d1
	bpl.s	l_zplus4BB
	moveq	#%11101,d5
	bra.s	l_endoBB
l_zplus4BB:
	moveq	#%01101,d5
l_endoBB:
	or.l	#$0b4a0002,d5
	move.w	(a2),d0
	sub.w	(a3),d0
	bpl.s	l_plus2BB
	neg.w	d0		
l_plus2BB:
	move.w	(a0),d1
	sub.w	(a1),d1
	bpl.s	l_plus3BB
	neg.w	d1
l_plus3BB:
	cmp.w	d0,d1
	bpl.s	l_wiekszeBB
	exg	d0,d1
l_wiekszeBB:
	move.w	d0,d3
	move.w	d1,d4
	exg	d0,d1
	asl.w	#2,d1
	move.w	d1,d2
	asl.w	#1,d0
	sub.w	d0,d1
	bpl.s	l_plusBB
	bset	#6,d5
l_plusBB:
	move.l	d1,d6
	move.w	d3,d1
	sub.w	d4,d1
	asl.w	#2,d1
	swap	d2
	move.w	d1,d2
	move.w	(a2),d0
	and.w	#15,d0
	asl.l	#8,d0
	asl.l	#4,d0
	swap	d5
	or.w	d0,d5
	swap	d5
	move.w	(a2),d0
	move.w	(a0),d1
	and.l	#$ff,d1
	asl.l	#6,d1
	asr.w	#3,d0
	add.w	d0,d1
	add.l	scractBB,d1
	move.w	d4,d0
	addq.w	#1,d0		
	asl.w	#6,d0
	bset	#1,d0
	btst	#14,$dff002
l_WaitBlit:
	btst	#14,$dff002
	bne.s	l_WaitBlit
	move.l	d2,$dff062
	move.l	d1,$dff048
	move.l	d1,$dff054
	move.l	d5,$dff040
	move.l	d6,$dff050
	move.w	#64,$dff060
	move.w	#64,$dff066
	move.l	#$ffff8000,$dff072
	move.l	#$ffffffff,$dff044
	move.w	d0,$dff058
l_quitBB:
	movem.l	(sp)+,d0-d6
	rts

fillBB:	move.l	singleBB,d0
	moveq	#4,d7
peteBB:	move.l	d0,d1
	add.l	#$3fc0-2,d1
	WaitBlit
	move.l	#$ffffffff,$dff044
	move.l	d1,$dff050
	move.l	d1,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#0,$dff064
	move.w	#0,$dff066
	move.w	#%11111111100000,$dff058
	add.l	#bplsizeBB,d0
	dbra	d7,peteBB
	rts


********************************************************
StartSeq:

ScrX=	29*2
BplLen=	$2976

	lea	screeno,a0
	lea	screenn,a1
	move.l	a0,(a1)
	move.l	a0,d0

	moveq	#5,d7
	lea	c11o,a1
setca:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#BplLen,d0
	dbra	d7,setca

	lea	coppero,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	moveq	#35,d7
aqw:	waitframe
	dbra	d7,aqw


	bsr.w	SunOn

FUp0:	waitframe
	waitframe
	waitframe
	waitframe
	lea	colors+2,a0
	lea	palette,a1
	moveq	#31,d7
	moveq	#0,d6
FUp:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUp
	tst.b	d6
	bne.b	FUp0

main1:	lea	$dff000,a6
	cmp.l	#-4*7,RobaX
	bgt.w	PlRobak
	cmp.l	#4*4,RobakNr
	beq.w	MoveRobak

PlRobak:
	addq.l	#4,RobakNr
	cmp.l	#RaEnd-RobakAnim,RobakNr
	blt.b	NoRLo
	clr.l	RobakNr
	subq.l	#4,RobaX

NoRLo:	move.l	RobakNr,d0
	lea	RobakAnim,a1
	add.l	d0,a1
	lea	Robak1,a0
	add.l	(a1),a0

	move.l	screenn,a5
	lea	ScrX*117+44(a5),a5
	add.l	RobaX,a5

	waitblit
	move.l	#$19f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#ScrX-14,$64(a6)

	moveq	#5,d7

PutRob:	waitblit
	move.l	a0,$dff050
	move.l	a5,$dff054
	move.w	#[49<<6]!7,$58(a6)
	lea	BplLen(a5),a5
	lea	$1014(a0),a0
	dbra	d7,PutRob

	moveq	#7,d7
Wti1:	waitframe
	dbra	d7,Wti1

	bra.w	Main1


MoveRobak:
	bsr.w	SunOn
	cmp.L	#6,FaceNr
	beq.b	NoFE
	addq.l	#1,FaceNr
NoFE:
	cmp.l	#12,Rob2Nr
	bge.w	Fall
	addq.l	#1,Rob2Nr
	move.l	Rob2Nr,d0

	mulu.w	#$98,d0
	lea	Robak2,a0
	add.l	d0,a0

	move.l	screenn,a5
	lea	ScrX*124+16(a5),a5

	waitblit
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#ScrX-4,$64(a6)

	moveq	#5,d7

PutRo2:	waitblit
	move.l	a0,$dff050
	move.l	a5,$dff054
	move.w	#[37<<6]!2,$58(a6)
	lea	BplLen(a5),a5
	lea	$07b4(a0),a0
	dbra	d7,PutRo2

	moveq	#10,d7
Wti2:	waitframe
	dbra	d7,Wti2

	bra.w	MoveRobak

Fall:
	add.l	#58*8,TrsiY
	cmp.l	#58*88,TrsiY
	bge.w	Quit

	move.l	screenn,a5
	move.l	TrsiY,d0
	bmi.b	ShowPart

	add.l	d0,a5
	addq.l	#8,a5

	lea	screen2+80*ScrX+8,a0

	waitblit
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#[ScrX-24]<<16![ScrX-24],$64(a6)

	moveq	#5,d7

PutTr:	waitblit
	move.l	a0,$dff050
	move.l	a5,$dff054
	move.w	#[86<<6]!12,$58(a6)
	lea	BplLen(a5),a5
	lea	BplLen(a0),a0
	dbra	d7,PutTr
	bra.b	Fend
	
ShowPart:
	neg.l	d0

	addq.l	#8,a5

	lea	screen2+80*ScrX+8,a0
	add.l	d0,a0
	divu.w	#58,d0

	moveq	#86,d1
	sub.w	d0,d1
	asl.w	#6,d1
	or.w	#12,d1

	waitblit
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#[ScrX-24]<<16![ScrX-24],$64(a6)

	moveq	#5,d7

PutTr2:	waitblit
	move.l	a0,$dff050
	move.l	a5,$dff054
	move.w	d1,$58(a6)
	lea	BplLen(a5),a5
	lea	BplLen(a0),a0
	dbra	d7,PutTr2

Fend:	waitframe

	bra.w	Fall
Quit:
FFp0:	waitframe
	lea	colors+6,a0
	moveq	#30,d7
	moveq	#0,d6
FFp:	move.w	(a0),d1
	move.w	#$fff,d0
	bsr.w	fade
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FFp
	tst.b	d6
	bne.b	FFp0


	lea	Screen2,a0
	move.l	a0,d0

	moveq	#5,d7
	lea	c11o,a1
setca2:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#BplLen,d0
	dbra	d7,setca2

FGp0:	waitframe
	lea	colors+6,a0
	lea	palette+2,a1
	moveq	#30,d7
	moveq	#0,d6
FGp:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FGp
	tst.b	d6
	bne.b	FGp0

fdup:	clr.l	Counter
	lea	WWSUpp,a0
	lea	WWSUW,a1
	move.l	#WWSUppe-WWSUpp,d0
	bsr.w	Decrunch
NT1:	cmp.l	#50*6-10,Counter
	ble.b	NT1

FGpx:	waitframe
	waitframe
	lea	colors+6,a0
	moveq	#30,d7
	moveq	#0,d6
FGp1x:	move.w	(a0),d1
	move.w	#0,d0
	bsr.w	fade
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FGp1x
	tst.b	d6
	bne.b	FGpx

	bsr.w	WeWill

	rts

SunOn:	move.l	FaceNr,d0
	asl.l	#5,d0
	lea	Faces,a0
	add.l	d0,a0
	lea	$dff000,a6
	move.l	screenn,a5
	lea	ScrX*36+2(a5),a5
	waitblit
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#ScrX-2,$64(a6)

	moveq	#5,d7
PutSun:	waitblit
	move.l	a0,$dff050
	move.l	a5,$dff054
	move.w	#[16<<6]!1,$58(a6)
	lea	BplLen(a5),a5
	lea	2*112(a0),a0
	dbra	d7,PutSun
	rts

;WE WILL SMASH YOU

WeWill:	lea	WeW,a0
	lea	c11W,a1
	bsr.w	SetAdW

	lea	WillW,a0
	lea	c12W,a1
	bsr.w	SetAdW

	lea	SmashW,a0
	lea	c13W,a1
	bsr.w	SetAdW
	lea	YouW,a0
	lea	c14W,a1
	bsr.w	SetAdW

	waitframe
	lea	copperW,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	move.l	#10,d7
WainW:	waitframe
	dbra	d7,WainW

	lea	cols1W+6,a2
	bsr.w	Fade1W
	lea	cols2W+6,a2
	bsr.w	Fade1W
	lea	cols3W+6,a2
	bsr.w	Fade1W
	lea	cols4W+6,a2
	bsr.w	Fade1W

	move.l	#2*50,d7
MainW:	waitframe
	dbra	d7,MainW
	moveq	#0,d0

MvRW:	waitframe
	move.w	d0,d1
	not.b	d1
	and.w	#$f,d1
	move.w	d1,d2
	asl.w	#4,d2
	or.w	d2,d1
	move.w	d1,Rig1W+2
	move.w	d1,Rig3W+2

	not.b	d1
	move.w	d1,Rig2W+2
	move.w	d1,Rig4W+2

	move.l	d0,d1
	asr.l	#3,d1
	and.b	#$fe,d1

	lea	WeW,a0
	add.l	d1,a0
	lea	c11W,a1
	bsr.w	SetAdW
	lea	SmashW,a0
	add.l	d1,a0
	lea	c13W,a1
	bsr.w	SetAdW

	lea	WillW,a0
	sub.l	d1,a0
	lea	c12W,a1
	bsr.w	SetAdW
	lea	YouW,a0
	sub.l	d1,a0
	lea	c14W,a1
	bsr.w	SetAdW

	bchg.b	#0,ChangerW
	beq.b	NoFdW
	bchg.b	#1,ChangerW
	beq.b	NoFdW
	bchg.b	#2,ChangerW
	beq.b	NoFdW
	movem.l	d0-a6,-(sp)
	lea	cols1W+6,a2
	bsr.w	Fade2W
	lea	cols2W+6,a2
	bsr.w	Fade2W
	lea	cols3W+6,a2
	bsr.w	Fade2W
	lea	cols4W+6,a2
	bsr.w	Fade2W
	movem.l	(sp)+,d0-a6
NoFdW:
	addq.l	#4,d0
	cmp.l	#320,d0
	blt.w	MvRW

QuitW:	rts

SetAdW:	movem.l	d0/d7/a1,-(sp)
	moveq	#5,d7
	move.l	a0,d0
setcaW:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$3fc0,d0
	dbra	d7,setcaW
	movem.l	(sp)+,d0/d7/a1
	rts

Fade1W:	move.l	a2,a0
	moveq	#30,d7
ToWhW:	move.w	#$fff,(a0)
	addq.l	#4,a0
	dbra	d7,ToWhW

FadeAW:	waitframe
	lea	palette+2,a1
	move.l	a2,a0
	moveq	#30,d7
	moveq	#0,d6
FUpW:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FUpW
	tst.b	d6
	bne.b	FadeAW
	rts

Fade2W:	move.l	a2,a0
	moveq	#30,d7
	moveq	#0,d6
F2UpW:	move.w	(a0),d1
	move.w	#$f0f,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,F2UpW
	rts



screenn:	dc.l	0
FaceNr:		dc.l	0
RobakNr:	dc.l	0
RobaX:		dc.l	0
Rob2Nr:		dc.l	0
TrsiY:		dc.l	-58*80
ChangerW:	dc.w	0
Q=686
RobakAnim:
	dc.l	0,1*Q,2*Q,3*Q,4*Q,5*Q
RaEnd:

palette:dc.w $0000,$0eee,$0ccc,$0aaa
	dc.w $0888,$0666,$0444,$0222
	dc.w $0020,$0040,$0161,$0383
	dc.w $05a5,$07c7,$09e9,$0bfb
	dc.w $0200,$0400,$0600,$0820
	dc.w $0a40,$0d60,$0f80,$0002
	dc.w $0004,$0116,$0228,$033a
	dc.w $055c,$077e,$0fb0,$0650

****************************************************************

SzerokoscQ	= 4
ModuloXQ	= 36
WysokoscQ	= 32
InZoomQ		= 1

BitSetQ:	MACRO
	move.w	(a2)+,d2
	move.b	(a3)+,d1

	IF \2=0
	btst.b	#\1,(a0)
	ELSE
	btst.b	#\1,(a0)+
	ENDC

	beq.b	\@1Q
	bset.b	d1,(a1,d2.w)
\@1Q:
	ENDM

okeyQ:	lea	endingQ,a0
	tst.b	(a0)
	bne.w	quitvQ

	lea	counterQ,a0
	cmp.l	#164+60,(a0)
	bne.b	lineinQ
	addq.l	#1,(a0)
	lea	copper2Q,a0
	move.l	a0,$dff080
	move.w	a0,$dff088
	bra.w	quitvQ
lineinQ:
	cmp.l	#164+60,(a0)
	blt.b	noexgcQ
	addq.l	#1,(a0)

	lea	posQ,a1
	move.l	scr2adrq,a2

	moveq	#2,d7
repclrQ:
	move.w	(a1),d0
	move.w	d0,d1
	asr.w	#3,d0
	not.b	d1
	bclr.b	d1,(a2,d0.w)
	move.w	2(a1),d0
	move.w	d0,d1
	asr.w	#3,d0
	not.b	d1
	bclr.b	d1,(a2,d0.w)
	addq.w	#1,(a1)
	subq.w	#1,2(a1)
	cmp.w	#174,(a1)
	bne.b	NoendQ
	lea	Endingq,a2
	move.b	#-1,(a2)
	bra.w	quitvQ

noendQ:
	dbra	d7,repclrQ

	bra.w	quitvQ
noexgcQ:

	lea	signalsQ,a0
	move.w	cmpikQ,d0
	cmp.w	tablQ,d0
	bne.b	noquitVQ
	bset	#0,(a0)
	bset	#1,(a0)
	bra.w	quitvQ
noquitVQ:

	btst	#1,(a0)
	bne.w	QuitVxQ
ToDr:
	btst	#1,SignalsQ
	bne.w	QuitVQ

	lea	screenpQ,a0
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	move.l	d0,d2
	add.l	#128*64+20,d2
	movem.l	d0-d2,(a0)

	bsr.w	setscrQ

	waitblit
	move.l	#0,$dff044
	move.l	#$01000000,$dff040
	move.w	#$14,$dff066
	move.l	screenpQ,$dff054
	move.w	#256<<6!22,$dff058

	moveq	#SzerokoscQ*8-1,d7
	lea	adtbQ,a0
	lea	tablQ,a1
	lea	adrsQ,a2
	lea	bitsQ,a3
	lea	pozYQ,a4

adlpQ:	move.w	(a0)+,d0
AsPar:	asl.w	#4,d0
	add.w	d0,(a1)
	move.w	(a1),d1

	add.w	YposQ,d1
	cmp.w	#66*64,d1
	blt.b	ltblQ
	move.w	#66*64,d1
ltblQ:
	cmp.w	#-64*65,d1
	bgt.b	ltbl2Q
	move.w	#-64*65,d1
ltbl2Q:	add.w	d1,d1
	and.b	#$c0,d1
	move.w	d1,(a4)+

	move.w	(a1)+,d1
	asr.w	#5,d1

	add.w	XposQ,d1
	cmp.w	#188,d1
	blt.b	ltbtQ
	move.w	#188,d1

ltbtQ:
	cmp.w	#-165,d1
	bgt.b	ltbt2Q
	move.w	#-165,d1
ltbt2Q:
	move.w	d1,d2
	asr.w	#3,d2
	not.b	d1
	move.b	d1,(a3)+
	move.w	d2,(a2)+
	dbra	d7,adlpQ

	lea	srakaQ,a0
	add.l	LetterAdrQ,a0

	lea	pozYQ,a4
	lea	adrsQ,a5
	lea	bitsQ,a6

	moveq	#0,d1
	moveq	#WysokoscQ-1,d5

	waitblit

loop3Q:	moveq	#SzerokoscQ-1,d7

	move.l	a5,a2
	move.l	a6,a3

	move.l	screenpQ+8,a1
	move.w	(a4)+,d1
	ext.l	d1
	add.l	d1,a1

Loop2Q:	BitSetQ 7,0
	BitSetQ 6,0
	BitSetQ 5,0
	BitSetQ 4,0
	BitSetQ 3,0
	BitSetQ 2,0
	BitSetQ 1,0
	BitSetQ 0,1

	dbra	d7,loop2Q

	If ModuloXQ>0
	If ModuloXQ<9
	addq.l	#ModuloXQ,a0
	Else
	lea	ModuloXQ(a0),a0
	EndC
	EndC
	dbra	d5,loop3Q


quitvQ:	rts

quitvxQ:lea	CounterQ,a0
	addq.l	#1,(a0)
	cmp.l	#160,(a0)
	bgt.b	cointQ
	bra.w	ToDr
cointQ:
	lea	CopperQ,a1

	cmp.b	#$aa,MvDnQ-CopperQ(a1)
	beq.b	AllMovedQ
	addq.b	#2,MvDnQ-CopperQ(a1)
	move.b	MvDnQ-CopperQ(a1),d0
	move.b	d0,MvDn2Q-CopperQ(a1)
	move.l	#$01005000,MvDn2Q+4-CopperQ(a1)
	move.l	#$01800113,Cip-CopperQ(a1)

	tst.b	MvUp2Q-CopperQ(a1)
	bne.b	NozeQ
	move.l	#$01be0000,MvUpQ-CopperQ(a1)
NozeQ:

	subq.b	#2,MvUp2Q-CopperQ(a1)
	subq.b	#2,MvUp3Q-CopperQ(a1)
AllMovedQ:
	bra.w	ToDR

setscrQ:move.l	screenpQ,d0
	lea	c11Q,a1
	moveq	#0,d7
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

DotsTyper:
	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr

	lea	DTScr,a0
	move.w	#520<<6!63,d0
	bsr.w	clearscreen_abs

	lea	DTScr,a0
	lea	screenpQ,a1
	add.l	#64,a0
	move.l	a0,(a1)+
	add.l	#$5000,a0
	move.l	a0,(a1)
	add.l	#$5000+64,a0
	lea	backgroundQ,a1
	move.l	a0,(a1)
	move.l	a0,d0

	lea	c11Q+8,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)

	add.l	#$5000,a0
	move.l	a0,d0
	lea	c12Q,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)

	lea	scr2adrQ,a1
	move.l	a0,(a1)
	moveq	#63,d0
drwQ:	clr.b	(a0)+
	dbra	d0,drwQ

	lea	ZoomPicQ,a0
	lea	c13Q,a1
	move.l	a0,d0
	moveq	#2,d7
setpQ:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#(352*255)/8,d0
	dbra	d7,setpQ

	lea	tablQ,a0
	moveq	#0,d0
lpcrQ:	move.w	d0,(a0)+
	add.w	#10,d0
	cmp.w	#900,d0
	blt.b	lpcrQ

	lea	adtbQ,a0
	move.l	#-[SzerokoscQ]*8,d0
lpcr2Q:	move.w	d0,d1
	move.w	d1,(a0)+
	add.w	#2,d0
	cmp.w	#[SzerokoscQ]*8,d0
	bne.b	lpcr2Q

	lea	tablQ,a0
	lea	adtbQ,a1

	move.l	#[endtablQ-tablQ]/2,d7

	lea	cmpikQ,a2
	move.w	(a0),d0
	move.w	(a1),d1
	muls.w	#11,d1
	add.w	d1,d0
	move.w	d0,(a2)
	
lopQaQ:	move.w	(a1),d0
	neg.w	(a1)+
	muls	#11+8*60,d0
	add.w	d0,(a0)+
	dbra	d7,lopqaQ

	lea	TablQ,a0
	lea	TablBufQ,a1
	move.l	#AbsEndTablQ-TablQ-1,d7
CrtBufQ:move.b	(a0)+,(a1)+
	dbra	d7,CrtBufQ

	bsr.w	SetScrQ

	waitframe
	lea	Vblk_Ptr,a0
	lea	Return_Abs,a1
	move.l	a1,(a0)

	lea	copper2Q,a0
	move.l	a0,$dff080
	move.w	a0,$dff088

linein2Q:
	lea	posQ,a1
	move.l	scr2adrq,a2

	moveq	#2,d7
repclr2Q:
	move.w	(a1),d0
	move.w	d0,d1
	asr.w	#3,d0
	not.b	d1
	bset.b	d1,(a2,d0.w)
	move.w	2(a1),d0
	move.w	d0,d1
	asr.w	#3,d0
	not.b	d1
	bset.b	d1,(a2,d0.w)
	subq.w	#1,(a1)
	addq.w	#1,2(a1)
	cmp.w	#1,(a1)
	beq.b	Proced
	dbra	d7,repclr2Q
	waitframe2
	bra.b	Linein2Q

Proced:
	lea	copperQ,a0
	move.l	a0,$dff080
	move.w	d0,$dff088
;	bra	allmoved2q

Proc2:	lea	CopperQ,a1

	cmp.b	#$30,MvDnQ-CopperQ(a1)
	beq.b	AllMoved2Q
	subq.b	#2,MvDnQ-CopperQ(a1)
	move.b	MvDnQ-CopperQ(a1),d0
	addq.b	#1,d0
	move.b	d0,MvDn2Q-CopperQ(a1)

	cmp.b	#$fe,MvUp2Q-CopperQ(a1)
	bne.b	Noze2Q
	move.l	#$ffddfffe,MvUpQ-CopperQ(a1)
Noze2Q:

	addq.b	#2,MvUp2Q-CopperQ(a1)
	addq.b	#2,MvUp3Q-CopperQ(a1)
	subq.b	#2,Cip-CopperQ(a1)
	waitframe
	move.w	#$5000,Bpc
	move.w	#$5000,Bpc2
	bra.w	Proc2

AllMoved2Q:

	lea	Vblk_Ptr,a0
	lea	OkeyQ,a1
	move.l	a1,(a0)

mainQ:	lea	txtposQ,a0
	lea	textQ,a1
	lea	lettabQ,a2
	lea	LetterAdrQ,a3

	addq.w	#1,(a0)
	moveq	#0,d1
RepLetQ:move.w	(a0),d0
	move.b	(a1,d0.w),d1
	bne.b	NoEndTxtQ
	clr.w	(a0)
	bra.w	PreQuitQ
NoEndTxtQ:
	cmp.b	#$20,d1
	bne.b	NoSpaceQ
	lea	XposQ,a6
	add.w	#33,(a6)
	bra.b	MainQ
NoSpaceQ:
	cmp.b	#-1,d1
	bne.b	NoRetQ
	lea	XposQ,a6
	move.w	#-150,(a6)
	lea	YposQ,a6
	addq.w	#1,(a0)
	move.b	1(a1,d0.w),d1
	ext.w	d1
	asl.w	#5,d1	
	add.w	d1,(a6)
	bra.b	MainQ

NoRetQ:	cmp.b	#-2,d1
	bne.b	NoChgXQ
	addq.w	#1,(a0)
	lea	XposQ,a6
	move.b	1(a1,d0.w),d1
	add.w	d1,(a6)
	bra.b	MainQ
NoChgXQ:
	cmp.b	#-3,d1
	bne.b	NoB
	bra.w	MainQ
NoB:

	add.w	d1,d1
	move.w	(a2,d1.w),d1
	move.l	d1,(a3)
	
	lea	signalsQ,a6
	bclr	#1,(a6)
	bclr	#0,(a6)
testQ:	btst	#0,(a6)
	bne.b	NextLetterQ
;	btst	#6,$bfe001
;	beq.w	quitQ
	bra.b	testQ

NextLetterQ:

StlQ:	waitblit
	move.l	#$0dfc0000,$dff040
	move.l	#-1,$dff044
	move.w	#$14,$dff062
	move.w	#$14,$dff064
	move.w	#$14,$dff066
	move.l	screenpQ,$dff050
	move.l	backgroundQ,d1
	move.l	d1,$dff04c
	move.l	d1,$dff054
	move.w	#255<<6!22,$dff058

	lea	TablQ,a4
	lea	TablBufQ,a5
	move.l	#AbsEndTablQ-TablQ-1,d7
RenewBufQ:
	move.b	(a5)+,(a4)+
	dbra	d7,RenewBufQ
	lea	XposQ,a6
	add.w	#33,(a6)
	bra.w	MainQ

PreQuitQ:
	lea	endingQ,a1
PreQuitxQ:
;	btst	#6,$bfe001
;	beq.b	quitQ
	tst.b	(a1)
	beq.b	prequitxQ
	
QuitQ:	lea	Vblk_Ptr,a0
	lea	Return_Abs,a1
	move.l	a1,(a0)
	rts

textQ:	dc.b	' '
	dc.b	-1,26,-2,8
	dc.b	'bicd  jdjd'
	dc.b	-1,56,-2,8
	dc.b	'feo   mddl'
	dc.b	-1,66,-2,8
	dc.b	'hnlgb  omc'
	dc.b	-1,46,-2,8
	dc.b	'p'
	dc.b	-1,1,0,0,0,0
	even
****************************************************

dotsH	=	$560
ilesinH	=	2
ad0H	=	4
ad1H	=	2
ad2H	=	6
ad3H	=	8
sp0H	=	32
sp1H	=	18
sp2H	=	22
sp3H	=	26

fragH:	move.w	(a0)+,d0
	add.w	(a1)+,d0
	move.b	d0,d1
	asr.w	#3,d0
	add.w	(a2)+,d0
	add.w	(a3)+,d0
	not.b	d1
	bset.b	d1,(a5,d0.w)
	not.b	d1
	neg.w	d0
	bset.b	d1,(a5,d0.w)

endfragH:


okeyH:	lea	screenpH,a0
	move.l	8(a0),d0
	move.l	4(a0),8(a0)
	move.l	(a0),4(a0)
	move.l	d0,(a0)

	waitblit
	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#6,$dff066
	move.l	screenpH,$dff054
	move.w	#%100000000010001,$dff058

	lea	possH,a6
	move.l	screenpH+4,a5
	add.l	#40*128+16,a5

	add.w	#sp0H,(a6)
	cmp.w	#dotsH*2,(a6)
	ble.b	okn1H
	sub.w	#dotsH*2,(a6)

okn1H:	add.w	#sp1H,2(a6)
	cmp.w	#dotsH*2,2(a6)
	ble.b	okn2H
	sub.w	#dotsH*2,2(a6)

okn2H:	add.w	#sp2H,4(a6)
	cmp.w	#dotsH*2,4(a6)
	ble.b	okn3H
	sub.w	#dotsH*2,4(a6)

okn3H:	add.w	#sp3H,6(a6)
	cmp.w	#dotsH*2,6(a6)
	ble.b	okn4H
	sub.w	#dotsH*2,6(a6)
okn4H:

	move.l	repl1H,a0
	cmp.l	endrH,a0
	beq.b	NSHH
	move.w	#$3018,(a0)
	add.l	#4*[EndfragH-fragH],a0
	move.w	#$4e75,(a0)
	move.l	a0,repl1H
	bra.b	nsh3H
NSHH:
	move.l	repl2H,a0
	move.l	replpH,d0
	add.l	#4*[endfragH-fragH],d0
	cmp.l	a0,d0
	bge.b	NSH2H
	sub.l	#4*[EndfragH-fragH],a0
	move.w	#$4e75,(a0)
	move.l	a0,repl2H
	bra.b	NSH3H
NSH2H:	move.b	#-1,QuH
NSH3H:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3

	lea	sins0H,a0
	lea	sins1H,a1
	lea	sins2H,a2
	lea	sins3H,a3


	move.w	(a6),d0
	move.w	2(a6),d1
	move.w	4(a6),d2
	move.w	6(a6),d3
	add.l	d0,a0
	add.l	d1,a1
	add.l	d2,a2
	add.l	d3,a3

	move.l	replpH,a6
	jsr	(a6)
	jsr	setscH
	rts

setscH:	move.l	screenpH+4,d0
	add.l	#80-4,d0
	lea	c11H,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	add.l	#$2800,d0
	swap	d0
	move.w	d0,10(a1)
	swap	d0
	move.w	d0,14(a1)
	rts

Dotsy:	waitframe
	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr
	lea	freeH,a0
	lea	screennH,a1
	move.l	a0,(a1)

	lea	freeh,a0
	move.w	#[$3ff<<6]!63,d0
	bsr	clearscreen_Abs


	move.l	screennH,a0
	move.l	a0,replpH
	move.l	a0,repl1H
	add.l	#[endfragH-fragH]*dotsH+20,a0
	lea	screenpH,a1
	move.l	a0,(a1)
	add.l	#$2800,a0
	move.l	a0,4(a1)
	add.l	#$2800,a0
	move.l	a0,8(a1)

	move.l	replpH,a0
	move.l	#dotsH-1,d6
lp1H:	move.l	#[endfragH-fragH-1],d7
	lea	fragH,a1
lp2H:	move.b	(a1)+,(a0)+
	dbra	d7,lp2H
	dbra	d6,lp1H
	move.l	a0,endrH
	move.l	a0,repl2H
	move.w	#$4e75,(a0)+
	waitframe
	lea	OkeyH,a0
	move.l	a0,Vblk_Ptr

	waitframe
	waitframe2
	lea	copperH,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

myszH:	tst.b	Quh
	bne.b	rth
	bra.s	myszH
	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr
	waitframe
Rth:	rts



screenpH:	dc.l	0,0,0
replpH:		dc.l	0
screennH:	dc.l	0
possH:		dc.w	1300,1300,1300,1300
repl1H:		dc.l	0
repl2H:		dc.l	0
endrH:		dc.l	0
quH:		dc.l	0

************************************************************
balls:	lea	Return_abs,a0
	move.l	a0,Vblk_Ptr

	lea	end_b,a0
	lea	mul40p_b,a1
	move.l	a0,(a1)+
	add.l	#512,a0
	move.l	a0,(a1)+
	add.l	#512,a0
	move.l	a0,(a1)+
	add.l	#512,a0
	lea	screenn_b,a1
	move.l	a0,(a1)
	bsr.w	clearp_2_b

	move.l	ptsp_b,a0
	move.l	#255,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
lmas_2_b:
	move.b	d0,(a0)+
	move.b	d1,(a0)+
	add.b	#16,d0
	cmp.b	d0,d2
	bne.b	noup_2_b
	addq.b	#3,d2
	move.b	d2,d0
	add.b	#16,d1
noup_2_b:
	dbra	d7,lmas_2_b

	move.l	mul40p_b,a0
	move.l	mul16p_b,a1
	moveq	#0,d0
cs40_2_b:
	move.l	d0,d1
	mulu.w	#40,d1
	move.w	d1,(a0)+
	move.l	d0,d1
	mulu.w	#20,d1
	move.w	d1,(a1)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.s	cs40_2_b

	move.l	screenn_b,a0
	lea	screenp_b,a1
	move.l	a0,(a1)
	add.l	#$a00,a0
	move.l	a0,12(a1)
	add.l	#$a00,a0
	move.l	a0,4(a1)
	add.l	#$2260,a0
	move.l	a0,8(a1)

	lea	dodtb_b,a0
	lea	dodx_b,a1
	lea	dody_b,a2
	lea	timeq_b,a3
	moveq	#[[dodtbe_b-dodtb_b]/4]-1,d7
mainl_b:move.b	(a0)+,(a1)
	move.b	(a0)+,(a2)
	move.b	(a0)+,1(a3)
	move.b	(a0)+,d0
	bsr.w	balls2_b
cntpa_b:dbra	d7,mainl_b
	move.w	#$fff,emptycopper+2
	bsr.w	sec
EndB:	waitframe
	sub.w	#$111,emptycopper+2
	bgt.b	EndB
	rts


okey_2_b:
	move.l	mul40p_b,a2
	lea	sin2_2_b,a3
	lea	paip_2_b,a5
	move.b	#17,(a5)
	move.l	screenp_b+4,2(a5)
	lea	ball_2_b,a0
	move.l	a0,6(a5)
	move.b	10(a5),11(a5)
	move.b	12(a5),13(a5)
	addq.b	#2,10(a5)
	addq.b	#1,12(a5)

	lea	screenp_b,a0
	waitblit
	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#12,$dff066
	move.l	(a0),d0
	addq.l	#2,d0
	move.l	d0,$dff054
	move.w	#%1000000000100,$dff058
	waitblit

	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#0,$dff066
	move.l	screenp_b+4,$dff054
	move.w	#%11010010010100,$dff058

	lea	sins_b,a0
	move.l	mul16p_b,a6

	move.l	ptsp_b,a1
	move.l	screenp_b,a4
	addq.l	#2,a4

	move.l	#255,d7
kopl_2_b:
	moveq	#0,d0
	moveq	#0,d1

	addq.b	#2,1(a1)
	addq.b	#2,(a1)

	move.b	(a1)+,d0
	move.b	(a1)+,d1

	add.w	d0,d0
	add.w	d1,d1
	move.w	d0,d2
	add.w	#254,d0
	move.w	(a0,d0.w),d0
	move.w	(a0,d1.w),d1
skipsa_2_b:
	muls.w	(a0,d2.w),d1
	cmp.w	#1,d0
	
	bmi.s	plsd_2_b
	neg.w	d1
	btst	#14,$dff002
	bne.s	plsd_2_b
	bsr.w	paintb_2_b
plsd_2_b:
	asr.w	#8,d1
	asr.w	#1,d1
	asr.w	#2,d0

	add.w	#32,d0
	add.w	#33,d1

	move.l	d0,d2
	asr.w	#3,d2
	not.b	d0
	add.w	d1,d1
	move.w	(a6,d1.w),d1
	add.w	d2,d1
	bset	d0,(a4,d1.w)
skips_2_b:
	dbra	d7,kopl_2_b

rept_2_b:
	tst.b	(a5)
	beq.b	lopqq_2_b
	btst	#14,$dff002
	bne.b	*-8
	bsr.b	paintb_2_b
	bra.b	rept_2_b
lopqq_2_b:
	lea	screenp_b,a0
	move.l	4(a0),d0
	move.l	8(a0),4(a0)
	move.l	d0,8(a0)
	move.l	(a0),d0
	move.l	12(a0),(a0)
	move.l	d0,12(a0)
	bsr.w	setsc_2_b

	lea	time_b,a0
	move.w	timeq_b,d0
	cmp.w	(a0),d0
	beq.b	fadeo_2_b
	addq.w	#1,(a0)
	lea	bcgcl_2_b,a0
	tst.w	(a0)
	beq.b	enough_2_b
	sub.w	#$111,(a0)
enough_2_b:
	rts
fadeo_2_b:
	lea	bcgcl_2_b,a0
	cmp.w	#$fff,(a0)
	bne.b	noty_2_b
	lea	endpat_b,a0
	move.b	#1,(a0)
	rts
noty_2_b:
	add.w	#$111,(a0)
	rts
paintb_2_b:
	tst.b	(a5)
	beq.w	return_2_b
	subq.b	#1,(a5)

	moveq	#0,d4
	moveq	#0,d5

	move.b	dodx_b,d4
	move.b	dody_b,d5
	add.b	d4,11(a5)
	add.b	d5,13(a5)

	move.b	11(a5),d4

	add.w	#256,d4
	move.b	(a3,d4.w),d4
	move.b	d4,d5

	and.b	#%1111,d4
	asl.w	#8,d4
	asl.w	#4,d4	

	move.w	d4,$dff042
	or.w	#%0000111111100010,d4
	move.w	d4,$dff040

	moveq	#0,d4
	move.b	d5,d4
	asr.w	#3,d4
	add.l	2(a5),d4

	move.l	#$ffffffff,$dff044
	move.l	#$001c0000,$dff060
	move.l	#$0008001c,$dff064

	move.b	13(a5),d5
	move.b	(a3,d5.w),d5
	add.w	d5,d5
	move.w	(a2,d5.w),d5
	add.l	d5,d4

	move.l	d4,$dff048
	move.l	6(a5),$dff04c
	move.l	screenp_b+12,$dff050
	move.l	d4,$dff054
	move.w	#%1000000000110,$dff058
return_2_b:
	rts

setsc_2_b:
	move.l	screenp_b+8,d0
	add.l	#40,d0
	lea	c11_2_b,a1
lopxc_2_b:
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

clearp_2_b:
	waitblit
	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#14,$dff066
	move.l	screenn_b,$dff054
	move.w	#%10000010111111,$dff058
	waitblit
	rts

balls2_b:
	movem.l	d0-a6,-(sp)
	lea	time_b,a0
	clr.w	(a0)
	lea	endpat_b,a0
	clr.b	(a0)

	waitframe
	lea	okey_2_b,a0
	move.l	a0,Vblk_Ptr

;	waitframe
	lea	copper_2_b,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	lea	endpat_b,a0
mysz_2_b:
	tst.b	(a0)
	beq.b	mysz_2_b

quit_2_b:
	lea	return_abs,a0
	move.l	a0,Vblk_Ptr
	movem.l	(sp)+,d0-a6
	rts


***************************

ileptsJ=9000

frag1J:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
endfrag1J:

frag2J:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a5,d1.w)
	bset.b	d0,(a4,d1.w)
endfrag2J:

frag3J:	move.b	(a1)+,d0
	move.w	(a0)+,d1
	bset.b	d0,(a4,d1.w)
endfrag3J:


setscrJ:move.l	screennJ+4,d0
	add.l	#40,d0
	lea	c11J,a1
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

runJ:	moveq	#0,d0
	bsr	NorMCop

	lea	ScreenJ,a0
	move.w	#$3ff<<6!63,d0
	jsr	clearscreen_abs
	lea	ScreenJ+$1f000,a0
	move.w	#$3ff<<6!63,d0
	jsr	clearscreen_abs

	jsr	tp_end

	lea	module2,a0
	lea	EndModul,a1
	move.l	#EndModule2-Module2,d0
MoveModul:
	move.b	(a0)+,(a1)+
	dbra	d0,MoveModul

	lea	EndModul,a0
	move.l	a0,tp_data
	jsr	tp_init

	lea	screenJ,a0
	lea	screennJ,a1
	move.l	a0,(a1)+
	add.l	#$1f40*2,a0
	move.l	a0,(a1)+
	add.l	#$1f40*2,a0
	move.l	a0,(a1)+

	bsr.w	setscrJ

	lea	tablica1J,a0
	lea	tabl1J,a1
	move.l	#endtabl1J-tablica1J,d0
	bsr.w	Decrunch

	lea	PicPJ,a0
	lea	PicJ,a1
	move.l	#PicJE-PicPJ,d0
	bsr.w	Decrunch

	lea	PutPointsJ,a0
	lea	tabl1J,a6
	lea	picJ+40*30,a5
	lea	$2800(a5),a4
	lea	tabl2J,a3
	move.l	#ileptsJ-1,d7	
	moveq	#0,d5

putprgJ:
	move.b	(a3)+,d0
	move.w	(a6)+,d1
	btst.b	d0,(a5,d1.w)
	beq.b	ptxJ

	btst.b	d0,(a4,d1.w)
	beq.b	no2bpl2J

	bsr.w	emptpJ
	moveq	#[endfrag2J-frag2J]/2-1,d6
	lea	Frag2J,a1
putone1J:move.w	(a1)+,(a0)+
	dbra	d6,putone1J
	bra.b	quitpJ


no2bpl2J:
	bsr.w	emptpJ
	moveq	#[endfrag1J-frag1J]/2-1,d6
	lea	Frag1J,a1
putoneJ:	move.w	(a1)+,(a0)+
	dbra	d6,putoneJ
	bra.b	quitpJ

ptxJ:
	btst.b	d0,(a4,d1.w)
	beq.b	no2bplJ
	bsr.w	emptpJ
	moveq	#[endfrag3J-frag3J]/2-1,d6
	lea	Frag3J,a1
putone3J:move.w	(a1)+,(a0)+
	dbra	d6,putone3J
	bra.b	quitpJ


no2bplJ:
	addq.l	#1,d5
quitpJ:
	dbra	d7,putprgJ
	move.w	#$4e75,(a0)+

	clr.l	Counter
	waitframe
	lea	copperJ,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

myszJ:
	cmp.w	#$888,ColPJ+6
	beq.b	Eqc1J
	add.w	#$111,ColPJ+6
Eqc1J:
	cmp.w	#$555,ColPJ+10
	beq.b	Eqc2J
	add.w	#$111,ColPJ+10
Eqc2J:
	cmp.w	#$333,ColPJ+14
	beq.b	Eqc3J
	add.w	#$111,ColPJ+14
Eqc3J:
	bsr.w	setscrJ
	movem.l	screennJ,d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,screennJ

	waitblit
	move.l	#$01000000,$dff040
	clr.l	$dff044
	move.l	screennJ,$dff054
	move.w	#0,$dff066
	move.w	#[400<<6]!20,$dff058

	addq.l	#4,adderJ
	cmp.l	#endsinJ-sinJ,adderJ
	bne.b	noway1J
	clr.l	adderJ
noway1J:

	move.l	screennJ+4,a5

	move.l	a5,a4
	add.l	#$1f40,a4

	lea	tabl1J,a0
	lea	tabl2J,a1
	lea	sinJ,a2
	move.l	adderJ,d0
	move.l	(a2,d0.l),d1
	asr.l	#1,d1
	sub.l	d1,a0
	asr.l	#1,d1
	sub.l	d1,a1

	moveq	#0,d0
	moveq	#0,d1

	lea	PutPointsJ,a6
	jsr	(a6)

	cmp.l	#600,Counter
	bge.b	QuiJ

	waitframeZ

	bra.w	myszJ
QuiJ:	rts

emptpJ:	tst.l	d5
	beq.b	okiyJ
	move.w	#$d3fc,(a0)+	
	move.l	d5,(a0)+
	asl.l	#1,d5
	move.w	#$d1fc,(a0)+
	move.l	d5,(a0)+
	moveq	#0,d5
okiyJ:	rts

**************************************

runED:	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr
	moveq	#0,d0
	bsr.w	NormCop

	lea	FontED,a0
	move.w	#$3ff<<6!63,d0
	jsr	clearscreen_abs

	lea	FontFast,a0
	lea	FontED,a1
	move.l	#[SignsFastEnd-FontFast]/4-1,d7
mvfnED:	move.l	(a0)+,(a1)+
	dbra	d7,mvfnED

	lea	NdPPED,a0
	lea	LogoED,a1
	move.l	#NdPPEndED-NdPPED,d0
	bsr.w	decrunch

	lea	screenED,a0
	lea	screennED,a1
	move.l	a0,(a1)
	move.l	a0,d0
	lea	c11ED,a1
	moveq	#2,d7
ccopED:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$2800,d0
	dbra	d7,ccopED

	lea	logoED,a0
	move.l	a0,d0
	lea	c10ED,a1

	moveq	#4,d7
ccop2ED:swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1450,d0
	dbra	d7,ccop2ED

	waitframe
	lea	copperED,a0
	move.l	a0,$dff080
	move.w	d0,$dff088


FNED1:	waitframe
	lea	ColED+2,a0
	moveq	#0,d6
	moveq	#31,d7
FDED1:	move.w	(a0),d1
	move.w	#$fff,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FDED1
	tst.b	d6
	bne.b	FNED1

FNED:	waitframe
	lea	ColED+2,a0
	lea	PalED,a1
	moveq	#0,d6
	moveq	#31,d7
FDED:	move.w	(a0),d1
	move.w	(a1)+,d0
	bsr.w	fade
	move.w	d1,(a0)
	addq.l	#4,a0
	dbra	d7,FDED
	tst.b	d6
	bne.b	FNED

	lea	$dff000,a6
	lea	TextED,a4

myszED:	moveq	#17,d6
StepED:	move.l	screennED,a0
	move.l	a0,a1
	lea	40(a1),a1
	moveq	#2,d7
MvUpED:	waitblit
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#0,$64(a6)
	move.l	a1,$50(a6)
	move.l	a0,$54(a6)
	move.w	#[200<<6]!20,$58(a6)
	lea	$2800(a0),a0
	lea	$2800(a1),a1
	dbra	d7,MvUpED

waitED:	btst	#6,$bfe001
	beq.b	waitED

	waitframe
	dbra	d6,StepED

	move.l	screennED,a1
	lea	40*175(a1),a1

	moveq	#19,d7

NextLED:moveq	#0,d0
	move.b	(a4)+,d0
	cmp.b	#$d,d0
	beq.b	QuitED
	tst.b	d0
	bne.b	NoSpcED
	lea	TextED,a4
	bra.b	NextLED	

NoSpcED:move.l	a1,a3
	lea	FontED,a2
	sub.b	#' ',d0
	add.w	d0,d0
	add.l	d0,a2

	waitblit
	move.l	#$09f00000,$40(a6)
	move.l	#-1,$44(a6)
	move.l	#$00760026,$64(a6)

	moveq	#2,d6
PutLetED:waitblit
	move.l	a2,$50(a6)
	move.l	a3,$54(a6)
	move.w	#[16<<6]!1,$58(a6)
	lea	$2800(a3),a3
	lea	$780(a2),a2
	dbra	d6,PutLetED

ToNextED:addq.l	#2,a1
	dbra	d7,NextLED

QuitED:	btst	#10,$dff016
	bne.w	myszED

	lea	Return_Abs,a0
	move.l	a0,Vblk_Ptr

	rts
screennED:	dc.l	0


	incdir	my:
	include	PPackerDecrunch.s

	section data,data_p


textED:
dc.b '      LMB-PAUSE     ',$D,$D
dc.b '--------------------',$D,$D
dc.b '  WE WILL SMASH U!  ',$D,$D
dc.b '    NO AGA DEMO     ',$D,$D
dc.b '         BY         ',$D
dc.b '   POLISH DIVISION  ',$D
dc.b '         OF         ',$D
dc.b '        TRSI        ',$D,$d
dc.b '    RELEASED AT:    ',$D,$D
dc.b '    THE PARTY IV    ',$D,$D
dc.b '    X-MASS 1994!    ',$D,$D
dc.b '--------------------',$D
dc.b '    THE CREDITS:    ',$D
dc.b '--------------------',$D,$d
dc.b 'ALL CODING......PEPE',$d,$d
dc.b 'GFX.............TEES',$D,$d
dc.b 'ALL MUSIC........XTD',$D,$d
dc.b 'DESIGN.....TEES&PEPE',$D,$D
DC.b 'FARFUNDA PIC.....SEQ',$D,$D
DC.b '--------------------',$d,$d
dc.b '    TRSI GREETS     '
DC.b '   THE FOLLOWING:   ',$D,$D
DC.b '      ABSOLUTE!     ',$D
DC.B '      ALCATRAZ      ',$D
DC.B '      APPLAUSE      ',$D
dc.b '     AVANTGARDE     ',$D
DC.b '        BLAZE       ',$D
DC.b '       COMPLEX      ',$D
DC.b '       DESIRE       ',$D
DC.b '       EFFECT       ',$D
DC.b '       ESSENCE      ',$D
DC.B '      FREEZERS      ',$D
DC.b '      ILLUSION      ',$D
dc.b '       INFECT       ',$D
DC.b '       JOKER        ',$D
DC.B '      KEFRENS       ',$D
DC.b '    MELON DEZIGN    ',$D
DC.b '      MOVEMENT      ',$D
DC.b '       MYSTIC       ',$D
DC.b '   POLKA BROTHERS   ',$D
DC.b '     RAZOR 1911     ',$D
DC.b '       REBELS       ',$D
DC.b '       SANITY       ',$D
DC.b '      SCOOPEX       ',$D
DC.b '     SPACEBALLS     ',$D
DC.b '      STELLAR       ',$D
DC.b '      THE EDGE      ',$D
DC.b '       TALENT       ',$D
DC.b '        TPD         ',$D
dc.b '       UNION        ',$D
DC.b '     VD OF FLT      ',$D
DC.B '   AND THE REST!    ',$D,$D,$D,$D
DC.B 'HAPPY NEW YEAR 1995!',$D,$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b '  CONTACT TRSI AT:  ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
DC.B '   NORBY OF TRSI    ',$D,$D
DC.B '     PO BOX 20      ',$D
DC.B '   56-300 MILICZ    ',$D,$D
dc.b '       POLAND       ',$D,$D,$D
dc.b '    SUPPORT IT!     ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
DC.B '    QBA OF TRSI     ',$D,$D
DC.B '    PO BOX  105     ',$D
DC.B '  12-100 SZCZYTNO   ',$D,$D
dc.b '       POLAND       ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b '   MR.KING OF TRSI  ',$D,$D
dc.b '    POSTFACH 3143   ',$D
dc.b '   46434 EMMERICK   ',$D,$D
dc.b '       GERMANY      ',$D,$D,$D
dc.b ' SUPPORT NEVER MIND!',$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b '   CONTROL OF TRSI  ',$D,$D
dc.b '    PLK 019-944 D   ',$D
dc.b ' 49001 OSNABRUECK 12',$D,$D
dc.b '       GERMANY      ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b '   UYANIK! OF TRSI  ',$D,$D
dc.b '      PO BOX 47     ',$D
dc.b '  A-8607 KEPFENBERG ',$D,$D
dc.b '       AUSTRIA      ',$D,$D,$D
dc.b '  FOR JOINING TRSI! ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b '    SHADE OF TRSI   ',$D,$D
dc.b '    HURDALSVEIEN    ',$D
dc.b ' 2074 EIDSVOLL VERK ',$D,$D
dc.b '       NORWAY       ',$D,$D,$D
dc.b '   SUPPORT SUICID!  ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b '  OVERDOSE OF TRSI  ',$D,$D
dc.b '    3 APREECE WAY   ',$D
dc.b '       STILTON      ',$D
dc.b '    PETERBOROUGH    ',$d
dc.b '        CAMBS       ',$d
dc.b '       PE7 3XG      ',$d,$d
dc.b '       ENGLAND      ',$D,$D,$D
dc.b '   SUPPORT LETHAL   ',$d
dc.b '     INJECTION!     ',$D,$D,$D
DC.b '--------------------',$D,$D,$D
dc.b 'HERE ARE SOME WORDS '
DC.B '     FROM PEPE:     ',$D,$d
DC.B ' I SEND MY PERSONAL '
DC.B '    GREETINGS TO    ',$d
DC.B '      MTC/ILS       ',$d
DC.B ' WITHOUT YOUR 1200  '
DC.B ' THIS COULD NOT BE  '
DC.B '       DONE !       ',$D,$D,$D
DC.B ' IF YOU ARE LOOKING ',$d
DC.B '  FOR NEW CONTACTS  ',$d
DC.B '   AND FRIENDSHIP   ',$d
DC.B '     (NO SWAP!)     ',$d
DC.B '  USE YOUR CED TO:  ',$D,$D,$D
DC.B '     PEPE/TRSI      ',$d,$d
DC.B '   UL.ROZANA 4/20   ',$d
DC.B '   11-400 KETRZYN   ',$d
DC.B '       POLAND       ',$D,$d
DC.B '(LONG LETTERS RULE!)'
DC.B '--------------------'
DC.B $D,$D,$D,$d,$d
dc.b '  HAVE A NICE DAY!  ',$D,$D,$D,$d,$d
DC.B '  TEXT RESTARTS...  ',$D,$D,$D,$D,$D,$D,$D,$D,$d,$d
dc.b 0,0

dc.b 0,0,0

vx0=9

points0:
dc.w	-25*vx0,-25*vx0,25*vx0
dc.w	25*vx0,-25*vx0,25*vx0
dc.w	-25*vx0,25*vx0,25*vx0
dc.w	25*vx0,25*vx0,25*vx0
dc.w	-25*vx0,-25*vx0,-25*vx0
dc.w	25*vx0,-25*vx0,-25*vx0
dc.w	-25*vx0,25*vx0,-25*vx0
dc.w	25*vx0,25*vx0,-25*vx0

pointsend0:

pstr0:
dc.w	0,1,3,2
dc.w	-3,0
dc.w	6,7,5,4
dc.w	-3,1
dc.w	4,5,1,0
dc.w	-3,1
dc.w	2,3,7,6
dc.w	-3,0
dc.w	1,5,7,3
dc.w	-3,0
dc.w	0,2,6,4,0


dc.w	-1,-1,-1,-1,-1,-1
pstrend0:

destp0:	blk.b	64
destx0:	blk.b	64
face00:	blk.b	64
face10:	blk.b	64
face20:	blk.b	64
face30:	blk.b	64
face40:	blk.b	64
face50:	blk.b	64
dest00:	blk.b	64

screennJ:	dc.l	0,0,0,0
adderJ:		dc.l	0

bufor0:		dc.w	0
stary0:		dc.l	0
alfa0:		dc.w	0,0,0
alfa20:		dc.w	0,0,0
dodaj0:		dc.w	0,0,0
dodaj20:	dc.w	3,2,1

Xpos0:		dc.w	0
posx0:		dc.l	0
scract0:	dc.l	0
single0:	dc.l	0,0,0,0
dodp0:		dc.l	0,0
alfowe0:	blk.w	16
alfowe20:	blk.w	16
pointsp0:	dc.l	0
pstrp0:		dc.l	0
pointsl0:	dc.l	0
hide0:		dc.l	0
hideptr0:	dc.w	0
hideptr20:	dc.w	0
scriptpos0:	dc.l	0
timer0:		dc.w	0
alarm0:		dc.w	1
PPos0:		dc.l	0

bufor:		dc.w	0
stary:		dc.l	0
adder:		dc.l	0
;screenn:	dc.l	0
shrinker:	dc.l	0

buforG:		dc.w	0
staryG:		dc.l	0
zezwolG:	dc.w	0
alfaG:		dc.w	115,0,0,0
dodajG:		dc.w	0,0,0
obrotG:		dc.w	0,0,0,0,0,0,0,0
pipcikG:	dc.w	0
scractG:	dc.l	0
singleG:	dc.l	0,0,0
y1G:		dc.w	0
y2G:		dc.w	0
x1G:		dc.w	0
x2G:		dc.w	0

alfaM:		dc.w	0,0,0,0
dodajM:		dc.w	4,3,2
posxM:		dc.l	0
scractM:	dc.l	0
singleM:	dc.l	0,0,0,0
dodpM:		dc.l	0,0
y1M:		dc.w	0
y2M:		dc.w	0
x1M:		dc.w	0
x2M:		dc.w	0
pointspM:	dc.l	0
pstrpM:		dc.l	0
pointslM:	dc.l	0
hideM:		dc.l	0
objectM:	dc.l	-1
bplpM:		dc.l	0,$27d8,$27d8*2,$27d8*3
COunterM:	dc.l	0


PosN:		dc.l	0
ChgN:		dc.w	0
adder2:		dc.l	0
adder1:		dc.l	-[sin1-sinst]
screennL:	dc.l	0,0,0,0
adderL:		dc.l	0
timerL:		dc.l	0
alarmL:		dc.l	1
scriptposL:	dc.l	0
addikL:		dc.l	0
ctl1:		dc.l	0,0
Oki:		dc.w	0
Size:		dc.w	2
Tim:		dc.l	0
Tim2:		dc.l	0
PalAdr:		dc.l	0
PicAdr:		dc.l	0

pl1BB:		dc.l	8
scractBB:	dc.l	0
singleBB:	dc.l	0
x1BB:		dc.w	0
x2BB:		dc.w	0
y1BB:		dc.w	0
y2BB:		dc.w	0
makepBB:	dc.l	0,0
kulsadrBB:	dc.l	0
czasBB:		dc.l	0
czas2BB:	dc.l	0
ktoryBB:	dc.l	0
ypBB:		dc.l	$2,0
		dc.w	$2,0
		dc.l	0,2
kierBB:		dc.l	0
rtBB:		dc.l	0
dup:		dc.l	256*2
fuje:		dc.l	0

vxRC1=9
pointsRC1:
dc.w	-40*vxRC1,-30*vxRC1,0*vxRC1
dc.w	40*vxRC1,-30*vxRC1,0*vxRC1
dc.w	40*vxRC1,30*vxRC1,0*vxRC1
dc.w	-40*vxRC1,30*vxRC1,0*vxRC1
pointsendRC1:

pstrRC1:
dc.w	0,1,2,3,0
dc.w	-1,-1,-1,-1,-1,-1
pstrendRC1:

destpRC1:	blk.b	100,0
alfaRC1:	dc.w	0,0,0,0
dodajRC1:	dc.w	0,0,2
posxRC1:	dc.l	0
scractRC1:	dc.l	0
singleRC1:	dc.l	0,0,0,0
dodpRC1:	dc.l	0,0
y1RC1:		dc.w	0
y2RC1:		dc.w	0
x1RC1:		dc.w	0
x2RC1:		dc.w	0
pointspRC1:	dc.l	0
pstrpRC1:	dc.l	0
pointslRC1:	dc.l	0
hideRC1:	dc.l	0
objectRC1:	dc.l	-1
bplpRC1:	dc.l	0,$4b00,$4b00*2,$4b00*3
adecRC1:	dc.w	0
screenn1:	dc.l	0
SizeY1:		dc.l	0
EndRC1:		dc.w	0

destpRC2:	blk.b	100,0
alfaRC2:	dc.w	0,0,0,0
dodajRC2:	dc.w	0,0,2
scractRC2:	dc.l	0
singleRC2:	dc.l	0,0,0,0
dodpRC2:	dc.l	0,0
y1RC2:		dc.w	0
y2RC2:		dc.w	0
x1RC2:		dc.w	0
x2RC2:		dc.w	0
hideRC2:	dc.l	0
bplpRC2:	dc.l	0,$4b00,$4b00*2,$4b00*3
adecRC2:	dc.w	0
EndRC2:		dc.w	0

screenpF:	dc.l	0,0,0
replpF:		dc.l	0
screennF:	dc.l	0
possF:		dc.w	0,0,0,0
sinusposF:	dc.l	0
bufrF:		dc.l	0,0
posXF:		dc.w	$f000
posYF:		dc.w	$00f4
RoutinePF:	dc.l	0
EndFuckF:	dc.w	0
CntrF:		dc.l	0
posVF:		dc.l	0,2
pos2VF:		dc.l	0,160*2
bchVF:		dc.w	0
TimVF:		dc.l	0
EndVF:		dc.w	0


scrtM:
	dc.l	0,0,[pointsendM-pointsM]/6-1,0
	dc.l	points3M-pointsM,pstr3M-pstrM,[pointsend3M-points3M]/6-1,0
	dc.l	0,0,[pointsendM-pointsM]/6-1,0
	dc.l	0,0,[pointsendM-pointsM]/6-1,0
vxM=9
pointsM:
dc.w	-25*vxM,-25*vxM,25*vxM
dc.w	25*vxM,-25*vxM,25*vxM
dc.w	25*vxM,25*vxM,25*vxM
dc.w	-25*vxM,25*vxM,25*vxM
dc.w	0*vxM,0*vxM,-35*vxM
pointsendM:
pstrM:
dc.w	0,1,2,3
dc.w	-4,1
dc.w	0,1,2,3
dc.w	-3,1
dc.w	4,1,0
dc.w	-3,1
dc.w	4,3,2
dc.w	-3,0
dc.w	4,0,3
dc.w	-3,0
dc.w	4,2,1,4
dc.w	-1,-1,-1,-1,-1,-1
pstrendM:
zxM=8
points2M:
dc.w	-25*zxM,-25*zxM,25*zxM
dc.w	25*zxM,-25*zxM,25*zxM
dc.w	25*zxM,25*zxM,25*zxM
dc.w	-25*zxM,25*zxM,25*zxM

dc.w	-25*zxM,-25*zxM,-25*zxM
dc.w	25*zxM,-25*zxM,-25*zxM
dc.w	25*zxM,25*zxM,-25*zxM
dc.w	-25*zxM,25*zxM,-25*zxM
pointsend2M:
pstr2M:
dc.w	0,1,2,3
dc.w	-3,0
dc.w	5,4,7,6
dc.w	-3,1
dc.w	1,5,6,2
dc.w	-3,1
dc.w	3,7,4,0
dc.w	-3,0
dc.w	0,4,5,1
dc.w	-4,1
dc.w	0,4,5,1
dc.w	-3,0
dc.w	2,6,7,3
dc.w	-4,1
dc.w	2,6,7,3,2
dc.w	-1,-1,-1,-1,-1,-1
pstrend2M:
axM=11
points3M:
dc.w	-25*axM,-25*axM,0*axM
dc.w	25*axM,-25*axM,0*axM
dc.w	25*axM,25*axM,0*axM
dc.w	-25*axM,25*axM,0*axM
dc.w	0,0,-30*axM
dc.w	0,0,30*axM
pointsend3M:
pstr3M:
dc.w	0,3,4
dc.w	-3,0
dc.w	4,2,1
dc.w	-3,1
dc.w	4,1,0
dc.w	-3,1
dc.w	3,2,4
dc.w	-3,1
dc.w	5,3,0
dc.w	-3,1
dc.w	1,2,5
dc.w	-3,0
dc.w	0,1,5
dc.w	-3,0
dc.w	5,2,3,5
dc.w	-1,-1,-1,-1,-1,-1
pstrend3M:


scriptL:	dc.l	200,400
		dc.l	300,399
		dc.l	50,400
		dc.l	300,401
		dc.l	50,400
		dc.l	5,600
		dc.l	5,800
		dc.l	5,1000
		dc.l	5,1200
		dc.l	5,1400
		dc.l	5,1600
		dc.l	5,1800
		dc.l	300,2000
		dc.l	-1,-1

pale:		dc.w	$007b,$0049,$0026

SinSt:
Sin1:	DC.W	$2058,$21C0,$22CE,$2436,$259E,$2706,$2814,$297C,$2A8A,$2BF2
	DC.W	$2D00,$2E68,$2F76,$3084,$3192,$32A0,$33AE,$34BC,$35CA,$36D8
	DC.W	$378C,$389A,$394E,$3A02,$3AB6,$3B6A,$3C1E,$3C78,$3D2C,$3D86
	DC.W	$3DE0,$3E3A,$3E94,$3EEE,$3EEE,$3F48,$3F48,$3F48,$3F48,$3F48
	DC.W	$3EEE,$3EEE,$3E94,$3E3A,$3DE0,$3D86,$3D2C,$3C78,$3C1E,$3B6A
	DC.W	$3AB6,$3A02,$394E,$389A,$378C,$36D8,$35CA,$34BC,$33AE,$32A0
	DC.W	$3192,$3084,$2F76,$2E68,$2D00,$2BF2,$2A8A,$297C,$2814,$2706
	DC.W	$259E,$2436,$22CE,$21C0,$2058,$1EF0,$1D88,$1C7A,$1B12,$19AA
	DC.W	$1842,$1734,$15CC,$14BE,$1356,$1248,$10E0,$0FD2,$0EC4,$0DB6
	DC.W	$0CA8,$0B9A,$0A8C,$097E,$0870,$07BC,$06AE,$05FA,$0546,$0492
	DC.W	$03DE,$032A,$02D0,$021C,$01C2,$0168,$010E,$00B4,$005A,$005A
	DC.W	$0000,$0000,$0000,$0000,$0000,$005A,$005A,$00B4,$010E,$0168
	DC.W	$01C2,$021C,$02D0,$032A,$03DE,$0492,$0546,$05FA,$06AE,$07BC
	DC.W	$0870,$097E,$0A8C,$0B9A,$0CA8,$0DB6,$0EC4,$0FD2,$10E0,$1248
	DC.W	$1356,$14BE,$15CC,$1734,$1842,$19AA,$1B12,$1C7A,$1D88,$1EF0


EndSin1:

Sin2:	DC.W	$002E,$0031,$0034,$0037,$003A,$003C,$003F,$0041,$0044,$0046
	DC.W	$0049,$004B,$004D,$004F,$0051,$0052,$0054,$0055,$0056,$0057
	DC.W	$0058,$0059,$0059,$005A,$005A,$005A,$005A,$0059,$0059,$0058
	DC.W	$0057,$0056,$0055,$0054,$0052,$0051,$004F,$004D,$004B,$0049
	DC.W	$0046,$0044,$0041,$003F,$003C,$003A,$0037,$0034,$0031,$002E
	DC.W	$002C,$0029,$0026,$0023,$0020,$001E,$001B,$0019,$0016,$0014
	DC.W	$0011,$000F,$000D,$000B,$0009,$0008,$0006,$0005,$0004,$0003
	DC.W	$0002,$0001,$0001,$0000,$0000,$0000,$0000,$0001,$0001,$0002
	DC.W	$0003,$0004,$0005,$0006,$0008,$0009,$000B,$000D,$000F,$0011
	DC.W	$0014,$0016,$0019,$001B,$001E,$0020,$0023,$0026,$0029,$002C


EndSin2:


sinustabVF:
	DC.W	$0140,$0168,$0190,$01B8,$01B8,$01E0,$0208,$0208,$0230,$0230
	DC.W	$0258,$0258,$0280,$0280,$0280,$0280,$0280,$0280,$0280,$0280
	DC.W	$0258,$0258,$0230,$0230,$0208,$0208,$01E0,$01B8,$01B8,$0190
	DC.W	$0168,$0140,$0140,$0118,$00F0,$00C8,$00C8,$00A0,$0078,$0078
	DC.W	$0050,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0028,$0028,$0050,$0050,$0078,$0078,$00A0,$00C8
	DC.W	$00C8,$00F0,$0118,$0140

endsintVF:
	DC.W	$0140,$0168,$0190,$01B8,$01B8,$01E0,$0208,$0208,$0230,$0230
	DC.W	$0258,$0258,$0280,$0280,$0280,$0280,$0280,$0280,$0280,$0280
	DC.W	$0258,$0258,$0230,$0230,$0208,$0208,$01E0,$01B8,$01B8,$0190
	DC.W	$0168,$0140,$0140,$0118,$00F0,$00C8,$00C8,$00A0,$0078,$0078
	DC.W	$0050,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0028,$0028,$0050,$0050,$0078,$0078,$00A0,$00C8
	DC.W	$00C8,$00F0,$0118,$0140
	DC.W	$0140,$0168,$0190,$01B8,$01B8,$01E0,$0208,$0208,$0230,$0230
	DC.W	$0258,$0258,$0280,$0280,$0280,$0280,$0280,$0280,$0280,$0280
	DC.W	$0258,$0258,$0230,$0230,$0208,$0208,$01E0,$01B8,$01B8,$0190
	DC.W	$0168,$0140,$0140,$0118,$00F0,$00C8,$00C8,$00A0,$0078,$0078
	DC.W	$0050,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0028,$0028,$0050,$0050,$0078,$0078,$00A0,$00C8
	DC.W	$00C8,$00F0,$0118,$0140
	DC.W	$0140,$0168,$0190,$01B8,$01B8,$01E0,$0208,$0208,$0230,$0230
	DC.W	$0258,$0258,$0280,$0280,$0280,$0280,$0280,$0280,$0280,$0280
	DC.W	$0258,$0258,$0230,$0230,$0208,$0208,$01E0,$01B8,$01B8,$0190
	DC.W	$0168,$0140,$0140,$0118,$00F0,$00C8,$00C8,$00A0,$0078,$0078
	DC.W	$0050,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0028,$0028,$0050,$0050,$0078,$0078,$00A0,$00C8
	DC.W	$00C8,$00F0,$0118,$0140
	DC.W	$0140,$0168,$0190,$01B8,$01B8,$01E0,$0208,$0208,$0230,$0230
	DC.W	$0258,$0258,$0280,$0280,$0280,$0280,$0280,$0280,$0280,$0280
	DC.W	$0258,$0258,$0230,$0230,$0208,$0208,$01E0,$01B8,$01B8,$0190
	DC.W	$0168,$0140,$0140,$0118,$00F0,$00C8,$00C8,$00A0,$0078,$0078
	DC.W	$0050,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0028,$0028,$0050,$0050,$0078,$0078,$00A0,$00C8
	DC.W	$00C8,$00F0,$0118,$0140
endsinustabVF:

sinustabF:
	blk.w	250,$208
	dc.w	$0208,$0230
	DC.W	$0280,$02A8,$02F8,$0320,$0348,$0398,$03C0,$03E8,$0410,$0438
	DC.W	$0460,$0488,$0488,$04B0,$04B0,$04B0,$04B0,$04B0,$04B0,$0488
	DC.W	$0488,$0460,$0438,$0410,$03E8,$03C0,$0398,$0348,$0320,$02F8
	DC.W	$02A8,$0280,$0230,$0208,$01B8,$0190,$0168,$0118,$00F0,$00C8
	DC.W	$00A0,$0078,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0028,$0028,$0050,$0078,$00A0,$00C8,$00F0,$0118,$0168
	DC.W	$0190,$01B8

endsintF:
	dc.w	$0208,$0230
	DC.W	$0280,$02A8,$02F8,$0320,$0348,$0398,$03C0,$03E8,$0410,$0438
	DC.W	$0460,$0488,$0488,$04B0,$04B0,$04B0,$04B0,$04B0,$04B0,$0488
	DC.W	$0488,$0460,$0438,$0410,$03E8,$03C0,$0398,$0348,$0320,$02F8
	DC.W	$02A8,$0280,$0230,$0208,$01B8,$0190,$0168,$0118,$00F0,$00C8
	DC.W	$00A0,$0078,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0028,$0028,$0050,$0078,$00A0,$00C8,$00F0,$0118,$0168
	DC.W	$0190,$01B8
	dc.w	$0208,$0230
	DC.W	$0280,$02A8,$02F8,$0320,$0348,$0398,$03C0,$03E8,$0410,$0438
	DC.W	$0460,$0488,$0488,$04B0,$04B0,$04B0,$04B0,$04B0,$04B0,$0488
	DC.W	$0488,$0460,$0438,$0410,$03E8,$03C0,$0398,$0348,$0320,$02F8
	DC.W	$02A8,$0280,$0230,$0208,$01B8,$0190,$0168,$0118,$00F0,$00C8
	DC.W	$00A0,$0078,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0028,$0028,$0050,$0078,$00A0,$00C8,$00F0,$0118,$0168
	DC.W	$0190,$01B8
	dc.w	$0208,$0230
	DC.W	$0280,$02A8,$02F8,$0320,$0348,$0398,$03C0,$03E8,$0410,$0438
	DC.W	$0460,$0488,$0488,$04B0,$04B0,$04B0,$04B0,$04B0,$04B0,$0488
	DC.W	$0488,$0460,$0438,$0410,$03E8,$03C0,$0398,$0348,$0320,$02F8
	DC.W	$02A8,$0280,$0230,$0208,$01B8,$0190,$0168,$0118,$00F0,$00C8
	DC.W	$00A0,$0078,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0028,$0028,$0050,$0078,$00A0,$00C8,$00F0,$0118,$0168
	DC.W	$0190,$01B8
	dc.w	$0208,$0230
	DC.W	$0280,$02A8,$02F8,$0320,$0348,$0398,$03C0,$03E8,$0410,$0438
	DC.W	$0460,$0488,$0488,$04B0,$04B0,$04B0,$04B0,$04B0,$04B0,$0488
	DC.W	$0488,$0460,$0438,$0410,$03E8,$03C0,$0398,$0348,$0320,$02F8
	DC.W	$02A8,$0280,$0230,$0208,$01B8,$0190,$0168,$0118,$00F0,$00C8
	DC.W	$00A0,$0078,$0050,$0028,$0028,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0028,$0028,$0050,$0078,$00A0,$00C8,$00F0,$0118,$0168
	DC.W	$0190,$01B8
endsinustabF:


vxRC2=20
xxRC2=vxrc2/4
pointsRC2:
AB1:	ds.b	12
AB2:	ds.b	12
AB3:	ds.b	12
AB4:	ds.b	12
AB5:	ds.b	12
AB6:	ds.b	12
AB7:	ds.b	12
AB8:	ds.b	12
pointsendRC2:

PoRC:
dc.w	-10*vxRC2,-10*vxRC2,0*vxRC2
dc.w	10*vxRC2,-10*vxRC2,0*vxRC2
dc.w	-10*vxRC2,-5*vxRC2,0*vxRC2
dc.w	10*vxRC2,-5*vxRC2,0*vxRC2
dc.w	-10*vxRC2,-5*vxRC2,0*vxRC2
dc.w	10*vxRC2,-5*vxRC2,0*vxRC2
dc.w	-10*vxRC2,0*vxRC2,0*vxRC2
dc.w	10*vxRC2,0*vxRC2,0*vxRC2
dc.w	-10*vxRC2,0*vxRC2,0*vxRC2
dc.w	10*vxRC2,0*vxRC2,0*vxRC2
dc.w	10*vxRC2,5*vxRC2,0*vxRC2
dc.w	-10*vxRC2,5*vxRC2,0*vxRC2
dc.w	10*vxRC2,5*vxRC2,0*vxRC2
dc.w	-10*vxRC2,5*vxRC2,0*vxRC2
dc.w	10*vxRC2,10*vxRC2,0*vxRC2
dc.w	-10*vxRC2,10*vxRC2,0*vxRC2

pstrRC2:
dc.w	0,1,3,5,7,9,10,12,14
dc.w	15,13,11,8,6,4,2
dc.w	0
dc.w	-1,-1,-1,-1,-1,-1
pstrendRC2:

pstsRC2:
dc.w	0,1,3,2
dc.w	-4,0
dc.w	4,5,7,6
dc.w	-4,0
dc.w	8,9,10,11
dc.w	-4,0
dc.w	12,13,15,14,12
dc.w	-1,-1,-1,-1,-1,-1
pstsendRC2:


plaskG:		dc.w	$1000
plasktabpG:	dc.w	0
czypionG:	dc.w	0
zzG:		dc.l	0
Sinuses1P:	dc.l	0
Sinuses2P:	dc.l	0
dodpG:		dc.l	0,0
EndSeq:		dc.w	0
scriptposG:	dc.w	0
czasG:		dc.w	0
AlarmG:		dc.w	1
posFL:		dc.w	270,0,270,0,0,0,0,0
sprFL:		dc.w	0
manysprFL:	dc.l	0,0,0,0,0,0,0,0
cmper:		dc.l	0

scriptG:
dc.w	0,2
blk.l	200,1
dc.w	1,5
dc.w	2,5
dc.w	3,5
dc.w	4,5
dc.w	5,5
dc.w	6,100
dc.w	5,5
dc.w	4,5
dc.w	3,5
dc.w	2,5
dc.w	1,5
dc.w	0,5
dc.w	-1,5
dc.w	-2,5
dc.w	-3,5
dc.w	-4,5
dc.w	-5,5
dc.w	-6,80

dc.w	-5,5
dc.w	-4,5
dc.w	-3,5
dc.w	-2,5
dc.w	-1,5
dc.w	0,5
dc.w	1,5
dc.w	2,5
dc.w	3,5
dc.w	4,5
dc.w	5,5
dc.w	6,5
dc.w	7,5
dc.w	8,5
dc.w	9,5
dc.w	10,5
dc.w	11,5
dc.w	12,5
dc.w	13,5
dc.w	14,5
dc.w	15,5
dc.w	16,5
dc.w	17,5
dc.w	18,5
dc.w	19,5
dc.w	20,5
endscriptG:
dc.w	20,200

script0:dc.w	0,0,0,0,0,0,0
	dc.w	45,0,0,6,3,2,1
	dc.w	45,6,0,0,3,0,0
;	dc.w	180,0,3,0,0,3,0
	dc.w	720,3,2,1,1,3,2

	dc.w	0,0,0,0,0,0,0

dane:
	blk.w	112,0*32
	blk.w	16

	blk.w	112/2,0*32
	blk.w	112/2,1*32
	blk.w	16,1*32

	blk.w	112/3,0*32
	blk.w	112/3,1*32
	blk.w	112/3+1,2*32
	blk.w	16,2*32

	blk.w	112/4,0*32
	blk.w	112/4,1*32
	blk.w	112/4,2*32
	blk.w	112/4,3*32
	blk.w	16,3*32

	blk.w	112/5,0*32
	blk.w	112/5,1*32
	blk.w	112/5,2*32
	blk.w	112/5,3*32
	blk.w	112/5+2,4*32
	blk.w	16,4*32

	blk.w	112/6,0*32
	blk.w	112/6,1*32
	blk.w	112/6,2*32
	blk.w	112/6,3*32
	blk.w	112/6,4*32
	blk.w	112/6+4,5*32
	blk.w	16,5*32

	blk.w	112/7,0*32
	blk.w	112/7,1*32
	blk.w	112/7,2*32
	blk.w	112/7,3*32
	blk.w	112/7,4*32
	blk.w	112/7,5*32
	blk.w	112/7,6*32
	blk.w	16,6*32

	blk.w	112/8,0*32
	blk.w	112/8,1*32
	blk.w	112/8,2*32
	blk.w	112/8,3*32
	blk.w	112/8,4*32
	blk.w	112/8,5*32
	blk.w	112/8,6*32
	blk.w	112/8,7*32
	blk.w	16*2,7*32

dane2:	blk.w	112,0*32
	blk.w	16

	blk.w	112/2,1*32
	blk.w	112/2,0*32
	blk.w	16,0*32

	blk.w	112/3+1,2*32
	blk.w	112/3,1*32
	blk.w	112/3,0*32
	blk.w	16,0*32

	blk.w	112/4,3*32
	blk.w	112/4,2*32
	blk.w	112/4,1*32
	blk.w	112/4,0*32
	blk.w	16,0*32

	blk.w	112/5+2,4*32
	blk.w	112/5,3*32
	blk.w	112/5,2*32
	blk.w	112/5,1*32
	blk.w	112/5,0*32
	blk.w	16,0*32

	blk.w	112/6+4,5*32
	blk.w	112/6,4*32
	blk.w	112/6,3*32
	blk.w	112/6,2*32
	blk.w	112/6,1*32
	blk.w	112/6,0*32
	blk.w	16,0*32

	blk.w	112/7,6*32
	blk.w	112/7,5*32
	blk.w	112/7,4*32
	blk.w	112/7,3*32
	blk.w	112/7,2*32
	blk.w	112/7,1*32
	blk.w	112/7,0*32
	blk.w	16,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

	blk.w	112/8,7*32
	blk.w	112/8,6*32
	blk.w	112/8,5*32
	blk.w	112/8,4*32
	blk.w	112/8,3*32
	blk.w	112/8,2*32
	blk.w	112/8,1*32
	blk.w	112/8,0*32
	blk.w	16*2,0*32

Bcgra:	dc.w 0
Pal0:	dc.w $0755,$0211,$0422
	dc.w $0433,$0533,$0544,$0100

Pal1:	dc.w $0778,$0112,$0223
	dc.w $0334,$0445,$0556,$0101

Pax:	dc.w $088,$0ff,$0bb,$066

setcolG:dc.w $0747,$0525,$0646
	dc.w $0535,$0868,$0868,$0080
	dc.w $0535,$0757,$0757,$0868
	dc.w $0646,$070f,$0c0e,$0c08

plasktabG:
	blk.w	50,$0
	dc.w	$0800,$1400,$2000,$2800,$3400,$4000,$4800,$5400,$5C00,$6400
	dc.w	$6C00,$7000,$7400,$7800,$7C00,$7C00,$7C00,$7C00,$7800,$7400
	dc.w	$7000,$6C00,$6400,$5C00,$5400,$4800,$4000,$3400,$2800,$2000
	dc.w	$1400,$0800,$F800,$EC00,$E000,$D800,$CC00,$C000,$B800,$AC00
	dc.w	$A400,$9C00,$9400,$9000,$8C00,$8800,$8400,$8400,$8400,$8400
	dc.w	$8800,$8C00,$9000,$9400,$9C00,$A400,$AC00,$B800,$C000,$CC00
	dc.w	$D800,$E000,$EC00,$F800
	dc.w	$0400,$1000,$1C00,$2800,$3000,$3C00,$4400,$4C00,$5000,$5400
	dc.w	$5800,$5C00,$5C00,$5C00,$5800,$5400,$5000,$4C00,$4400,$3C00
	dc.w	$3000,$2800,$1C00,$1000,$0400,$FC00,$F000,$E400,$D800,$D000
	dc.w	$C400,$BC00,$B400,$B000,$AC00,$A800,$A400,$A400,$A400,$A800
	dc.w	$AC00,$B000,$B400,$BC00,$C400,$D000,$D800,$E400,$F000,$FC00
	dc.w	$0400,$0C00,$1400,$1C00,$2400,$2800,$3000,$3400,$3800,$3800
	dc.w	$3C00,$3C00,$3C00,$3800,$3800,$3400,$3000,$2800,$2400,$1C00
	dc.w	$1400,$0C00,$0400,$FC00,$F400,$EC00,$E400,$DC00,$D800,$D000
	dc.w	$CC00,$C800,$C800,$C400,$C400,$C400,$C800,$C800,$CC00,$D000
	dc.w	$D800,$DC00,$E400,$EC00,$F400,$FC00
	dc.w	$0400,$0C00,$1400,$1800,$1C00,$1C00,$1800,$1400,$0C00,$0400
	dc.w	$FC00,$F400,$EC00,$E800,$E400,$E400,$E800,$EC00,$F400,$FC00
endingG:

balltabyG:
	blk.w	17,$a
	DC.W	$000A,$000A,$000A,$000B,$000C,$000D,$000E,$0010,$0011,$0013
	DC.W	$0015,$0018,$001A,$001D,$0020,$0023,$0027,$002A,$002E,$0032
	DC.W	$0036,$003A,$003F,$0043,$0048,$004D,$0052,$0057,$005C,$0061
	DC.W	$0067,$006C,$0072,$0077,$007D,$0083,$0089,$008E,$0094,$009A
	DC.W	$009E,$0098,$0092,$008C,$0086,$0080,$007B,$0075,$006F,$006A
	DC.W	$0064,$005F,$005A,$0055,$0050,$004B,$0046,$0041,$003D,$0039
	DC.W	$0034,$0030,$002D,$0029,$0025,$0022,$001F,$001C,$001A,$0017
	DC.W	$0015,$0013,$0011,$000F,$000E,$000D,$000C,$000B,$000B,$000B
	blk.w	133,$a

plasktabyG:
	blk.w	50,-20*zxG
	dc.w	$FF65,$FF6E,$FF77,$FF80,$FF89,$FF91,$FF99,$FFA0,$FFA7,$FFAD
	dc.w	$FFB2,$FFB7,$FFBA,$FFBD,$FFBF,$FFC0,$FFC0,$FFBF,$FFBD,$FFBA
	dc.w	$FFB7,$FFB2,$FFAD,$FFA7,$FFA0,$FF99,$FF91,$FF89,$FF80,$FF77
	dc.w	$FF6E,$FF65,$FF5B,$FF52,$FF49,$FF40,$FF37,$FF2F,$FF27,$FF20
	dc.w	$FF19,$FF13,$FF0E,$FF09,$FF09,$FF09,$FF09,$FF09,$FF09,$FF09
	dc.w	$FF09,$FF09,$FF09,$FF0E,$FF13,$FF19,$FF20,$FF27,$FF2F,$FF37
	dc.w	$FF40,$FF49,$FF52,$FF5B
	dc.w	$FF64,$FF6C,$FF74,$FF7B,$FF82,$FF89,$FF8F,$FF94,$FF98,$FF9C
	dc.w	$FF9E,$FF9F,$FFA0,$FF9F,$FF9E,$FF9C,$FF98,$FF94,$FF8F,$FF89
	dc.w	$FF82,$FF7B,$FF74,$FF6C,$FF64,$FF5C,$FF54,$FF4C,$FF45,$FF3E
	dc.w	$FF37,$FF31,$FF2C,$FF28,$FF24,$FF22,$FF21,$FF20,$FF21,$FF22
	dc.w	$FF24,$FF28,$FF2C,$FF31,$FF37,$FF3E,$FF45,$FF4C,$FF54,$FF5C
	dc.w	$FF64,$FF6D,$FF75,$FF7D,$FF85,$FF8C,$FF92,$FF97,$FF9B,$FF9E
	dc.w	$FF9F,$FFA0,$FF9F,$FF9E,$FF9B,$FF97,$FF92,$FF8C,$FF85,$FF7D
	dc.w	$FF75,$FF6D,$FF64,$FF5C,$FF53,$FF4B,$FF43,$FF3B,$FF34,$FF2E
	dc.w	$FF29,$FF25,$FF22,$FF21,$FF20,$FF21,$FF22,$FF25,$FF29,$FF2E
	dc.w	$FF34,$FF3B,$FF43,$FF4B,$FF53,$FF5C
	dc.w	$FF65,$FF6F,$FF77,$FF7D,$FF80,$FF80,$FF7D,$FF77,$FF6F,$FF65
	dc.w	$FF5B,$FF51,$FF49,$FF43,$FF40,$FF40,$FF43,$FF49,$FF51,$FF5B

data:	dc.w	$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.w	$99,$99,$99,$99,$99,$88,$88,$88,$88,$88,$88,$88,$77,$77,$77,$77
	dc.w	$aa,$aa,$aa,$99,$99,$99,$88,$88,$88,$88,$88,$77,$77,$66,$66,$66
	dc.w	$bb,$bb,$bb,$aa,$aa,$99,$99,$88,$88,$77,$77,$66,$66,$55,$55,$66
	dc.w	$cc,$cc,$cc,$bb,$bb,$aa,$99,$88,$88,$77,$77,$55,$55,$44,$44,$66
	dc.w	$dd,$dd,$dd,$cc,$bb,$bb,$aa,$88,$88,$77,$66,$55,$44,$33,$33,$66
	dc.w	$ee,$ee,$ee,$ee,$cc,$cc,$bb,$88,$88,$55,$55,$44,$44,$22,$22,$66
	dc.w	$ff,$ff,$ff,$ff,$cc,$cc,$bb,$88,$88,$55,$55,$44,$11,$11,$11,$66
	dc.w	$ff,$ff,$ff,$ff,$cc,$cc,$bb,$88,$88,$55,$55,$44,$11,$11,$11,$66
endd:

SinX0:	dc.w	$00F0,$00EF,$00EE,$00EC,$00E9,$00E6,$00E2,$00DD,$00D7,$00D2
	dc.w	$00CB,$00C4,$00BC,$00B4,$00AC,$00A3,$009A,$0090,$0086,$007C
	dc.w	$0071,$0066,$005C,$0051,$0046
	dc.w	$0043,$0049,$004F,$0055,$005B,$0061,$0066,$006C,$0071,$0076
	dc.w	$007B,$007F,$0084,$0088,$008C,$008F,$0093,$0096,$0098,$009A
	dc.w	$009C,$009E,$009F,$00A0,$00A0,$00A0,$00A0,$009F,$009E,$009C
	dc.w	$009A,$0098,$0096,$0093,$008F,$008C,$0088,$0084,$007F,$007B
	dc.w	$0076,$0071,$006C,$0066,$0061,$005B,$0055,$004F,$0049,$0043
	dc.w	$0041,$0043,$0045,$0047,$0049,$004B,$004D,$004F,$0050,$0052
	dc.w	$0054,$0055,$0057,$0058,$0059,$005A,$005C,$005D,$005D,$005E
	dc.w	$005F,$005F,$0060,$0060,$0060,$0060,$0060,$0060,$005F,$005F
	dc.w	$005E,$005D,$005D,$005C,$005A,$0059,$0058,$0057,$0055,$0054
	dc.w	$0052,$0050,$004F,$004D,$004B,$0049,$0047,$0045,$0043,$0041
EndSX0:

SinSp:
	DC.B	$00,$01,$02,$05,$08,$0C,$10,$16,$1C,$22,$2A,$31,$3A,$43,$4D,$57
	DC.B	$61,$6C,$77,$83,$8F,$9B,$A7,$B3,$C0

	DC.B	$C2,$BA,$B2,$AA,$A2,$9B,$93,$8C,$85,$7E,$78,$71,$6B,$66,$61,$5C
	DC.B	$58,$54,$51,$4E,$4B,$49,$48,$47,$46,$46,$47,$48,$49,$4B,$4E,$51
	DC.B	$54,$58,$5C,$61,$66,$6B,$71,$78,$7E,$85,$8C,$93,$9B,$A2,$AA,$B2
	DC.B	$BA,$C2

	DC.B	$C4,$C0,$BC,$B8,$B4,$B0,$AD,$A9,$A5,$A2,$9F,$9C,$99,$96,$93,$91
	DC.B	$8F,$8D,$8B,$8A,$89,$88,$87,$86,$86,$86,$86,$87,$88,$89,$8A,$8B
	DC.B	$8D,$8F,$91,$93,$96,$99,$9C,$9F,$A2,$A5,$A9,$AD,$B0,$B4,$B8,$BC
	DC.B	$C0,$C4,$c6
EndSP:	dc.b	$c6,$c6

txtposQ:	dc.w	0
cmpikQ:		dc.w	0
YposQ:		dc.w	-50*64
XposQ:		dc.w	-150
screenpQ:	dc.l	0,0,0
counterQ:	dc.l	0
backgroundQ:	dc.l	0
LetterAdrQ:	dc.l	0
EndingQ:	dc.w	0
SignalsQ:	dc.w	0
CopAdrQ:	dc.l	0,0
posQ:		dc.w	174,174
scr2adrQ:	dc.l	0

lettabQ:
x1=32*40
x2=32*2*40

	blk.w	45,x2+36
	dc.w	x2+28,x2+24
	blk.w	17,x2+36
	dc.w	x2+32
	blk.w	32,x2+36
	dc.w	0,4,8,12,16,20,24,28,32,36
	dc.w	x1+0,x1+4,x1+8,x1+12,x1+16,x1+20,x1+24,x1+28,x1+32,x1+36
	dc.w	x2+0,x2+4,x2+8,x2+12,x2+16,x2+20,x2+24,x2+28,x2+32,x2+36
	blk.w	100,x2+36

screenp_b:	dc.l	0,0,0,0
screenn_b:	dc.l	0
paip_b:		dc.l	0,0,0,0,0
paip_2_b:	dc.l	0,0,0,0,0
dodx_b:		dc.b	0
dody_b:		dc.b	0,0,0
time_b:		dc.w	0
timeq_b:	dc.w	0
endpat_b:	dc.w	0
mul40p_b:	dc.l	0
mul16p_b:	dc.l	0
ptsp_b:		dc.l	0

dodtb_b:	dc.b	132,132,250,1
dodtbe_b:

PalEd:	dc.w $0000,$0fff,$0eee,$0ddd
	dc.w $0ccc,$0bbb,$0aaa,$0999
	dc.w $0888,$0777,$0666,$0555
	dc.w $0444,$0333,$0222,$0111
	dc.w $0200,$0300,$0400,$0500
	dc.w $0610,$0720,$0740,$0850
	dc.w $0010,$0020,$0030,$0040
	dc.w $0151,$0262,$0373,$0484

	section	dupa,code_c
copperED:
	dc.l	$009683e0,$00960020
LEFED:	dc.l	$008e2c50,$00902Cd1
	dc.l	$01080000,$010a0000
	dc.l	$00920038,$009400d0


ColED:	dc.w $0180,0,$0182,0,$0184,0,$0186,0
	dc.w $0188,0,$018a,0,$018c,0,$018e,0
	dc.w $0190,0,$0192,0,$0194,0,$0196,0
	dc.w $0198,0,$019a,0,$019c,0,$019e,0
	dc.w $01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w $01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w $01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w $01b8,0,$01ba,0,$01bc,0,$01be,0

c10ED:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

	dc.l	$01005000

	dc.l	$a907fffe,$01000000

	dc.w $0182,$0000,$0184,$0000,$0186,$0000
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000

c11ED:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000

	dc.l	$aa07fffe
	dc.l	$01003000

	dc.l $ab07fffe
	dc.w $0182,$0001,$0184,$0000,$0186,$0000
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $ac07fffe
	dc.w $0182,$0112,$0184,$0000,$0186,$0000
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $ad07fffe
	dc.w $0182,$0223,$0184,$0001,$0186,$0000
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $ae07fffe
	dc.w $0182,$0334,$0184,$0112,$0186,$0000
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $af07fffe
	dc.w $0182,$0445,$0184,$0223,$0186,$0001
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $b007fffe
	dc.w $0182,$0556,$0184,$0334,$0186,$0112
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $b107fffe
	dc.w $0182,$0667,$0184,$0445,$0186,$0223
	dc.w $0188,$0001,$018a,$0000,$018c,$0000,$018e,$0000
	dc.l $b207fffe
	dc.w $0182,$0778,$0184,$0556,$0186,$0334
	dc.w $0188,$0112,$018a,$0001,$018c,$0000,$018e,$0000
	dc.l $b307fffe
	dc.w $0182,$0889,$0184,$0667,$0186,$0445
	dc.w $0188,$0223,$018a,$0112,$018c,$0001,$018e,$0000
	dc.l $b407fffe
	dc.w $0182,$099a,$0184,$0778,$0186,$0556
	dc.w $0188,$0334,$018a,$0223,$018c,$0112,$018e,$0001
	dc.l $b507fffe
	dc.w $0182,$0aab,$0184,$0889,$0186,$0667
	dc.w $0188,$0445,$018a,$0334,$018c,$0223,$018e,$0112

	dc.l	$ffddfffe,$2007fffe

	dc.w $0188,$0445,$018a,$0334,$018c,$0223,$018e,$0112
	dc.w $0182,$0aab,$0184,$0889,$0186,$0667
	dc.l $2107fffe
	dc.w $0188,$0334,$018a,$0223,$018c,$0112,$018e,$0001
	dc.w $0182,$099a,$0184,$0778,$0186,$0556
	dc.l $2207fffe
	dc.w $0188,$0223,$018a,$0112,$018c,$0001,$018e,$0000
	dc.w $0182,$0889,$0184,$0667,$0186,$0445
	dc.l $2307fffe
	dc.w $0188,$0112,$018a,$0001,$018c,$0000,$018e,$0000
	dc.w $0182,$0778,$0184,$0556,$0186,$0334
	dc.l $2407fffe
	dc.w $0188,$0001,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0667,$0184,$0445,$0186,$0223
	dc.l $2507fffe
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0556,$0184,$0334,$0186,$0112
	dc.l $2607fffe
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0445,$0184,$0223,$0186,$0001
	dc.l $2707fffe
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0334,$0184,$0112,$0186,$0000
	dc.l $2807fffe
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0223,$0184,$0001,$0186,$0000
	dc.l $2907fffe
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0112,$0184,$0000,$0186,$0000
	dc.l $2a07fffe
	dc.w $0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
	dc.w $0182,$0001,$0184,$0000,$0186,$0000

	dc.l	$fffffffe

copperJ:	dc.l	$009683c0,$00960020
		dc.l	$008e2c50,$00902cc1
		dc.l	$01080000,$010a0000
		dc.l	$01060000,$00f80000,$00fa0000,$01fc0000
		dc.l	$00920038,$009400d0

colpJ:		dc.w $0180,0,$0182,0,$0184,0,$0186,0

		dc.l	$4807fffe
c11J:		dc.l	$00e00000
		dc.l	$00e20000
		dc.l	$00e40000
		dc.l	$00e60000
		dc.l	$00e80000
		dc.l	$00ea0000
		dc.l	$00ec0000
		dc.l	$00ee0000
		dc.w	$0100,%0010000000000000
		dc.l	$f007fffe,$01000000
		dc.l	$fffffffe

frag1F:	add.w	(a1)+,a0
	bset.b	#0,$00(a0)
endfrag1F:

frag2F:	movem.l	bufrF,a0-a1
	addq.l	#2,a1
	lea	40*3(a0),a0
	movem.l	a0-a1,bufrF
	addq.l	#2,d7
	move.w	(a3,d7.l),d6
	add.l	d6,a0
endfrag2F:

okeyF:	addq.l	#1,CntrF
	cmp.l	#50*7,CntrF
	blt.b	FaseOneF

	tst.w	Col1F
	beq.b	Faded2F
	subq.w	#1,Col1F
	bra.b	BabaF
Faded2F:
	cmp.b	#$f0,posXF
	beq.b	NoSuw2F
	addq.b	#1,PosXF
	bra.b	BabaF
NoSuw2F:move.b	#-1,EndFuckF
	bra.w	QuitF
FaseOneF:
	cmp.w	#$f,Col1F
	beq.b	FadedF
	addq.w	#1,Col1F
FadedF:
	cmp.b	#$30,Up1F
	beq.b	UppedF
	subq.b	#1,Up1F
UppedF:

	cmp.b	#$d6,posXF
	beq.b	NoSuwF
	subq.b	#1,PosXF
NoSuwF:

BabaF:
	lea	screenpF,a0
	movem.l	(a0),d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,(a0)

	waitblit
	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#0,$dff066
	move.l	screenpF,$dff054
	move.w	#%100000000010100,$dff058
	move.l	screenpF+4,a0

	add.l	#40*54,a0

	lea	sinusF,a1
	lea	sinustabF,a3

	addq.l	#4,sinusposF
	cmp.l	#endsintF-sinustabF,sinusposF
	bne.b	noway1F
	move.l	#500,sinusposF
noway1F:
	move.l	sinusposF,d7
	add.l	d7,a1

	lea	EndsintF-386,a5
	add.l	d7,a5
	moveq	#0,d0
	move.w	(a5),d0
	divu.w	#40,d0
	add.w	#240,d0
	move.w	d0,PosYF
	bsr.b	SetPosF

	movem.l	a0-a1,bufrF
	moveq	#0,d6
	move.w	(a3,d7.l),d6
	add.l	d6,a0
	add.w	(a1)+,a0
	move.l	RoutinePF,a5
	jsr	(a5)

	bsr.b	setscF
QuitF:	rts

setscF:	move.l	screenpF+4,d0
	add.l	#40*54,d0
	lea	c11F,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	rts

SetposF:move.w	PosYF,d0
	move.b	d0,Spr1F
	move.b	d0,Spr2F
	move.b	d0,Spr3F
	move.b	d0,Spr4F
	cmp.w	#$ff,d0
	sgt.b	d2
	and.b	#4,d2

	add.w	#30,d0
	cmp.w	#$ff,d0
	sgt.b	d1
	and.b	#$2,d1
	or.b	d2,d1
	or.b	#$80,d1

	move.b	d1,Spr1F+3
	move.b	d1,Spr2F+3
	move.b	d1,Spr3F+3
	move.b	d1,Spr4F+3

	move.b	d0,Spr1F+2
	move.b	d0,Spr2F+2
	move.b	d0,Spr3F+2
	move.b	d0,Spr4F+2

	move.b	PosXF,d0
	move.b	d0,Spr1F+1
	move.b	d0,Spr2F+1
	addq.b	#8,d0
	move.b	d0,Spr3F+1
	move.b	d0,Spr4F+1

	rts

PreFala:lea	Return_abs,a0
	move.l	a0,vblk_ptr
	clr.l	Counter
	lea	RoutpF,a0
	move.l	a0,d0
	tst.w	d0
	beq.b	EquF
	clr.w	d0
	add.l	#$00010000,d0
EquF:	move.l	d0,screennF

	lea	endF,a0
	lea	RoutinePF,a1
	move.l	a0,(a1)

	moveq	#0,d0
	lea	obrVF,a0
	lea	imgVF,a1
	move.l	a0,a2
	move.l	#pipVF-imgVF,d7
kiolVF:	move.b	(a1)+,d0
	move.w	#0,d1
	cmp.b	#'a',d0
	blt.b	chck2VF
	cmp.b	#'z',d0
	bgt.b	chck2VF

	moveq	#40,d1
	sub.w	#96-7,d0
	mulu.w	d0,d1
	neg.w	d1
	add.w	#$2800,d1
	bra.b	nooVF
chck2VF:
	cmp.b	#'A',d0
	blt.b	nooVF
	cmp.b	#'Z',d0
	bgt.b	nooVF

	moveq	#40,d1
	sub.w	#64,d0
	add.w	d0,d0
	mulu.w	d0,d1
	neg.w	d1

nooVF:	move.w	d1,(a2)+
	dbra	d7,kiolVF

	lea	SprAdrF,a0
	lea	Spr1F,a1
	move.l	a1,d0
	moveq	#3,d7
SSPF:	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	addq.l	#8,a0
	add.l	#Spr2F-Spr1F,d0
	dbra	d7,SSPF

	lea	SprAdrF+32,a0
	lea	EmptySpr,a1
	move.l	a1,d0
	moveq	#3,d7
SSP2F:	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	addq.l	#8,a0
	dbra	d7,SSP2F

	jsr	SetposF

	lea	LodzioF,a0
	move.l	a0,d0

	lea	c10F,a1
	moveq	#4,d7
TuuF:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	add.l	#$300,d0
	addq.l	#8,a1
	dbra	d7,TuuF

	move.l	screennF,a0
	lea	screenpF,a1
	move.l	a0,(a1)
	add.l	#$2800,a0
	move.l	a0,4(a1)
	add.l	#$2800,a0
	move.l	a0,8(a1)

	lea	sinusF,a0
	lea	sinustabF,a1
	move.l	#endsinustabF-sinustabF-2,d7
	move.w	(a1)+,d1
reptwF:	move.w	(a1)+,d0
	move.w	d0,d2
	sub.w	d1,d0
	move.w	d2,d1
	move.w	d0,(a0)+
	dbra	d7,reptwF
dimxF=77
dimyF=51
	move.l	RoutinePF,a2
	move.l	#15*8,d5
	moveq	#DimYF-1,d0
MVI1F:	moveq	#DimXF-1,d6
	move.l	#320,d4
	sub.l	d5,d4
	asr.l	#1,d4

	move.l	d5,d3
	asl.l	#7,d3
	divu.w	#DimXF,d3
	moveq	#0,d2

mvi3F:	lea	frag1F,a0
	moveq	#endfrag1F-frag1F-1,d7
mvi2F:	move.b	(a0)+,(a2)+
	dbra	d7,mvi2F

	lea	-[endfrag1F-frag1F](a2),a3
	
	move.l	d2,d1
	asr.l	#7,d1
	add.w	d4,d1	
	move.b	d1,5(a3)
	eor.b	#7,5(a3)
	and.b	#7,5(a3)
	asr.w	#3,d1
	move.w	d1,6(a3)
	add.w	d3,d2
	dbra	d6,mvi3F

	add.l	#4,d5

	lea	frag2F,a1
	moveq	#endfrag2F-frag2F-1,d7
mvi5F:	move.b	(a1)+,(a2)+
	dbra	d7,mvi5F

	dbra	d0,mvi1F
	move.w	#$4e75,(a2)
VBPO:	cmp.l	#50,Counter
	blt.b	VBPO
	rts

Fala:	lea	OkeyF,a0
	move.l	a0,vblk_ptr
	waitframe
	lea	copperF,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

myszVF:	tst.b	EndFuckF
	bne.w	QuitNF
	bra.s	myszVF
QuitNF:	bra.w	RunVF
	rts


frag1VF:move.w	(a2)+,d0
	add.w	(a1)+,a0
	bset.b	#0,$00(a0,d0.w)
endfrag1VF:

frag2VF:movem.l	bufrF,a0-a1
	addq.l	#2,a1
	lea	40*4(a0),a0
	movem.l	a0-a1,bufrF
	addq.l	#2,d7
	move.w	(a3,d7.l),d6
	add.l	d6,a0
	lea	160(a2),a2
endfrag2VF:


okeyVF:	addq.l	#1,TimVF
	cmp.l	#50*7,TimVF
	blt.b	NoTimF

	moveq	#14,d7
	lea	Mx1F,a0
LowerF:	tst.w	2(a0)
	beq.b	Mz1F
	subq.w	#1,2(a0)
Mz1F:	addq.l	#8,a0
	dbra	d7,LowerF

	cmp.b	#$ff,BiBF+2
	bne.b	NoAllF
	move.b	#-1,EndVF
	bra.b	NoTimF
NoAllF:	addq.b	#4,BibF+2
	tst.b	BiB2F+2
	beq.b	NoTimF
	subq.b	#4,BiB2F+2

NoTimF:	lea	screenpF,a0
	movem.l	(a0),d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,(a0)

	not.b	bchVF

	waitblit
	move.l	#$01000000,$dff040
	move.l	#0,$dff044
	move.w	#0,$dff066
	move.l	screenpF,$dff054
	move.w	#%1000000000010100,$dff058
	move.l	screenpF+4,a0

	add.l	#40*70,a0

	lea	sinusF,a1
	lea	sinustabVF,a3

	addq.l	#4,sinusposF
	cmp.l	#endsintVF-sinustabVF,sinusposF
	bne.b	noway1VF
	clr.l	sinusposF
noway1VF:

	move.l	sinusposF,d7
	add.l	d7,a1

	move.l	posVF+4,d0
	add.l	d0,posVF
	move.l	pos2VF+4,d0
	add.l	d0,pos2VF

	tst.l	posVF
	bgt.b	pli1VF
	neg.l	posVF+4
pli1VF:	cmp.l	#160,posVF
	ble.b	pli2VF
	neg.l	posVF+4
pli2VF:
	cmp.l	#128*2,pos2VF
	bgt.b	pli3VF
	neg.l	pos2VF+4
pli3VF:	cmp.l	#128*2*49,pos2VF
	blt.b	pli4VF
	neg.l	pos2VF+4
pli4VF:
	lea	obrVF,a2
	add.l	posVF,a2
	add.l	pos2VF,a2
	movem.l	a0-a1,bufrF

	moveq	#0,d6
	move.w	(a3,d7.l),d6
	add.l	d6,a0

	add.w	(a1)+,a0

	move.l	RoutinePF,a5
	jsr	(a5)

	bsr.b	setscVF

	tst.b	klaoa
	beq.b	FadaF
	cmp.w	#$fff,Col2F
	beq.w	FadaF
	add.w	#$100,Col1F
	add.w	#$111,Col2F
	add.w	#$111,Col3F
FadaF:	move.b	#-1,klaoa
	rts
klaoa:	dc.w	0

setscVF:move.l	screenpF+4,d0
	add.l	#40*52,d0
	lea	c11F,a1
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	add.l	#$2800,d0
	swap	d0
	move.w	d0,10(a1)
	swap	d0
	move.w	d0,14(a1)
	rts

runVF:	waitframe
	lea	Return_Abs,a0
	move.l	a0,vblk_ptr

	clr.l	SinuSPosF
	lea	RoutpF,a0
	move.l	a0,d0
	tst.w	d0
	beq.b	Equ2F
	clr.w	d0
	add.l	#$00010000,d0
Equ2F:	move.l	d0,RoutinePF

	lea	endF,a0
	lea	screennF,a1
	move.l	a0,(a1)

	move.l	screennF,a0
	lea	screenpF,a1
	move.l	a0,(a1)
	add.l	#2*$2800,a0
	move.l	a0,4(a1)
	add.l	#2*$2800,a0
	move.l	a0,8(a1)


	lea	sinusF,a0
	lea	sinustabVF,a1
	move.l	#endsinustabVF-sinustabVF-2,d7
	move.w	(a1)+,d1
reptwVF:move.w	(a1)+,d0
	move.w	d0,d2
	sub.w	d1,d0
	move.w	d2,d1
	move.w	d0,(a0)+
	dbra	d7,reptwVF
dimxVF=80
dimyVF=34
	move.l	routinePF,a2
	move.l	#17*8,d5
	moveq	#DimYVF-1,d0

MVI1VF:	moveq	#DimXVF-1,d6

	move.l	#320,d4
	sub.l	d5,d4
	asr.l	#1,d4

	move.l	d5,d3
	asl.l	#7,d3
	divu.w	#DimXVF,d3
	moveq	#0,d2

mvi3VF:	lea	frag1VF,a0
	moveq	#endfrag1VF-frag1VF-1,d7
mvi2VF:	move.b	(a0)+,(a2)+
	dbra	d7,mvi2VF

	lea	-[endfrag1VF-frag1VF](a2),a3
	
	move.l	d2,d1
	asr.l	#7,d1
	add.w	d4,d1	
	move.b	d1,7(a3)
	eor.b	#7,7(a3)
	and.b	#7,7(a3)
	asr.w	#3,d1
	move.w	d1,8(a3)
	add.w	d3,d2

	dbra	d6,mvi3VF

	add.l	#5,d5

	lea	frag2VF,a1
	moveq	#endfrag2VF-frag2VF-1,d7
mvi5VF:	move.b	(a1)+,(a2)+
	dbra	d7,mvi5VF

	dbra	d0,mvi1VF
	move.w	#$4e75,(a2)

	clr.l	counter
	waitframe
	lea	OkeyVF,a0
	move.l	a0,vblk_ptr
	move.w	#$2000,ScrCF
MyszF:	cmp.l	#400,Counter
	bge.b	QuitOkF
	bra.s	myszF

QuitOkF:lea	Return_Abs,a0
	move.l	a0,vblk_ptr
	rts


	section	coppers,data_c

PCopper:
	dc.l	$009683e0,$00968020
	dc.l	$01fc0000
	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000
	dc.l	$00920038,$009400d0

col0:	dc.w	$0180,0,$0182,0,$0184,0,$0186,0
	dc.w	$0188,0,$018a,0,$018c,0,$018e,0

	dc.l	$4007fffe
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
	dc.w	$0100,%0011000000000000

	dc.l	$5f07fffe

col1:	dc.w $0182,$fff,$0184,$fff,$0186,$fff
	dc.w $0188,$fff,$018a,$fff,$018c,$fff,$018e,$fff
make:

CopperLO:
	dc.l	$01800fff,$01820fff
	dc.l	$008e2c50,$00902cc1
SpD:	dc.l	$0107fffe
	dc.l	$01800fff,$01820fff
	dc.l	$01001000
	dc.l	$fffffffe

copper0:
	dc.l	$009683c0,$00968020,$01fc0000

	dc.l	$008e1080,$009038c1
	dc.l	$00920038,$009400d0

cox0:	dc.l	$01800fff
	dc.l	$01820fff,$01840fff
	dc.l	$01860fff

	dc.l	$2007fffe
	dc.l	$0108ffd8,$010affd8
c110:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$01002000
	dc.l	$6007fffe
	dc.l	$01080000,$010a0000

	dc.l	$f607fffe,$0108ffd8,$010affd8
	dc.l	$fffffffe

copperG:dc.l	$009683c0,$01020000
	dc.l	$008e30c8,$00907870
	dc.l	$00920038,$009400d0
priG:	dc.l	$01040022

	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
spradG:
	dc.w	$138,0,$13a,0,$13c,0,$13e,0

colorsG:dc.w	$0180,$0407,$0182,$0407,$0184,$0407,$0186,$0407
	dc.w	$0188,$0407,$018a,$0407,$018c,$0407,$018e,$0407
	dc.w	$0190,$0407,$0192,$0407,$0194,$0407,$0196,$0407
	dc.w	$0198,$0407,$019a,$0407,$019c,$0407,$019e,$0407
	dc.l	$01a00000,$01a20fff,$01a40eee,$01a60ddd,$01a80ccc,$01aa0bbb
	dc.l	$01ac0aaa,$01ae0999,$01b00888,$01b20777,$01b40666,$01b60555
	dc.l	$01b80444,$01ba0333,$01bc0222,$01be0111
	dc.l	$3007fffe
c11G:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.w	$0108,-40,$010A,-40
	dc.w	$0100,%0001000000000000
	dc.l	$8007fffe
	dc.l	$01080018,$010A0018
	dc.w	$0100,%0100000000000000
	dc.l	$c607fffe
	dc.l	$01800607
colors2G:
	dc.w	$0180,$0607,$0182,$0607,$0184,$0607,$0186,$0607
	dc.w	$0188,$0607,$018a,$0607,$018c,$0607,$018e,$0607
	dc.w	$0190,$0607,$0192,$0607,$0194,$0607,$0196,$0607
	dc.w	$0198,$0607,$019a,$0607,$019c,$0607,$019e,$0607
	dc.l	$ed07fffe,$01000000
	dc.w	$ffff,$fffe


copperM:dc.l	$009683e0,$00968020

	dc.w	$01a0,$0000,$01a2,$0aac,$01a4,$0113,$01a6,$0224
	dc.w	$01a8,$0225,$01aa,$0335,$01ac,$0336,$01ae,$0446
	dc.w	$01b0,$0557,$01b2,$0779,$01b4,$077a,$01b6,$0879
	dc.w	$01b8,$088b,$01ba,$099b,$01bc,$0003,$01be,$0bbd

AdrSpr1:dc.l	$01200000,$01220000,$01240000,$01260000
	dc.l	$01280000,$012a0000,$012c0000,$012e0000
	dc.l	$01300000,$01320000,$01340000,$01360000
	dc.l	$01380000,$013a0000,$013c0000,$013e0000

	dc.l	$008e2050,$010200ff
	dc.l	$00920038,$009400d0
colM:	dc.l	$01800fff
	dc.l	$01820fff,$01840fff
	dc.l	$01880fff,$018a0fff
	dc.l	$3007fffe,$009028c1
	dc.w	$0108,0,$010A,-40
c11M:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e80000
	dc.l	$00ea0000
c12M:	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$01003000
makeM:	blk.l	4*linesM+1
	dc.l	$00902a00
	dc.l	$01001000
	dc.l	$0108ffd8
	dc.l	$fffffffe

EmptySprite0:
	dc.l	0,0,0,0

SprCopper0:
	dc.w $01a0,$0000,$01a2,$0aac,$01a4,$0113,$01a6,$0224
	dc.w $01a8,$0225,$01aa,$0335,$01ac,$0336,$01ae,$0446
	dc.w $01b0,$0557,$01b2,$0779,$01b4,$077a,$01b6,$0879
	dc.w $01b8,$088b,$01ba,$099b,$01bc,$0003,$01be,$0bbd

AdrSpr0:dc.l	$01200000,$01220000,$01240000,$01260000
	dc.l	$01280000,$012a0000,$012c0000,$012e0000
	dc.l	$01300000,$01320000,$01340000,$01360000
	dc.l	$01380000,$013a0000,$013c0000,$013e0000
	dc.l	$008a0000


PalN:	dc.w $0000,$0eca,$0100,$0200
	dc.w $0300,$0400,$0500,$0600
	dc.w $0e30,$0d20,$0c10,$0b10
	dc.w $0a00,$0900,$0800,$0700
	dc.w $0f40,$0f50,$0f60,$0f70
	dc.w $0f80,$029f,$015a,$0139
	dc.w $0010,$0020,$0030,$0050
	dc.w $0181,$0127,$0115,$0103

copperN:	dc.l	$009683e0,$00968020

	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000
	dc.l	$00920038,$009400d0,$01020000
	dc.w	$0104
PRiorN:	dc.w	$1

SprAdrN:dc.l	$01280000,$012a0000,$01300000,$01320000
	dc.l	$01380000,$013a0000,$012c0000,$012e0000
	dc.l	$01240000,$01260000,$01340000,$01360000
	dc.l	$01200000,$01220000,$013c0000,$013e0000


ColorsN:dc.w $0180,0,$0182,0,$0184,0,$0186,0
	dc.w $0188,0,$018a,0,$018c,0,$018e,0
	dc.w $0190,0,$0192,0,$0194,0,$0196,0
	dc.w $0198,0,$019a,0,$019c,0,$019e,0
	dc.w $01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w $01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w $01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w $01b8,0,$01ba,0,$01bc,0,$01be,0

c11N:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

	dc.w	$0100,$5000
	dc.l	$fffffffe

SprN:	dc.l	$00001000
	dc.w $2004,$700e,$700e,$d81b,$f81f,$8811,$f81f,$d42b
	dc.w $7c3e,$ec37,$1e78,$37ec,$0bd0,$1e78,$03c0,$0e70
	dc.w $0a50,$1ff8,$13c8,$1a58,$0180,$33cc,$0240,$07e0
	dc.w $0420,$0660,$0420,$0000,$0420,$0420,$0000,$0420
SprBN:	dc.l	0


copperX:	dc.l	$009683c0,$00960020
		dc.l	$008e2c50,$00902cd0
		dc.l	$01080000,$010a0000,$01000000
		dc.l	$01060000,$00f80000,$00fa0000,$01fc0000
		dc.l	$00920038,$009400d0,$01020000

cols2:		dc.w $0180,$0203,$0182,$0fff,$0184,$0eef,$0186,$0ddf
		dc.w $0188,$0cce,$018a,$0bbd,$018c,$0aac,$018e,$088a
		dc.w $0190,$0779,$0192,$0667,$0194,$0555,$0196,$0454
		dc.w $0198,$0343,$019a,$0232,$019c,$0121,$019e,$0344

m1:		dc.l	$2e07fffe
c10:		dc.l	$00e00000
		dc.l	$00e20000
		dc.l	$00e40000
		dc.l	$00e60000
		dc.l	$00e80000
		dc.l	$00ea0000
		dc.l	$00ec0000
		dc.l	$00ee0000

m2:		dc.l	$3007fffe
		dc.l	$0100c000
m3:		dc.l	$3f07fffe
		dc.l	$01000000

		dc.l	$01800203,$01000000
		dc.w	$0102
Mvb:		dc.w	$10
cols:		dc.l	$01820203,$01840203,$01860203

m4:		dc.l	$5607fffe
c11b:		dc.l	$00e00000
		dc.l	$00e20000
		dc.l	$00e40000
		dc.l	$00e60000
		dc.l	$00e80000
		dc.l	$00ea0000
		dc.l	$00ec0000
		dc.l	$00ee0000
m5:		dc.l	$5807fffe
		dc.l	$01002000
m9:		dc.l	$f807fffe,$01000000
		dc.l	$00920040,$009400d8,$01020000
m8:		dc.l	$ffddfffe,$1207fffe

c13:		dc.l	$00e00000
		dc.l	$00e20000
		dc.l	$00e40000
		dc.l	$00e60000
		dc.l	$00e80000
		dc.l	$00ea0000
		dc.l	$00ec0000
		dc.l	$00ee0000

cols3:		dc.w $0180,$0203,$0182,$0ead,$0184,$0d9c,$0186,$0c9b
		dc.w $0188,$0b9a,$018a,$0a9b,$018c,$0889,$018e,$0779
		dc.w $0190,$066a,$0192,$0559,$0194,$0558,$0196,$0547
		dc.w $0198,$0436,$019a,$0325,$019c,$0214,$019e,$0103

m6:		dc.l	$1407fffe
		dc.l	$0100c000
m7:		dc.l	$2607fffe,$01000000
		dc.l	$fffffffe

copper1:
	dc.l	$009683e0,$00960020
	dc.l	$01020088,$01080000,$010a0000

	dc.l	$008e2250,$00904cc1
	dc.l	$00920050,$009400b0

	dc.w $0180,$0000,$0182,$0346,$0184,$0457,$0186,$0569
	dc.w $0188,$0211,$018a,$0a64,$018c,$0953,$018e,$0842
	dc.w $0190,$0002,$0192,$0200,$0194,$0300,$0196,$0400
	dc.w $0198,$0510,$019a,$0621,$019c,$0721,$019e,$0731
	dc.w $01a0,$0003,$01a2,$0004,$01a4,$0777,$01a6,$0025
	dc.w $01a8,$0036,$01aa,$0037,$01ac,$0049,$01ae,$004b
	dc.w $01b0,$0555,$01b2,$0666,$01b4,$0016,$01b6,$0005
	dc.w $01b8,$0035,$01ba,$0333,$01bc,$0222,$01be,$0444

c111:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

	dc.l	$01005000

make1:	ds.l	3*400

	dc.l	$fffffffe


copper21:
	dc.l	$009683e0,$00960020
	dc.l	$01020088,$01000000

	dc.l	$008e2250,$00904cc1,$01080000,$010a0000
	dc.l	$00920038,$009400d0

Col21:	dc.w $0180,$0000,$0182,$0fff,$0184,$0eee,$0186,$0ddd
	dc.w $0188,$0ccc,$018a,$0bbb,$018c,$0aaa,$018e,$0999
	dc.w $0190,$0888,$0192,$0777,$0194,$0666,$0196,$0555
	dc.w $0198,$0444,$019a,$0333,$019c,$0222,$019e,$0111

c101:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000

	dc.l	$7007fffe
	dc.l	$01004000

	dc.l	$ad07fffe,$01000000
	dc.l	$b007fffe
c91:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000

Col1b:	dc.w 	$0180,0,$0182,0,$0184,0,$0186,0
	dc.w 	$0188,0,$018a,0,$018c,0,$018e,0
	dc.l	$010200aa

	dc.l	$c007fffe,$01003000
	dc.l	$d007fffe,$01000000
	dc.l	$fffffffe

copperRC1:
	dc.l	$009683c0,$0960020,$01020000

	dc.l	$008e0020,$009050f0
	dc.l	$00920030,$009400d8
	dc.w	$0108,20,$010A,20

ColRC1:	dc.l	$01800000,$01820203
	dc.l	$1407fffe
c11RC1:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$01001000
	dc.l	$ffddfffe,$4007fffe,$01000000
	dc.w	$ffff,$fffe

copperRC2:
	dc.l	$009683c0,$0960020,$01020000
	dc.l	$008e0020,$009050f0
	dc.l	$00920030,$009400d8
	dc.w	$0108,64+20,$010A,64+20
colRC:	dc.l	$01800000,$018200ff
	dc.l	$1407fffe
c11RC2:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$01001000
	dc.l	$ffddfffe,$4007fffe,$01000000
	dc.w	$ffff,$fffe

Pal11:	dc.w 	$0000,$0aab,$0889,$0667
	dc.w 	$0445,$0334,$0223,$0112

copperF:dc.l	$01020000,$01fc0000
	dc.l	$009683e0
	dc.l	$01000000
BiBF:	dc.l	$008e2b28,$00903000
	dc.l	$00920038,$009400d0
	dc.w	$0108,-$18
	dc.w	$010a,-$18

SprAdrF:dc.l	$01200000,$01220000,$01240000,$01260000
	dc.l	$01280000,$012a0000,$012c0000,$012e0000
	dc.l	$01300000,$01320000,$01340000,$01360000
	dc.l	$01380000,$013a0000,$013c0000,$013e0000

	dc.w $0180,$0000,$0182,$0ddd,$0184,$0bbb,$0186,$0999
	dc.w $0188,$0777,$018a,$0666,$018c,$0555,$018e,$0444
	dc.w $0190,$0363,$0192,$0252,$0194,$0242,$0196,$0232
	dc.w $0198,$0121,$019a,$0111,$019c,$0222,$019e,$0333
	dc.w $01a0,$0001,$01a2,$0112,$01a4,$0113,$01a6,$0224
	dc.w $01a8,$0335,$01aa,$0446,$01ac,$0557,$01ae,$0668
	dc.w $01b0,$0100,$01b2,$0311,$01b4,$0422,$01b6,$0533
	dc.w $01b8,$0644,$01ba,$0755,$01bc,$0866,$01be,$0977

c10F:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000,$00f20000

Up1F:	dc.l	$6007fffe
	dc.l	$01005000
	dc.l	$5007fffe
mx1F:	dc.l	$01800001,$5107fffe
	dc.l	$01800002,$5207fffe
	dc.l	$01800003,$5307fffe
	dc.l	$01800004,$5407fffe
	dc.l	$01800005,$5507fffe
	dc.l	$01800006,$5607fffe
	dc.l	$01800007,$5707fffe
	dc.l	$01800008,$5807fffe
	dc.l	$01800007,$5907fffe
	dc.l	$01800006,$5a07fffe
	dc.l	$01800005,$5b07fffe
	dc.l	$01800004,$5c07fffe
	dc.l	$01800003,$5d07fffe
	dc.l	$01800002,$5e07fffe
	dc.l	$01800001,$5f07fffe,$01800000

	dc.l	$6007fffe
BiB2F:	dc.l	$00902cca,$01000000
	dc.l	$01080000,$010a0000

	dc.l	$01a00000,$01a20b74,$01a40952,$01a60731
	dc.l	$01a80620,$01aa0410,$01ac0c85,$01ae0ea7

c11F:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000,$00f20000

	dc.l	$01800000
	dc.w	$0182
Col1F:	dc.w	$0000
	dc.w	$0184
COl2F:	dc.w	$0000
	dc.w	$0186
Col3F:	dc.w	$0000
	dc.l	$6207fffe
	dc.w	$0100
scrcF:	dc.w	$1000

	dc.l	$ffddfffe
	dc.l	$2407fffe
	dc.l	$01000000
	dc.l	$fffffffe
 NormCopper:
	dc.l	$01000000
	dc.w	$0180
NCCO:	dc.w	0
	dc.l	-2

EmptySpr:dc.l	0,0,0,0

Spr1F:	dc.w $0000,$0080
	dc.w $02ff,$001e,$1d47,$0a78,$7d8f,$2ef0,$7800,$44ff
	dc.w $776a,$31ff,$3ff7,$1f77,$0f49,$0000,$00ab,$0000
	dc.w $603d,$3ff0,$d943,$7ff0,$c166,$7fd0,$c15a,$7ff0
	dc.w $7ff6,$3fe0,$02aa,$0000,$303c,$1ff8,$2c28,$3ff8
	dc.w $2092,$3fc8,$3083,$1fd8,$1ffd,$0fd8,$00aa,$0000
	dc.w $0c1d,$07fc,$1854,$0ffc,$1845,$0fec,$0fee,$07ec
	dc.w $0055,$0000,$021d,$01fc,$0274,$03f4,$03fd,$01f4
	dc.w $01f6,$0000
	dc.w 0,0

Spr2F:	dc.w $0000,$0080
	dc.w $02e1,$0000,$1180,$0000,$4d00,$0000,$0300,$0000
	dc.w $4e00,$0000,$2088,$0000,$0f7f,$0000,$00ab,$0000
	dc.w $400d,$0000,$9c0b,$0000,$900f,$0000,$800b,$0000
	dc.w $4017,$0000,$02ab,$0000,$2005,$0000,$0e05,$0000
	dc.w $0827,$0000,$2027,$0000,$1025,$0000,$00aa,$0000
	dc.w $0801,$0000,$1302,$0000,$1013,$0000,$0812,$0000
	dc.w $0055,$0000,$0283,$0000,$000b,$0000,$020b,$0000
	dc.w $01f6,$0000
	dc.w 0,0

Spr3F:	dc.w $0000,$0080
	dc.w $8000,$0000,$e000,$4000,$f000,$a000,$c800,$6000
	dc.w $2400,$d000,$1a00,$f800,$1b00,$e600,$a8c0,$d780
	dc.w $f460,$4bc0,$ba3c,$c5f0,$fc37,$53fe,$baa8,$c577
	dc.w $bd9f,$d260,$bf3f,$f8c2,$fe5f,$d1a7,$5c3f,$63c2
	dc.w $6e6b,$7194,$3715,$38ea,$9ca0,$1f5f,$daaa,$1fff
	dc.w $6fd7,$0fff,$b7fd,$07fd,$ddf8,$0000,$c055,$0055
	dc.w $880f,$0fff,$17ce,$1fc0,$5c60,$1c00,$6600,$0000
	dc.w $a000,$0000
	dc.w 0,0

Spr4F:	dc.w $0000,$0080
	dc.w $8000,$0000,$2000,$0000,$9000,$0000,$5800,$0000
	dc.w $0c00,$0000,$0600,$0000,$0100,$0000,$0040,$0000
	dc.w $8020,$0000,$000c,$0000,$9001,$0000,$0000,$0000
	dc.w $1000,$0000,$3802,$0000,$1007,$0000,$8002,$0000
	dc.w $8000,$0000,$c000,$0000,$e000,$0000,$e000,$0000
	dc.w $7000,$0000,$b802,$0000,$dfff,$0000,$ffaa,$0000
	dc.w $f000,$0000,$603e,$0000,$63e0,$0000,$7e00,$0000
	dc.w $a000,$0000
	dc.w 0,0

copperBC:
	dc.l	$009683c0,$00960020

	dc.l	$008e0828,$00902898
	dc.l	$01020000
	dc.l	$00920038,$009400d0
	dc.w	$0108,-40,$010a,-40

	dc.l	$01200000,$01220000
	dc.l	$01240000,$01260000
	dc.l	$01280000,$012a0000
	dc.l	$012c0000,$012e0000
	dc.l	$01300000,$01320000
	dc.l	$01340000,$01360000
	dc.l	$01380000,$013a0000
	dc.l	$013c0000,$013e0000

	dc.l	$01800000
c11BC:	dc.w	$00e0
	dc.w	0
	dc.w	$00e4
	dc.w	0
	dc.w	$00e8
	dc.w	0
	dc.w	$00ec
	dc.w	0
	dc.w	$00f0
	dc.w	0

	dc.w	$0100,%0101000000000000
makeBC:

colhx:	dc.w $0000,$0010,$0420,$0530
	dc.w $0740,$0752,$0960,$0b70
	dc.w $0d83,$0f91,$0fa2,$0fa6
	dc.w $0fa2,$0fc2,$0fe5,$0fff
	dc.w $00f4,$0010,$0020,$0430
	dc.w $0650,$0854,$0a60,$0c74
	dc.w $0f92,$0fc4,$0040,$0062
	dc.w $0085,$00ba,$00ed,$0fff

CopperAX:
	dc.l	$009683c0,$00960020
XXC:	dc.l	$008eff18,$009000e8
	dc.l	$01020000
	dc.l	$00920038,$009400d0
	dc.w	$0108,0,$010a,0

colh:	dc.w $0180,$0,$0182,$0,$0184,$0,$0186,$0
	dc.w $0188,$0,$018a,$0,$018c,$0,$018e,$0
	dc.w $0190,$0,$0192,$0,$0194,$0,$0196,$0
	dc.w $0198,$0,$019a,$0,$019c,$0,$019e,$0
	dc.w $01a0,$0,$01a2,$0,$01a4,$0,$01a6,$0
	dc.w $01a8,$0,$01aa,$0,$01ac,$0,$01ae,$0
	dc.w $01b0,$0,$01b2,$0,$01b4,$0,$01b6,$0
	dc.w $01b8,$0,$01ba,$0,$01bc,$0,$01be,$0

cax:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.l	$01005000
	dc.l	-2

copperW:dc.l	$009683e0,$00960020
	dc.l	$008e2c64,$00902cd1
	dc.l	$01080024,$010a0024
	dc.l	$00920030,$009400d8
cols1W:	dc.w	$0180,0,$0182,0,$0184,0,$0186,0
	dc.w	$0188,0,$018a,0,$018c,0,$018e,0
	dc.w	$0190,0,$0192,0,$0194,0,$0196,0
	dc.w	$0198,0,$019a,0,$019c,0,$019e,0
	dc.w	$01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w	$01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w	$01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w	$01b8,0,$01ba,0,$01bc,0,$01be,0
Rig1W:	dc.l	$010200ff
c11W:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.l	$00f40000
	dc.l	$00f60000
	dc.l	$4807fffe
	dc.l	$01006000
	dc.l	$6607fffe
cols2W:	dc.w $0180,0,$0182,0,$0184,0,$0186,0
	dc.w $0188,0,$018a,0,$018c,0,$018e,0
	dc.w $0190,0,$0192,0,$0194,0,$0196,0
	dc.w $0198,0,$019a,0,$019c,0,$019e,0
	dc.w $01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w $01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w $01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w $01b8,0,$01ba,0,$01bc,0,$01be,0
Rig2W:	dc.l	$01020000
c12W:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.l	$00f40000
	dc.l	$00f60000
	dc.l	$9607fffe
cols3W:	dc.w $0180,0,$0182,0,$0184,0,$0186,0
	dc.w $0188,0,$018a,0,$018c,0,$018e,0
	dc.w $0190,0,$0192,0,$0194,0,$0196,0
	dc.w $0198,0,$019a,0,$019c,0,$019e,0
	dc.w $01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w $01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w $01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w $01b8,0,$01ba,0,$01bc,0,$01be,0
Rig3W:	dc.l	$010200ff
c13W:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.l	$00f40000
	dc.l	$00f60000
	dc.l	$de07fffe
cols4W:	dc.w $0180,0,$0182,0,$0184,0,$0186,0
	dc.w $0188,0,$018a,0,$018c,0,$018e,0
	dc.w $0190,0,$0192,0,$0194,0,$0196,0
	dc.w $0198,0,$019a,0,$019c,0,$019e,0
	dc.w $01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w $01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w $01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w $01b8,0,$01ba,0,$01bc,0,$01be,0
Rig4W:	dc.l	$01020000
c14W:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.l	$00f40000
	dc.l	$00f60000
	dc.l	$ffddfffe,$1407fffe,$01000000
	dc.l	$fffffffe

coppero:dc.l	$009683e0,$00960020

;	dc.l	;$01060000,
	dc.l	$00f80000,$00fa0000,$01fc0000
	dc.l	$008e2c50,$00902cc1
	dc.l	$01080012,$010a0012
	dc.l	$00920038,$009400d0

colors:	dc.w $0180,0,$0182,0,$0184,0,$0186,0
	dc.w $0188,0,$018a,0,$018c,0,$018e,0
	dc.w $0190,0,$0192,0,$0194,0,$0196,0
	dc.w $0198,0,$019a,0,$019c,0,$019e,0
	dc.w $01a0,0,$01a2,0,$01a4,0,$01a6,0
	dc.w $01a8,0,$01aa,0,$01ac,0,$01ae,0
	dc.w $01b0,0,$01b2,0,$01b4,0,$01b6,0
	dc.w $01b8,0,$01ba,0,$01bc,0,$01be,0
c11o:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000
	dc.l	$00f40000
	dc.l	$00f60000
	dc.l	$01006000
	dc.l	$e307fffe,$01000000
	dc.l	$fffffffe

EmptyCopper:
	dc.l	$01800000,$01000000,$fffffffe
	dc.w	$0100
Bpc:	dc.w	0

copperQ:dc.l	$009683e0,$00960020
	dc.l	$008e2874,$009041ce
	dc.l	$01080000,$010a0014,$01020000
	dc.l	$00920030,$009400d8
c13Q:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00f00000
	dc.l	$00f20000
c11Q:	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00ec0000
	dc.l	$00ee0000
;	dc.l	$3007fffe

MvDnQ:	dc.l	$aa07fffe
	dc.l	$01000000
	dc.l	$01800052,$01820052,$01840052,$01860052
	dc.l	$01880052,$018a0052,$018c0052,$018e0052
	dc.l	$01900052,$01920052,$01940052,$01960052
	dc.l	$01980052,$019a0052,$019c0052,$019e0052
	dc.l	$01a00052,$01a20052,$01a40052,$01a60052
	dc.l	$01a80052,$01aa0052,$01ac0052,$01ae0052
	dc.l	$01b00052,$01b20052,$01b40052,$01b60052
	dc.l	$01b80052,$01ba0052,$01bc0052,$01be0052
MvDn2Q:	dc.l	$ab07fffe
clrsQ:
;	dc.w $0180,$0113,$0182,$0234,$0184,$0456,$0186,$0224
;	dc.w $0188,$0636,$018a,$0848,$018c,$0335,$018e,$0678

	dc.w $0180,$0113,$0182,$0234,$0184,$0fff,$0186,$0fff
	dc.w $0188,$0456,$018a,$0224,$018c,$0fff,$018e,$0fff
	dc.w $0190,$0668,$0192,$0789,$0194,$0fff,$0196,$0fff
	dc.w $0198,$09ab,$019a,$0779,$019c,$0fff,$019e,$0fff
	dc.w $01a0,$0636,$01a2,$0848,$01a4,$0fff,$01a6,$0fff
	dc.w $01a8,$0335,$01aa,$0678,$01ac,$0fff,$01ae,$0fff
	dc.w $01b0,$0b8b,$01b2,$0d9d,$01b4,$0fff,$01b6,$0fff
	dc.w $01b8,$088a,$01ba,$0bcd,$01bc,$0fff,$01be,$0fff
cip:	dc.l	$ac07fffe
	dc.w	$0100
Bpc2:	dc.w	0

mvupQ:	dc.l	$01be0000
mvup2Q:	dc.l	$aa07fffe
	dc.l	$01000000
	dc.l	$01800052,$01820052,$01840052,$01860052
	dc.l	$01880052,$018a0052,$018c0052,$018e0052
	dc.l	$01900052,$01920052,$01940052,$01960052
	dc.l	$01980052,$019a0052,$019c0052,$019e0052
	dc.l	$01a00052,$01a20052,$01a40052,$01a60052
	dc.l	$01a80052,$01aa0052,$01ac0052,$01ae0052
	dc.l	$01b00052,$01b20052,$01b40052,$01b60052
	dc.l	$01b80052,$01ba0052,$01bc0052,$01be0052
mvup3Q:	dc.l	$ab07fffe
	dc.l	$01800000,$01820000,$01840000,$01860000
	dc.l	$01880000,$018a0000,$018c0000,$018e0000
	dc.l	$01900000,$01920000,$01940000,$01960000
	dc.l	$01980000,$019a0000,$019c0000,$019e0000
	dc.l	$01a00000,$01a20000,$01a40000,$01a60000
	dc.l	$01a80000,$01aa0000,$01ac0000,$01ae0000
	dc.l	$01b00000,$01b20000,$01b40000,$01b60000
	dc.l	$01b80000,$01ba0000,$01bc0000,$01be0000
	dc.l	$fffffffe
CopEndQ:

copper2Q:
	dc.l	$01000000
	dc.l	$01800000
	dc.l	$01820052

	dc.l	$009683e0,$00960020
	dc.l	$008e2874,$009041ce
	dc.l	$01080014,$010a0014
	dc.l	$00920030,$009400d8

c12Q:	dc.l	$00e00000
	dc.l	$00e20000

mviQ:	dc.l	$aa07fffe
	dc.w	$0100,%0001000000000000
	dc.l	$ac07fffe
	dc.l	$01000000
	dc.l	$fffffffe

copperH:dc.l	$01020000
	dc.l	$009683e0
	dc.l	$00960020
	dc.l	$01000000
	dc.l	$01080000
	dc.w	$010a,-80
	dc.l	$008e21a2,$00902ca8

c11H:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000,$00f20000
	dc.l	$00920038,$009400d0

	dc.l	$01800000,$0182000f,$0184000f,$018600ff
	dc.l	$2807fffe
	dc.w	$0100,%0010000000000000

	dc.l	$ffddfffe
	dc.l	$2807fffe
	dc.l	$01000000
	dc.l	$fffffffe

copperU:
	dc.l	$009683e0,$00960020
	dc.l	$008e2150,$00902cc1
	dc.l	$01080000,$010a0000

	dc.l	$5a07fffe
	dc.w	$0108,$18,$010a,$18
	dc.l	$00920038,$009400d0

	dc.l	$5b07fffe
c11U:	dc.l	$00e00000
	dc.l	$00e20000 
	dc.l	$00e40000
	dc.l	$00e60000
	dc.w	$0100,%0010000000000000
	dc.l	$01800000,$01820fff,$01840fff,$01860fff

	dc.l	$fffffffe


copper_2_b:
	dc.l	$009683e0
	dc.l	$00960020
	dc.l	$01000000
	dc.w	$0108,0,$010a,0
	dc.l	$008e2c2c,$00902cc0
	dc.w	$0180
bcgcl_2_b:
	dc.w	$0fff
	dc.l	$01820fff
c11_2_b:dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00920038,$009400d0
	dc.l	$4807fffe
	dc.w	$0100,%0001000000000000
	dc.l	$ffddfffe,$1107fffe
	dc.l	$01000000
	dc.w	$ffff,$fffe

		section	chips,data_c

	incdir	my:incl/

spr1FL:		incbin	ball_sprites.dta
LodzioF:	incbin	Trsi.lodzio.raw
ball_2_b:	incbin	ball2.raw
		blk.b	40

		section	external,data_p

module2:	incbin	endmodule
endmodule2:
bcgrBB:		blk.w	8
		incbin	raster.dta,256
		blk.w	10,0
PosY1:		incbin	cdt1.dta
PosY2:		incbin	cdt2.dta
sinus0:		incbin	VecSinus.dta
ss0:		blk.b	100
sinusM		=sinus0

sinusG:		incbin	Vector_Sinusy.dta
ygrekG=	ampl+[ampl/2]
sinusfG:
sinusf2G=sinusfg+[ygrekG+50]*2
		incbin	Gel-sinusy.dta
SphPP:		incbin	SphereData.pp
EndSphPP:
picB:		incbin	sph2.raw
		incbin	sph2.raw
picend2:
picendB=picend2-[96/8]*0

tablica1L:	incbin	tablica.pp
endtabl1L:
tabl3L:		incbin	rot3.dta
PicPPL:		incbin	Trsi.raw.pp
endpicL:
PicPP1:		incbin	Istota.raw.pp
PicEnd1:
imgVF:		incbin block.s
pipVF:		blk.b	2000
NinjaPP:	incbin	Ninja.raw.pp
EndNPP:
TabN:		incbin	Mucha.dta
EndTabN:
cpic1pp:	incbin	cube1.pp
cpic2pp:	incbin	cube2.pp
cpicendpp:
sinusBB:	incbin	Ball.dta

kulsBB		=SinusBB+1100
sinusmoveBB	=sinusBB+5196
endsinBB	=sinusmovebb

RamkiFast:	incbin	Ramka.Up.Raw
		incbin	Ramka.Down.Raw

SprDatFast:	incbin	RamkaSpr.dta
SprDatEnd:

FontFast:	incbin	font.raw
		incbin	Signs.raw
SignsFastEnd:

SeqPicPP:	incbin	Seq.raw.pp
EndSeqPP:

FrogPic:	incbin	Frog.raw

WWSUpp:		incbin	WWSU.raw.pp
WWSUppe:

sins0H:		incbin	dts.dta
sins1H=sins0H+dotsH*ilesinH*2
sins2H=sins1H+dotsH*ilesinH*2
sins3H=sins2H+dotsH*ilesinH*2

;sinusxU:	incbin	DtScSin.dat
;sinusYU=SinusXU+$600
sins_b:		incbin	balls_sinus.dta
sin2_2_b:	incbin	balls2_sinus.dta

ilesinJ=100
ilesin2J=400
sinJ:		incbin	Wkr.Sin.Dta
sin1J		=SinJ+400
sin2J		=Sin1J+IleSInJ*4
endsinJ		=Sin2J+IleSIn2J*4+400
tablica1J:	incbin	tabl.pp
endtabl1J:
picpJ:		incbin	wkr.raw.pp
PicJe:
NdPPED:		incbin	EndLogo.raw.pp
NdPPEndED:
Putpoints:	ds.b	$a700

		section	puste,data_c
endmodul:
mod:		incbin	module

RamkaUp:	ds.b	$8850
RamkaDown:	ds.b	$8850
RamkaDownE:

Free:		incbin	RobakAnim.pp

srakaQ:		incbin	fonty32chala.raw
		blk.b	100,0
ZoomPicQ:	incbin	zoompic.raw
		ds.b	$20000-$9100-$a6d2
as:

RamkaUpX	=Free+$2940
RamkaDownX	=RamkaUpX+$12c0
EndRamkiX	=RamkaDownX+$1680

Tabl1		=EndRamkiX
FreeGel		=Free

Pic		=RamkaUp
Pic2		=RamkaDown

SprDat0		=Free
copper		=SprDat0+$1830
mul400		=Copper+$6000
mulm40		=Mul400+$200
mul40		=Mulm40+$200

destpM		=Mul40+$200
sinxM		=DestpM+$200
CrM		=SinXM+$270
maximumM	=crM+$c8
mul40M		=CrM+$190
screenM		=Mul40M+$200
screen0		=ScreenM+$4fb0*4

tabl1p		=Tabl1+32400
tabl2		=Tabl1p+32400
tabl2p		=Tabl2+16200

tabl1L		=Tabl1
ttabl1L		=Tabl1L+60000
tabl2L		=Ttabl1L+60000
ttabl2L		=Tabl2L+30000
screen		=Ttabl2L+30000
picL		=screen
;PutPoints	=picL+$1f40*6

font		=Tabl1
Signs1		=Font+$1680
screen21	=Signs1+$1310
screen1		=Screen21+$2ee0
screenRC1	=Screen21
screenRC2	=Screen21
sinusF		=Tabl1
endsinusF	=SinusF+[endsinustabF-sinustabF]*10
obrVF		=EndSinusF
routpF		=ObrVF+30000
endF		=routpF+$18000	;40*256*3*2
NinjaScr	=Tabl1

CopperBB	=RamkaUp
C11BB		=C11BC-CopperBC+CopperBB
MakeBB		=MakeBC-CopperBC+COpperBB
dodajnikBB	=CopperBB+4*[150*38+3]+[MakeBC-CopperBC]
colortableBB	=DodajnikBB+$400
screenBB	=colortableBB+130*160*8+160+128+32
SeqPic		=ScreenBB

Screen2		=Free
Screeno		=screen2+$f8c4
Faces		=screen2+$1f188
Robak1		=screen2+$1f6c8
Robak2		=screen2+$25740

WWSUW		=screen
WeW		=WWSUW
WillW		=WeW+80*27-2
SmashW		=WeW+80*78
YouW		=WeW+80*150-2

DTScr		=Free
TablQ		=DTScr+$10000
EndTablQ	=TablQ+$200
AdTbQ		=EndTablQ
AdrsQ		=AdTbQ+$200
BitsQ		=AdrsQ+$200
PozYQ		=BitsQ+$200
AbsEndTablQ	=PozYQ+$200
TablBufQ	=AbsEndTablQ+$200	;[AbsEndTablQ-TablQ]

FreeH		=Free

end_b		=Free

screenJ		=Free
putpointsJ	=ScreenJ+$1f40*6
picJ		=PutPointsJ+$6000
tabl1J		=PicJ+20480+$d99c
tabl2J		=tabl1J+$d99c/2

fonted		=free
LogoED		=fonted+$1680+120*16
ScreenED	=LogoED+26000		;$2800*3


end




