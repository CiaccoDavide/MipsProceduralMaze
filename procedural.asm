main:

.data
string1: .asciiz "Inserire il seed: "	
string2: .asciiz "\n Numero random: "

.text
li $v0, 4				# selezione di print_string (codice = 4)
la $a0, string1			# $a0 = indirizzo di string1
syscall					# lancio print_string

li $v0, 5				# Selezione read_int (codice = 5)
syscall					
add $t0, $zero, $v0		# memorizzo il seed iniziale in $t0


#generazione
li $v0, 4				#stampo stringa
la $a0, string2			
syscall

srl $t1, $t0, 2			#shift a destra di 2
xor $t0, $t0, $t1		#xor tra seed e shiftato
sll $t1, $t0, 6			#shift a sinistra di 6
xor $t0, $t0, $t1		#xor tra seed e shiftato

#per fare il modulo basta dividere per 4 e prendere il resto della divisione!
div $t3, $t0, 4
mfhi $t3
abs $t3 $t3

add $a0, $zero, $t3

li $v0, 1				# selezione di print_int (codice = 1)
syscall












li $v0, 10				# selezione di exit (codice = 10)
syscall					
