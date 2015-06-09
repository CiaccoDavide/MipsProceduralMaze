
.data
labirinto: .byte 	35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,0

default: .byte 	35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,35,32,35,32,35,32,35,32,35,10,35,35,35,35,35,35,35,35,35,10,0

saluto: .asciiz "\nProgramma terminato!\nCreato da Ciacco Davide 794163"
string1: .asciiz "\nInserire il seed: "



.text
main:

#li $v0, 4				# selezione di print_string
#la $a0, labirinto		# $a0 = indirizzo di string2
#syscall					# lancio print_string

la $s1, labirinto
la $s2, default

#j reset

#--------------------------------#
#la $s1, labirinto
#la $s2, default

#lb $t0, 0($s2)	#prende un char dalla stringa di default

#addi $t0, $zero, 65
#li $t0, 65		#carico il carattere A di partenza in $t0
#sb $t0, 40+11($s1)	#salva il char nel buffer(?)





jal rand 			#GENERA la X
add $t3, $zero, $t2
jal rand 			#GENERA la Y
add $t4, $zero, $t2



#DETERMINO L'OFFSET SULLA STRINGA DEL LABIRINTO e lo salvo in $t2
mul $t3, $t3, 2		#(2*x)
mul $t4, $t4, 20	#(20*y)
add $t2, $t3, $t4	#(2*x)+(20*y)
addi $t2, $t2, 11	#11+((2*x)+(20*y))

#POSIZIONO IL PUNTO DI PARTENZA
li $t0, 65		#carico il carattere A di partenza in $t0
add $s1, $s1, $t2	#sposto il puntatore sulla casella
sb $t0, ($s1)	#salva il char nel buffer(?)








termina:	#da migliorare con menu per la scelta: 0:termina 1:reset e restart!

li $v0, 4				# selezione di print_string
la $a0, labirinto		# $a0 = indirizzo di string2
syscall					# lancio print_string

li $v0, 4		#stampo l'autore del programma
la $a0, saluto
syscall


j pre_reset	#ORA CONTINUA ALL'INFINITO CHIEDENDO SEMPRE NUOVI SEEDS


li $v0, 10     	#termino il programma tramite syscall apposita
syscall



pre_reset:
la $s1, labirinto
la $s2, default

reset: #reset funzionante!

lb $t0, ($s2)	#prende un char dalla stringa di default
sb $t0, ($s1)	#salva il char nel buffer(?)

beq $t0, 0 main

addi $s2, $s2, 1 	#incremento i puntatori
addi $s1, $s1, 1

j reset 		#loop













rand:
li $v0, 4				# selezione di print_string (codice = 4)
la $a0, string1			# $a0 = indirizzo di string1
syscall					# lancio print_string

li $v0, 5				# Selezione read_int (codice = 5)
syscall					
add $t0, $zero, $v0		# memorizzo il seed iniziale in $t0

#GENERA la X
srl $t1, $t0, 2			#shift a destra di 2
xor $t0, $t0, $t1		#xor tra seed e shiftato
sll $t1, $t0, 6			#shift a sinistra di 6
xor $t0, $t0, $t1		#xor tra seed e shiftato

#per fare il modulo basta dividere per 4 e prendere il resto della divisione!
div $t2, $t0, 4
mfhi $t2
abs $t2 $t2  #l'abs potrebbe essere semplice usando una xor?

jr $ra