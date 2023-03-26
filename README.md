# But du projet
Le but sera de faire fonctionner diverses LEDS à l'aide d'un STM32 et tout cela en langage Assembler
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
   0:e1e00000 mvnr0, r0
   4:e12fff1e bxlr

00000008 <set>:
   8:e3a01001 movr1, #1
   c:e59f3010 ldrr3, [pc, #16]@ 24 <add+0x1c>
  10:e5932000 ldrr2, [r3]
  14:e1d230b5 ldrhr3, [r2, #5]
  18:e1c33011 bicr3, r3, r1, lsl r0
  1c:e1c230b5 strhr3, [r2, #5]
  20:e12fff1e bxlr
  24:00000000 andeqr0, r0, r0
```