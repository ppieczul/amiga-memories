

	lea	bufor,a0
	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a

	lea	module,a0
	move.l	a0,tp_data
	bsr.s	tp_init

	bsr	run
	bsr	run2
	bsr	run3

	lea	screena,a0
	move.l	#$4b00,d7
aa:	clr.l	(a0)+
	dbra	d7,aa

	bsr	runa

	bsr	run4

	bsr	run5

	bsr	tp_end

	move.w	bufor,d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	rts


no=0
yes=1

pt1.1=no	;protracker v1.1 compatible (default=pt2.0)
syncs=no	;do you use vibrato or tremolo with sync ?
funk=no		;do you use the ef-comand ?
vbruse=no	;use vectortableoffset ?
volume=yes	;use volumesliding ?
suck=yes	;das ya dick wanna b suckd ?
		;(sorry, not yet implementated)

tp_init:
	lea	$dff002,a5
	lea	tp_wait,a0
	move	#1,(a0)
	clr	tp_pattcount-tp_wait(a0)
	move	#6,tp_speed-tp_wait(a0)
	move.l	tp_data,a1
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
	lea	tp_instlist,a2
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
	lea	tp_voice0dat,a1
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
	lea	tp_mainint,a2
	move.l	a2,tp_int1pon-tp_wait(a0)
	if	vbruse
	move.l	tp_vbr,a1
	move.l	$78(a1),tp_oldint-tp_wait(a0)
	move.l	a2,$78(a1)
	else
	move.l	$78.w,tp_oldint-tp_wait(a0)
	move.l	a2,$78.w
	endc
	lea	tp_voiceloopint,a2
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
	move.l	tp_vbr,a1
	move.l	tp_oldint,$78(a1)
	else
	move.l	tp_oldint,$78.w
	endc
	rts

tp_mainint:
	movem.l	d0-a5,-(a7)
	lea	$dff002,a5
	tst.b	$bfdd00
	move	#$2000,$9a(a5)
	moveq	#0,d4
	lea	tp_wait,a0
	clr.b	tp_dmaon-tp_wait+1(a0)
	subq	#1,(a0)
	beq	tp_newline
