		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc
	include LUMIERES.inc

;************************************************************************
; 					IMPORT/EXPORT Syst�me
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de proc�dure           

	IMPORT Init_Cible
	IMPORT Run_Timer3
		
	IMPORT Eteint_LED
	IMPORT Allume_LED
	IMPORT Inverse_LED
	
	IMPORT Set_SCLK
	IMPORT Reset_SCLK
	IMPORT DriverGlobal
	IMPORT DriverReg
	IMPORT Tempo

	EXPORT main
	
;***************VARIABLES*******************************************************
	AREA  mesdonnees, data, readwrite
;*******************************************************************************
		
M		EQU 20

;***************CODE************************************************************
   	AREA  moncode, code, readonly
; 	Proc�dure principale et point d'entr�e du projet
;*******************************************************************************	
main   PROC 
;*******************************************************************************
		BL Run_Timer3			;Allumage du Timer 3
		MOV R0,#1
		BL Init_Cible;
;*******************************************************************************
; ETAPE 2
;*******************************************************************************
		MOV R7,#0
Etape2								;for(int=0;i<M;i++)
		LDR R0, =Barette3			;Adresse Jeu de led 1 : Argument
		BL DriverReg				;*******************
		MOV R0, #500					;Argument : 500ms
		BL Tempo;					:Tempo(10)
		LDR R0, =Barette2			;Adresse Jeu de led 2 : Argument
		BL DriverReg				;*******************
		MOV R0, #500					;Argument : 500ms
		BL Tempo;					:Tempo(10)
		
		LDR R6,=GPIOBASEA			;On r�cup l'adresse	du GPIOA
		LDR R6,[R6,#OffsetInput]	;On lit le GPIOA_IDR
		AND R6, R6, #(0x01<<8)		;On masque pour n'avoir que le 9�me bit (Capteur)
		CMP R6, #(0x01<<8)			;On v�rifie que ce dernier bit est bien � 1.
		BNE TheEnd					;if capteur = true -> on sort de la boucle
		ADD R7,R7,#1				;i++
		CMP R7, #M					;i==M ?
		BNE Etape2					;if i!=10 -> on continue la boucle (Au final : R7 == M || R6)
;*******************************************************************************
; ETAPE 1
;*******************************************************************************
;		MOV R0,#0;
;		MOV R1,#0;
;		MOV R3,#0;
;Boucle
;		LDR R12,=GPIOBASEA			;On r�cup l'adresse	du GPIOA		
;		LDR R0,[R12,#OffsetInput]	;On charge sa valeur avec l'OffsetInput
;		AND R0, R0, #(0x01 << 8)	;R0 est masqu� pour n'avoir que le bit de l'offset input
;		CMP R0, #(0x01 << 8)		;On compare R0 doit etre egal � 1 pour le front montant
;		BNE Is_detect				;On allume
;		MOV R1,R0					;R1 poss�de la valeur de R0 avant
;		BL Boucle					;Sinon on boucle
;				
;Is_detect
;		CMP R1, #(0x01 << 8)		;R1 doit etre egal � 0 pour le front montant
;		BNE Boucle
;
;T_Oui
;		BL Inverse_LED				;On inverse le status de la led grace a R3
;		B Boucle
;		
;*******************************************************************************
TheEnd
		B .			 ; boucle inifinie terminale...
		ENDP

	END

;*******************************************************************************
