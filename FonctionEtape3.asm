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
	EXPORT Init_TVI
	EXPORT Timer1_IRQHandler
	EXPORT setIRQFunction
		
	IMPORT DriverReg
	IMPORT Tempo

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 
	include LUMIERES.inc

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

MAX_Interrupt			EQU 256
TVI_Flash				EQU 0x0

;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************
		
Timer1_IRQHandler PROC
		PUSH {LR}
		LDR R2,=SwitchState			;On lit l'adresse de switch state
		LDRB R3,[R2]				;On charge la donn�e
		CMP R3, #0					;if(Switchstate == 0)
		BEQ SETBarrette1			; {DriverReg(Barette1)}
SETBarrette2
		LDR R0, =Barette2			;else {DriverReg(Barette2)} Adresse Jeu de led 2 : Argument
		MOV R3, #0;
		STRB R3,[R2]				;On remet la donn�e
		B GoToDriverReg
SETBarrette1
		LDR R0, =Barette1			;Adresse Jeu de led 1 : Argument
		MOV R3, #1;
		STRB R3,[R2]				;On remet la donn�e
GoToDriverReg
		BL DriverReg				;DriverReg(Barette3)
		LDR R0,=TIM1_SR
		LDR R1, [R0]
		AND R1, #~(1<<1)
		STR R1, [R0]
		POP {LR}
		BX LR
	ENDP

;On copie toute la TVI dans la RAM (0x2....)
;On modifie les interruptions Up et CC pour pointer sur nos fonctions rien qu'� nous
;On fait pointer � SCB_VTOR l'adresse de la TVI que nous avons copi�
Init_TVI PROC
		LDR R0,=TVI_Flash				;On Lit le premier TVI
		LDR R1,=TVI_Pile				;Nouvelle TVI
		MOV R2,#0						;i
for_tvi								;for(int i=0;i<MAX_Interrupt;i++)
		LDR R3,[R0]						;temp = TVI_Flash[i]
		STR R3, [R1]					;TVI_Pile[i] = temp
		ADD R1,R1,#4					;TVI_Pile++
		ADD R0,R0,#4					;TVI_Flash++
		ADD R2,R2,#1					;i++
		CMP R2,#MAX_Interrupt			;is i == MAX_Interrupt?
		BNE	for_tvi
scbvector_link
		LDR R1,=TVI_Pile				;On relit l'adresse de TVIPile
		LDR R0,=SCB_VTOR				;ON lit l'adresse de SCB_VTOR
		STR R1,[R0]						;On met l'adresse de TVI_Pile dans le SCB_VTOR
		BX LR
	ENDP

;*******************************************************************
;Arguments :
;R0 -> Interruption
;R1 -> Adresse de la fonction
;*******************************************************************
setIRQFunction PROC
		LDR R3,=TVI_Pile
		ADD R0,R0,R3
		STR R1, [R0]
		BX LR
	ENDP
	

;**************************************************************************
	END
