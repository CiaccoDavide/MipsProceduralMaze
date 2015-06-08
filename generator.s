
.data
labirinto: .byte 	35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,0

default: .byte 	66,67,35,66,35,66,35,66,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,123,0

saluto: .asciiz "\nProgramma terminato!\nCreato da Ciacco Davide 794163"



.text
main:

move $a0, $t0

li $v0, 4				# selezione di print_string
la $a0, labirinto		# $a0 = indirizzo di string2
syscall					# lancio print_string

j reset

#--------------------------------#

reset:

la $s1, labirinto
la $s2, default

lb $t0, ($s2)	#prende un char dalla stringa di default
beq $t0, 35 termina
sb $t0, ($s1)	#salva il char nel buffer(?)

addi $s2, $s2, 1 	#incremento i puntatori
addi $s1, $s1, 1

j reset 		#loop




termina:
li $v0, 4		#stampo l'autore del programma
la $a0, saluto
syscall

li $v0, 10     	#termino il programma tramite syscall apposita
syscall

