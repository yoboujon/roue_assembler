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

	EXPORT Set_SCLK
	EXPORT Reset_SCLK
	EXPORT DriverGlobal

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

SCLK 		EQU 5
SIN1 		EQU 7
	
PF			DCD (1<<31)
Barette1 	DCB 0xff,0,0
			DCB 0,0xff,0
			DCB 0,0,0xff
			DCB 0xff,0,0
			DCB 0xff,0xff,0
			DCB 0xff,0xff,0xff
			DCB 0xff,0,0
			DCB 0,0xff,0
			DCB 0,0,0xff
			DCB 0xff,0,0
			DCB 0xff,0xff,0
			DCB 0xff,0xff,0xff
			DCB 0xff,0,0
			DCB 0xff,0xff,0
			DCB 0xff,0xff,0xff
			DCB 0x0f,0xff,0x00
			


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
		PUSH {R1,R2}				;On stocke R0 à R4 dans SP
		MOV R1, #1					;*******
		LSL R0, R1, R0				;1<<Arg
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		ORR R2, R2, R0				;similaire à GPIOA->ODR |= (1<<Arg)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R5) stocké dans ODR
		POP{R1,R2}					;Déchargement de la pile
		BX LR						;Retour
	
	ENDP
		
Reset_X	PROC
		PUSH {R1,R2}				;On stocke R0 à R4 dans SP
		MOV R1, #1					;*******
		LSL R0, R1, R0				;1<<Arg
		MVN R0, R0					;~(1<<Arg)
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		AND R2, R2, R0				;similaire à GPIOA->ODR &= ~(1<<Arg)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R5) stocké dans ODR
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
		;LDR R0,=		;DataSend <- 0
		B .				;while(1)
		
PoidFortOKIF
	BL Set_X			;Set_X(SCLK)
	B PoidFortOKJUMP	;After Reset8X
	
	ENDP

;**************************************************************************
	END