tp_playeffects:
	lea	tp_voice0dat+6,a1
	move	(a1)+,d0
	beq.s	tp_novoice1
	lea	$9e(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice1:
	lea	tp_voice1dat+6,a1
	move	(a1)+,d0
	beq.s	tp_novoice2
	lea	$ae(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice2:
	lea	tp_voice2dat+6,a1
	move	(a1)+,d0
	beq.s	tp_novoice3
	lea	$be(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice3:
	lea	tp_voice3dat+6,a1
	move	(a1)+,d0
	beq.s	tp_novoice4
	lea	$ce(a5),a3
	jsr	tp_fxplaylist-4(pc,d0.w)
tp_novoice4:
	move.b	tp_dmaon+1,d4
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
	move	tp_speed,(a0)
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
	move.l	tp_pattadr,a1
	move	(a1)+,tp_pattadrpon-tp_wait(a0)
	cmp.l	tp_pattadr2,a1
	bne.s	tp_pattadrok
	move.l	tp_pattadr3,a1
tp_pattadrok:
	move.l	a1,tp_pattadr-tp_wait(a0)
tp_repeatit:
	clr	tp_pattrepeat-tp_wait(a0)
	move	tp_pattadrpon,d0
	move.l	tp_pattlistadr,a1
	movem	(a1,d0.w),d0-d3
	moveq	#-2,d4
	move.l	tp_pattdataadr,a1
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

	move	tp_shitpon,d0
	bne.s	tp_noshit
	moveq	#1,d0
	bra.s	tp_shit
tp_noshit:
	moveq	#0,d0
tp_shit:

	add	tp_newpattpos,d0
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
	lea	tp_voice0dat+2,a1
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
	lea	tp_voice0dat+1,a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice0end
	moveq	#1,d4
	lea	$9e(a5),a3
	bsr	tp_playvoice
tp_playvoice0end:
	move	26(a1),$a4(a5)
	lea	tp_voice1dat+1,a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice1end
	moveq	#2,d4
	lea	$ae(a5),a3
	bsr	tp_playvoice
tp_playvoice1end:
	move	26(a1),$b4(a5)
	lea	tp_voice2dat+1,a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice2end
	moveq	#4,d4
	lea	$be(a5),a3
	bsr	tp_playvoice
tp_playvoice2end:
	move	26(a1),$c4(a5)
	lea	tp_voice3dat+1,a1
	addq.b	#2,(a1)+
	bmi.s	tp_playvoice3end
	moveq	#8,d4
	lea	$ce(a5),a3
	bsr.s	tp_playvoice
tp_playvoice3end:
	move	26(a1),$d4(a5)
	move.b	tp_dmaon+1,d4
tp_initnewsamples:
	move	d4,$94(a5)
	lea	tp_dmaonint,a1
	if	vbruse
	move.l	tp_vbr,a2
	move.l	a1,$78(a2)
	else
	move.l	a1,$78.w
	endc
	move.b	#$19,$bfdf00
	if	funk
tp_funkit:
	lea	tp_voice0dat+48,a1
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
	mulu	tp_volume,d5
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
	sub	tp_speed,d2
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
	mulu	tp_volume,d1
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
	mulu	tp_volume,d0
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
	lea	tp_voicefx9after,a4
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
	move.l	tp_pattadr3,a1
	add.w	d1,d1
	add.w	d1,a1
	move.l	a1,tp_pattadr-tp_wait(a0)
	rts

tp_voicefxc:
	move	6(a1),d1
	move	d1,10(a1)
	if	volume
	mulu	tp_volume,d1
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
	move	tp_pattcount,50(a1)
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
	move	tp_speed,d1
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
	move	tp_dmaon,$dff096
	if	vbruse
	move.l	a0,-(a7)
	move.l	tp_vbr,a0
	move.l	tp_int3pon,$78(a0)
	move.l	(a7)+,a0
	else
	move.l	tp_int3pon,$78.w
	endc
	move	#$2000,$dff09c
	rte

tp_voiceloopint:
	tst.b	$bfdd00
	move.l	tp_voice0dat+18,$dff0a0
	move	tp_voice0dat+24,$dff0a4
	move.l	tp_voice1dat+18,$dff0b0
	move	tp_voice1dat+24,$dff0b4
	move.l	tp_voice2dat+18,$dff0c0
	move	tp_voice2dat+24,$dff0c4
	move.l	tp_voice3dat+18,$dff0d0
	move	tp_voice3dat+24,$dff0d4
	if	vbruse
	move.l	a0,-(a7)
	move.l	tp_vbr,a0
	move.l	tp_int1pon,$78(a0)
	move.l	(a7)+,a0
	else
	move.l	tp_int1pon,$78.w
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

	lea	copper,a0
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
	move.l	#250,d6

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

No60:	cmp.l	#200,d6
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

	move.l	#400,d6

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


run4:	lea	Pic2a,a0
	move.l	a0,d0
	sub.l	#12,d0
	lea	c14,a1
	moveq	#2,d7
setc4:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$a28,d0
	dbra	d7,Setc4

	lea	copper4,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	moveq	#50,d7
aksla:	waitframe
	dbra	d7,aksla

	moveq	#24,d0
Part4:	moveq	#14,d7
Paw:	waitframe
	dbra	d7,Paw
	move.w	#$fff,Col4
	waitframe
	move.w	#$0,Col4
	dbrA	d0,Part4

	rts

run5:
	lea	make5,a0
	move.l	#255,d7
	moveq	#45,d0

mak5:	move.l	#$01800000,(a0)+
	move.l	#$01820000,(a0)+
	move.l	#$01840000,(a0)+
	move.l	#$01860000,(a0)+

	cmp.b	#$0,d0
	bne.b	NoWA
	move.l	#$ffddfffe,(a0)+
	addq.b	#1,d0
	bra.b	YeAS
NoWA:	move.b	d0,(a0)+
	move.b	#7,(a0)+
	move.w	#-2,(a0)+
	addq.b	#1,d0
YeAS:	dbra	d7,mak5

	lea	Credit,a0
	move.l	a0,d0
	lea	c15,a1
	moveq	#4,d7
setc5:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$2800,d0
	dbra	d7,Setc5

	lea	copper5,a0
	move.l	a0,$dff080
	move.w	d0,$dff088

	move.l	#127,d7

	lea	Make5+5*4*0,a0
	lea	Make5+255*5*4,a1

Cr5:	waitframe
	move.w	#Col05,2(a1)
	move.w	#Col15,6(a1)
	move.w	#Col25,10(a1)
	move.w	#Col35,14(a1)

	move.w	#Col05,2(a0)
	move.w	#Col15,6(a0)
	move.w	#Col25,10(a0)
	move.w	#Col35,14(a0)

	add.l	#5*4*2,a0
	sub.l	#5*4*2,a1

	dbra	d7,Cr5


	move.l	#450,d7
qksla:	waitframe
	dbra	d7,qksla

	move.l	#127,d7
	lea	Make5+5*4*0,a0
	lea	Make5+255*5*4,a1

Cr15:	waitframe
	move.w	#0,2(a1)
	move.w	#Colx,6(a1)
	move.w	#Colx,10(a1)
	move.w	#Colx,14(a1)

	move.w	#0,2(a0)
	move.w	#Colx,6(a0)
	move.w	#Colx,10(a0)
	move.w	#Colx,14(a0)

	add.l	#5*4*2,a0
	sub.l	#5*4*2,a1

	dbra	d7,Cr15

	move.l	#127,d7
	lea	Make5+5*4*0,a0
	lea	Make5+255*5*4,a1

Cr25:	waitframe
	clr.w	2(a1)
	clr.w	6(a1)
	clr.w	10(a1)
	clr.w	14(a1)

	clr.w	2(a0)
	clr.w	6(a0)
	clr.w	10(a0)
	clr.w	14(a0)

	add.l	#5*4*2,a0
	sub.l	#5*4*2,a1
	subq.w	#2,tp_volume

	dbra	d7,Cr25

	rts


col05	=0
col15	=$fff
col25	=$450
col35	=$f00
colx	=$00f

copper5:
	dc.l	$009683e0,$00960020

	dc.l	$008e2c50,$00902cc1
	dc.l	$01080000,$010a0000,$01020000
	dc.l	$00920038,$009400d0,$01000000

c15:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000
	dc.l	$00ec0000
	dc.l	$00ee0000
	dc.l	$00f00000
	dc.l	$00f20000

	dc.l	$01002000

make5:	ds.l	5*256+4
	dc.l	$fffffffe


copper:	dc.l	$009683e0

	dc.l	$01200000,$01220000
	dc.l	$01240000,$01260000
	dc.l	$01280000,$012a0000
	dc.l	$012c0000,$012e0000
	dc.l	$01300000,$01320000
	dc.l	$01340000,$01360000
	dc.l	$01380000,$013a0000
	dc.l	$013c0000,$013e0000

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


runa:	lea	pstra,a0
	moveq	#[pstrenda-pstra]/2-1,d7
stilpa:	move.w	(a0)+,d0
	bmi.b	stila
	asl.w	#2,d0
	move.w	d0,-2(a0)
stila:	dbra	d7,stilpa

	lea	mul40a,a0
	moveq	#0,d0
lopklopa:move.l	d0,d1
	mulu	#40,d1
	move.w	d1,(a0)+
	addq.l	#1,d0
	cmp.l	#$100,d0
	bne.b	lopklopa

	lea	singlea,a1
	lea	screena,a0
	move.l	a0,(a1)
	add.l	#$1900*3,a0
	move.l	a0,4(a1)
	add.l	#$1900*3,a0
	move.l	a0,8(a1)
	add.l	#$1900*3,a0
	move.l	a0,12(a1)

	lea	Pic1a,a0
	move.l	a0,d0
	lea	c10a,a1
	moveq	#2,d1
clop2a:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$4d8,d0
	dbra	d1,clop2a

	moveq	#2,d1
	bsr.w	setscra
	move.l	singlea+12,a0

	lea	bufora,a0
	lea	starya,a1
	lea	vblka,a2
	lea	nexta,a3

	move.w	$dff01c,(a0)
	move.w	#$7fff,$dff09a
	move.l	$6c,(a1)
	move.l	a2,$6c
	move.l	starya,$02(a3)
	
	move.w	(a0),d0
	or.w	#$8020,d0
	move.w	d0,$dff09a

	lea	coppera,a0
	move.l	a0,$dff080
	move.w	d0,$dff088


mysza:	cmp.l	#$770,Timerab
	bge.b	QuitA
	bra.b	mysza
	
quita:  move.w	#$7fff,$dff09a
	move.l	starya,$6c
	move.w	bufora,d0
	or.w	#$8000,d0
	move.w	d0,$dff09a
	rts

vblka:	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$dff01e,d0
	and.w	#$0020,d0
	bne.s	okeya
	bra.s	exit2a
exit1a:
;	move.w	#$8,$dff180
	move.w	#$0020,$dff09c
exit2a:	movem.l	(sp)+,d0-d7/a0-a6
nexta:	jmp	0.l

okeya:	addq.l	#1,TimerAB
	lea	singlea,a0
	movem.l	(a0),d0-d2
	exg.l	d0,d1
	exg.l	d0,d2
	movem.l	d0-d2,(a0)

	moveq	#2,d1
	bsr.w	setscra

	bsr.w	cleara

	lea	PreAlfaa,a0
	lea	destpa,a4
	lea	pointsa,a5
	move.l	#[pointsenda-pointsa]/6-1,d7

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5

	lea	sinusa,a6

	move.w	alfaa,d2
	add.w	d2,d2
	move.w	(a6,d2.w),2(a0)
	add.w	#180,a6
	move.w	(a6,d2.w),(a0)

	move.w	alfaa+2,d2
	add.w	d2,d2
	move.w	(a6,d2.w),6(a0)
	add.w	#180,a6
	move.w	(a6,d2.w),4(a0)

	move.w	alfaa+4,d2
	add.w	d2,d2
	move.w	(a6,d2.w),10(a0)
	add.w	#180,a6
	move.w	(a6,d2.w),8(a0)

cpr2a:	move.w	(a5)+,d0
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

leftya:	;move.l	#$2000,d3
	sub.l	#vxa*2*40,d5
	asl.l	#3,d5
	move.l	d5,d3
	muls.w	d3,d0
	muls.w	d3,d1
	swap	d0
	swap	d1

	move.w	d0,(a4)+
	move.w	d1,(a4)+
	dbra	d7,cpr2a

	bsr.w	filla

	lea	dodpa,a1
	lea	bplpa,a2
	move.l	singlea,a3
	lea	destpa,a4
	move.l	a3,a5
	lea	pstra,a6

	move.w	(a6)+,d0

	move.w	d0,(a1)
	move.w	d0,2(a1)

repta:	move.w	(a1),d3

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
	bpl.b	Pluka

waita:	move.w	(a6)+,d0
	bpl.b	waita	
	cmp.w	#-4,d0
	beq.b	waita
	subq.l	#2,a6
	bra.b	Pluka

rept2a:	move.w	(a1),d1
	move.w	d6,(a1)

	move.w	(a4,d1.w),d2
	move.w	2(a4,d1.w),d3
	move.w	2(a4,d6.w),d1
	move.w	(a4,d6.w),d0
	bsr.w	linea

Pluka:	move.w	(a6)+,d6
	bpl.b	Rept2a

	cmp.b	#-1,d6
	beq.b	quitya

	move.l	a5,d7
	move.w	(a6)+,d0
	add.l	(a2,d0.w),d7

	move.l	(a1),d0

	move.w	(a4,d0.w),d2
	move.w	2(a4,d0.w),d3
	swap	d0
	move.w	2(a4,d0.w),d1
	move.w	(a4,d0.w),d0
	bsr.w	linea

	move.w	(a6),(a1)
	move.w	(a6)+,2(a1)
	move.l	d7,a3
	cmp.b	#-4,d6
	beq.b	pluka
	bra.w	repta

quitya:

	lea	alfaa,a0
	lea	dodaja,a1

	moveq	#2,d0
addlv2a:	move.w	(a1),d1
	add.w	d1,(a0)
	cmp.w	#360,(a0)
	blt.b	nookr2a
	sub.w	#360,(a0)
nookr2a:	tst.w	(a0)
	bge.b	nookr3a
	add.w	#360,(a0)
nookr3a:	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d0,addlv2a

	lea	Msina,a0
	move.l	SinPosa,d0
	move.l	Addza,d1
	add.l	d1,d1
	add.l	d1,SinPosa

	cmp.l	#MEndSina-Msina,SinPosa
	blt.b	NMEa
	sub.l	#MEndSina-Msina,SinPosa
	clr.l	sinposa
NMEa:	add.l	d0,a0
	move.w	(a0),d0

	move.w	d0,Pointsa+4
	move.w	d0,Pointsa+4+6
	move.w	d0,Pointsa+4+12
	move.w	d0,Pointsa+4+18

	add.w	#25*vxa,d0

	move.w	d0,Pointsa+4+24
	move.w	d0,Pointsa+4+30
	move.w	d0,Pointsa+4+36
	move.w	d0,Pointsa+4+42

	subq.w	#1,Timera
	bgt.b	NoSCHa

	lea	Scripta,a0
	move.l	ScriptPosa,d0
	add.l	#10,ScriptPosa
	cmp.l	#ScriptEnda-Scripta,ScriptPosa
	blt.b	NoSEa
;	move.l	#Script2-Scripta,ScriptPosa
	clr.l	scriptposa
NoSEa:	add.l	d0,a0
	move.w	(a0)+,Timera
	move.l	(a0)+,Dodaja
	move.w	(a0)+,Dodaja+4
	move.w	(a0)+,Addza+2
NoSCHa:

	bra.w	exit1a

linea:	movem.l	d0-d6/a0-a6,-(sp)

	add.w	#160,d0
	add.w	#160,d2
	add.w	#110,d1
	add.w	#110,d3


	lea	mul40a,a1
	lea	$dff000,a5

	cmp.w	d3,d1
	beq.w	l_quita
	bhi.b	l_noycha

	exg.l	d1,d3
	exg.l	d0,d2

l_noycha:subq.w	#1,d1

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
	bge.b	y2Gy1a
	neg.w	d3
y2Gy1a:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.b	x2Gx1a
	neg.w	d2
x2Gx1a:
	move.w	d3,d1
	sub.w	d2,d1
	bge.b	dyGdxa
	exg.l	d2,d3
dyGdxa:
	roxl.b	#1,d5
	add.w	d2,d2
	move.b	OctantsFa(pc,d5.w),d5

WBlita:	btst.b	#14,$02(a5)
	bne.b	WBlita

	move.w	d2,$62(a5)
	sub.w	d3,d2
	bge.b	SignNla
	or.b	#$40,d5
SignNla:
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

l_quita:	movem.l	(sp)+,d0-d6/a0-a6
	rts
OctantsNa:
	dc.b	1,17,09,21,5,25,13,29
OctantsFa:
	dc.b	3,19,11,23,7,27,15,31


waitblita:	
	btst	#14,$dff002
waitbla:	btst	#14,$dff002
	bne.s	waitbla
	rts

cleara:	bsr.b	waitblita
	move.l	singlea,a6
	addq.l	#4,a6
	move.l	a6,$dff054
	move.l	#$01000000,$dff040
	move.w	#10,$dff066
	move.w	#[480<<6]!15,$dff058
	rts

filla:	move.l	singlea+4,d0
	add.l	#$1900*3-6,d0
	bsr.b	waitblita
	move.l	#$ffffffff,$dff044
	move.l	d0,$dff050
	move.l	d0,$dff054
	move.l	#%00001001111100000000000000010010,$dff040
	move.w	#10,$dff064
	move.w	#10,$dff066
	move.w	#[480<<6]!15,$dff058
	rts


setscra:
	move.l	singlea+8,d0
	add.l	#48*40,d0
	lea	c11a,a1
clopa:	swap	d0
	move.w	d0,2(a1)
	swap	d0
	move.w	d0,6(a1)
	addq.l	#8,a1
	add.l	#$1900,d0
	dbra	d1,clopa
	rts


vxa=15
yxa=15

pointsa:

 dc.w	-05*vxa,+05*yxa,+00*vxa
dc.w	+05*vxa,+05*yxa,+00*vxa
dc.w	+05*vxa,-05*yxa,+00*vxa
dc.w	-05*vxa,-05*yxa,+00*vxa
dc.w	-05*vxa,+05*yxa,+36*vxa
dc.w	+05*vxa,+05*yxa,+36*vxa
dc.w	+05*vxa,-05*yxa,+36*vxa
dc.w	-05*vxa,-05*yxa,+36*vxa

dc.w	-10*vxa,+10*yxa,+00*vxa
dc.w	+10*vxa,+10*yxa,+00*vxa
dc.w	+10*vxa,-10*yxa,+00*vxa
dc.w	-10*vxa,-10*yxa,+00*vxa

dc.w	-15*vxa,+15*yxa,+00*vxa
dc.w	+15*vxa,+15*yxa,+00*vxa
dc.w	+15*vxa,-15*yxa,+00*vxa
dc.w	-15*vxa,-15*yxa,+00*vxa
pointsenda:

pstra:
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
pstrenda:

destpa:	blk.b	200,0

even

bufora:		dc.w	0
starya:		dc.l	0
alfaa:		dc.w	0,0,0,0
dodaja:		dc.w	0,6,0
posxa:		dc.l	0
scracta:		dc.l	0
singlea:		dc.l	0,0,0,0
dodpa:		dc.l	0,0
pointspa:	dc.l	0
pstrpa:		dc.l	0
pointsla:	dc.l	0
addza:		dc.l	0
objecta:		dc.l	-1
bplpa:		dc.l	0,$1900,$1900*2,$1900*3
prealfaa:	dc.l	0,0,0,0,0,0,0,0
SinPosa:		dc.l	0
timera:		dc.l	0
scriptposa:	dc.l	0
timerab:	dc.l	0

Msina:	DC.w	$002D,$003C,$004B,$005A,$0069,$0069,$0078,$0087,$0096,$0096
	DC.w	$00A5,$00A5,$00B4,$00B4,$00B4,$00B4,$00B4,$00B4,$00A5,$00A5
	DC.w	$0096,$0096,$0087,$0078,$0069,$0069,$005A,$004B,$003C,$002D
	DC.w	$000F,$0000,$FFF1,$FFE2,$FFD3,$FFD3,$FFC4,$FFB5,$FFA6,$FFA6
	DC.w	$FF97,$FF97,$FF88,$FF88,$FF88,$FF88,$FF88,$FF88,$FF97,$FF97
	DC.w	$FFA6,$FFA6,$FFB5,$FFC4,$FFD3,$FFD3,$FFE2,$FFF1,$0000,$000F
Mendsina:


scripta:
	dc.w	90,0,0,0,1
	dc.w	21,0,4,0,1
	dc.w	90,0,0,0,1
	dc.w	25,4,0,0,1
	dc.w	90,0,0,0,1
	dc.w	90,-4,0,0,1
	dc.w	90,3,2,1,1
;	dc.w	90,4,3,4,1
	dc.w	90,3,5,4,2
	dc.w	85,5,4,6,3
;	dc.w	90,6,8,3,4
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

scriptenda:

even

coppera:	dc.l	$009683c0,$01000000

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
	dc.w $0188,$0a0a,$018a,$0c0c,$018c,$0e0e,$018e,$0f0f

	dc.l	$4107fffe
c10a:	dc.l	$00e00000
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

c11a:	dc.l	$00e00000
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

	dc.l	-2

Copper4:
	dc.l	$009683c0,$00960020,$01000000

	dc.l	$008e2081,$009028c1
	dc.w	$0108,0,$010A,0

	dc.l	$00920038,$009400d0

c14:	dc.l	$00e00000
	dc.l	$00e20000
	dc.l	$00e40000
	dc.l	$00e60000
	dc.l	$00e80000
	dc.l	$00ea0000

Col4=*+2
	dc.l	$01800000
	dc.l	$01820fff,$01840ccc
	dc.l	$01860999
	dc.l	$01880444
	dc.l	$018a0999,$018c0888
	dc.l	$018e0666
	dc.l	$8807fffe
	dc.l	$01003000
	dc.l	$c907fffe,$01000000
	dc.l	-2

sinusa:
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

mul40a:	blk.w	256,0	

	incdir	ram:
pic1a:	incbin	anal.iff
pic2a:	incbin	info.iff



module:	incbin	slowiki.tp3
credit:
	incbin	cred.iff

screena:
screen1:
	incbin	dachaos.iff
screen2:
	incbin	presentatos.iff
	dc.l	0
screen3:
	incbin	muertos.iff
	ds.l	$2500
