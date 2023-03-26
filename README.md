# But du projet
Le but sera de faire fonctionner diverses LEDS à l'aide d'un STM32 et tout cela en langage Assembler.
# Fonctionnalitées
## Fonctions
|Nom|Argument(s)|Retour|Description|
|---|---|---|---|
|Set_X|**1** - R0 : PINAX||Pour un output donné, met à 1 ce dernier.|
|Reset_X|**1** - R0 : PINAX||Pour un output donné, force à 0 ce dernier.|
|DriverGlobal|||Pour une Barette de LED donnée, envoie les signaux demandés|

---
Chaque fonction prendra des arguments de R0 à R3 (avec R3 étant une référence au tas si le besoin d'argument est supérieur à 3). Le renvoi se fait sur R0.

## Main

Le main pour l'instant ne fait qu'appeler DriverGlobal.

## Variables globales

- SCLK *(5)* et SIN1 *(7)* sont des variables globales permettant avec la fonction Set/Reset_X de définir l'état de sortie d'une pin X. 
- PF *(1<<31)* est le poids fort, comme il n'est pas possible d'utiliser l'instruction **MOV** avec des nombres supérieurs à 1 octet, il est préférable d'utiliser une variable globale avec cette valeur.
- Barette1 (16\*3 valeurs), tableau contenant pour chaque LED *(16)*, le niveau RVB.

## Chronogramme

Voici le premier chronogramme observable avec les états de SCLK et SIN1. Aucun test matériel n'a encore été réalisé :
![SIN SCLK Graph](assets/graph_complete.png)

# Réaliser un code assembler à partir de C
Comme vous le savez le code en langage C peut être compilé puis récupéré en assembler. C'est justement ici une solution que j'ai trouvé pour mieux comprendre différents principes, ou si certaines instructions ne me paraissent pas clair.
Bien évidemment le but du projet n'est pas de recopier bêtement du code que le compilateur peut réaliser, mais de comprendre et de voir comment faire différents algorithmes en Assembler.

La première chose est d'installer le package suivant sur une machine Linux :
```bash
sudo dnf install arm-none-eabi-gcc
```
*J'utilise Fedora donc mon package manager est dnf, mais cela fonctionne avec apt ou pacman*

Ensuite il suffit de créer un programme en C, voici en un par exemple qui m'a aidé à comprendre l'inversion des bits, ou comment le C récupère les arguments d'une fonction :
```c
void set(int pin);
int invert(int x);

void * gpioA = (void *)0x40010800;

int main(void)
{
	set(5);
	invert(0x20);
	return 0;
}

void set(int pin){ *((short *)(globalPtr+0xc)) |= (0x01 << pin) }
int invert(int x){ return ~x }
```

Ensuite je lance la commande suivante pour compiler le tout dans un niveau d'optimisation choisi :
```shell
arm-bibe-eabi-gcc -OX -c test.c -o test.o
```

|Argument|Type d'optimisation du compilateur|
|---|---|
|-O0|Zero|
|-O1|Normale|
|-O2|Maximale|

Et enfin pour voir le résultat en assembler dans la le terminal :
```shell
arm-none-eabi-objdump -D test.o
```

Nous obtenons le résultat suivant :

```assembly
00000000 <invert>:
   0:e1e00000 mvn   r0, r0
   4:e12fff1e bx    lr

00000008 <set>:
   8:e3a01001 mov   r1, #1
   c:e59f3010 ldr   r3, [pc, #16]@ 24 <add+0x1c>
  10:e5932000 ldr   r2, [r3]
  14:e1d230b5 ldrh  r3, [r2, #5]
  18:e1c33011 bic   r3, r3, r1, lsl r0
  1c:e1c230b5 strh  r3, [r2, #5]
  20:e12fff1e bx    lr
  24:00000000 andeq r0, r0, r0
```