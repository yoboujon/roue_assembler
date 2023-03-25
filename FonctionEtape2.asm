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

 
Barette1 	DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			DCB 0,1,0
			


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

Reset_SCLK	PROC
		PUSH {R0-R2}				;On stocke R0 à R2
		LDR R1,=GPIOBASEA			;R1 -> Adresse de GPIOA
		LDRH R2,[R1,#OffsetOutput]	;Valeur à l'adresse d'ODR : R2 = GPIOA->ODR
		AND R2, R2,#~(0x01 << 5)	;similaire à GPIOA->ODR &= ~(1<<5)
		STRH R2,[R1,#OffsetOutput]	;Etat du port B (R5) stocké dans ODR
		BX LR						;Retour
	
	ENDP
		
;****************************************************************************
;R6 = NBLed
;R7 = *ValCourante
;R8 = ValCourante[NBLed]
;****************************************************************************
DriverGlobal	PROC
		BL Set_SCLK;
		MOV R6, #0;
WHILE_NBLED
		;Pour NbLed = 1 à 48
		LDR R7,=Barette1	;On recupère l'adresse de base
		LDRB R8,[R7,R6]		;R8 = ValCourante[...NBLed]
		
		LSL R8,#24			;ValCourante[NBLed]<<24
		
		ADD R6, R6, #1		;On incrémente R6
		CMP R6, #47			; SI R6==47 alors on arrête la boucle
		BNE WHILE_NBLED
	ENDP

;**************************************************************************
	END