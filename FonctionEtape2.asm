;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************

	IMPORT DataSend
	EXPORT Set_SCLK
	EXPORT Reset_SCLK
	EXPORT DriverGlobal
	EXPORT Tempo
	EXPORT DriverReg

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 
	include LUMIERES.inc

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

SCLK 		EQU 5
SIN1 		EQU 7
MILSEC		EQU 1304
	
PF			DCD (1<<31)

;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

Set_SCLK	PROC
		PUSH {R0-R2}				;On stocke R0 à R2
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		ORR R2, R2,#(0x01 << 5)		;similaire à GPIOA->ODR |= (1<<5)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R5) stocké dans ODR
		BX LR						;Retour
	
	ENDP
		
Set_X	PROC
		PUSH {R1,R2}				;On stocke R1 et R2 dans SP
		MOV R1, #1					;*******
		LSL R0, R1, R0				;1<<Arg
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		ORR R2, R2, R0				;similaire à GPIOA->ODR |= (1<<Arg)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R2) stocké dans ODR
		POP{R1,R2}					;Déchargement de la pile
		BX LR						;Retour
	
	ENDP
		
Reset_X	PROC
		PUSH {R1,R2}				;On stocke R1 et R2 dans SP
		MOV R1, #1					;*******
		LSL R0, R1, R0				;1<<Arg
		MVN R0, R0					;~(1<<Arg)
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		AND R2, R2, R0				;similaire à GPIOA->ODR &= ~(1<<Arg)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R2) stocké dans ODR
		POP{R1,R2}					;Déchargement de la pile
		BX LR						;Retour
	
	ENDP

Reset_SCLK	PROC
		PUSH {R0-R2}				;On stocke R0 à R2 dans SP
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		AND R2, R2,#~(0x01 << 5)	;similaire à GPIOA->ODR &= ~(1<<5)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R5) stocké dans ODR
		BX LR						;Retour
	
	ENDP
		
Tempo PROC
		MOV R1,#10					;*******
		MUL R0,R0,R1				;10*Argument
		MOV R2,#MILSEC				;1304, la constante pour avoir 0.01ms
		MOV R3,#0					;0
WHILE_NBMIL							;for(int i=0;i<10*Arg;i++)
		ADD R3,R3,#1				;i++
		MOV R1,#0					;j=0
		CMP R3,R0					;SI i==10*Arg alors on arrête la boucle
		BXEQ LR
WHILE_NOPL							;for(int j=0;j<1304;j++)
		NOP							;Timing
		ADD R1,R1,#1				;j++
		CMP R1,R2					;SI j==1304 alors on arrête la sous-boucle
		BNE WHILE_NOPL				;NON : On retourne dans cette boucle
		B WHILE_NBMIL				;OUI : On retourne dans la surboucle
	ENDP
		
;****************************************************************************
;R1 = *ValCourante
;R2 = NBLed (i)
;R3 = ValCourante[i]
;****************************************************************************
DriverGlobal	PROC
		MOV R0, #SCLK	;Argument SCLK
		BL Set_X;		;Set_X(SCLK)
		LDR R1,=Barette1;On recupère l'adresse de base
		
		MOV R2, #0;			;*************************
WHILE_NBLED					;for(int i=0;i<48;i++)
		LDRB R3,[R1,R2]		;ValCourante[i]
		LSL R3,#24			;ValCourante[i]<<24
		
		LDR R0,=PF
		LDR R5,[R0,#0]	;R5 = (1<<31)
		MOV R4, #0		;*************************
WHILE_NBBIT				;for(int j=0;j<12;j++)
		MOV R0, #SCLK		;Argument SCLK
		BL Reset_X;			;Reset_X(SCLK)
		MOV R0, #SIN1		;Argument SIN1
		AND R6,R3,R5		;ValCourante[i] &= (1<<31) (<- PF)
		CMP R6,R5			;if(PF == 1)
		BEQ PoidFortOKIF	;{ Set_X(SIN1) }
		BL Reset_X;			;else { Reset_X(SIN1) }
PoidFortOKJUMP				;Fin Si
		LSL R3,#1			;ValeurCourante[i]<<1
		MOV R0, #SCLK		;Argument SCLK
		BL Set_X;			;Set_X(SCLK)
		ADD R4, R4, #1		;On incrémente NBBit
		CMP R4, #11			;SI NBBIT==11 alors on arrête la boucle
		BNE WHILE_NBBIT
		
		ADD R2, R2, #1		;On incrémente NBLed
		CMP R2, #47			;SI NBLED==47 alors on arrête la boucle
		BNE WHILE_NBLED
		
		MOV R0, #SCLK	;Argument SCLK
		BL Reset_X;		;Reset_X(SCLK)
		LDR R0,=DataSend;Adresse de DataSend
		MOV R1,#0		; DataSend
		STRB R1,[R0,#0]	;DataSend=0
		B .				;while(1)
		
PoidFortOKIF
	BL Set_X			;Set_X(SCLK)
	B PoidFortOKJUMP	;After Reset8X
	
	ENDP

;****************************************************************************
;R0 Argument : Barette
;R1 = *ValCourante
;R2 = NBLed (i)
;R3 = ValCourante[i]
;****************************************************************************

DriverReg	PROC
		PUSH {LR,R6}	;Place LR dans la pile
		MOV R1,R0		;On recupère l'adresse de base
		MOV R0, #SCLK	;Argument SCLK
		BL Set_X;		;Set_X(SCLK)
		
		MOV R2, #0;			;*************************
REG_WHILE_NBLED					;for(int i=0;i<48;i++)
		LDRB R3,[R1,R2]		;ValCourante[i]
		LSL R3,#24			;ValCourante[i]<<24
		
		LDR R0,=PF
		LDR R5,[R0,#0]	;R5 = (1<<31)
		MOV R4, #0		;*************************
REG_WHILE_NBBIT				;for(int j=0;j<12;j++)
		MOV R0, #SCLK		;Argument SCLK
		BL Reset_X;			;Reset_X(SCLK)
		MOV R0, #SIN1		;Argument SIN1
		AND R6,R3,R5		;ValCourante[i] &= (1<<31) (<- PF)
		CMP R6,R5			;if(PF == 1)
		BEQ REG_PoidFortOKIF;{ Set_X(SIN1) }
		BL Reset_X;			;else { Reset_X(SIN1) }
REG_PoidFortOKJUMP			;Fin Si
		LSL R3,#1			;ValeurCourante[i]<<1
		MOV R0, #SCLK		;Argument SCLK
		BL Set_X;			;Set_X(SCLK)
		ADD R4, R4, #1		;On incrémente NBBit
		CMP R4, #11			;SI NBBIT==11 alors on arrête la boucle
		BNE REG_WHILE_NBBIT
		
		ADD R2, R2, #1		;On incrémente NBLed
		CMP R2, #47			;SI NBLED==47 alors on arrête la boucle
		BNE REG_WHILE_NBLED
		
		MOV R0, #SCLK	;Argument SCLK
		BL Reset_X;		;Reset_X(SCLK)
		LDR R0,=DataSend;Adresse de DataSend
		MOV R1,#0		; DataSend
		STRB R1,[R0,#0]	;DataSend=0
		POP {LR,R6}		;On remet LR dans les registres
		BX LR			;On retourne dans le main
		
REG_PoidFortOKIF
	BL Set_X				;Set_X(SCLK)
	B REG_PoidFortOKJUMP	;After Reset8X
	
	ENDP

;**************************************************************************
	END
