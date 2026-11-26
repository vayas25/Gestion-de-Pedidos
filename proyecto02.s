# proyecto02.s - Version 1.01: documentacion de formatos MIPS y datapath
# Cambio realizado: solo se agregan los comentarios.
#
# Objetivo: identificar formatos R, I y J, registros usados, efecto en el estado
# del procesador, componentes del datapath y dependencias relevantes.
#
# Formatos MIPS:
# R: opcode(6) | rs(5) | rt(5) | rd(5) | shamt(5) | funct(6)
# I: opcode(6) | rs(5) | rt(5) | immediate(16)
# J: opcode(6) | address(26)
#
# Instrucciones seleccionadas:
#
# R1: add $t2, $t1, $t1
#   Formato R. opcode=0, rs=$t1(9), rt=$t1(9), rd=$t2(10), shamt=0, funct=0x20.
#   Efecto: $t2 = $t1 + $t1. Lee banco de registros, usa ALU y escribe $t2.
#   No accede a memoria de datos. El PC avanza normalmente a PC+4.
#
# R2: sub $t3, $t2, $t1
#   Formato R. opcode=0, rs=$t2(10), rt=$t1(9), rd=$t3(11), shamt=0, funct=0x22.
#   Efecto: $t3 = $t2 - $t1. Lee rs y rt, usa ALU y escribe rd. PC avanza a PC+4.
#
# I1: lw $t1, 0($s3)
#   Formato I. opcode=0x23(35), rs=$s3(19), rt=$t1(9), immediate=0.
#   Efecto: $t1 = Mem[$s3 + 0]. La ALU calcula la direccion, se lee memoria de datos
#   y se escribe el dato en $t1. El PC avanza a PC+4.
#
# I2: addi $t1, $zero, 8
#   Formato I. opcode=0x08(8), rs=$zero(0), rt=$t1(9), immediate=8.
#   Efecto: $t1 = $zero + 8. Usa la ALU con el inmediato extendido con signo y
#   escribe el resultado en $t1. PC avanza a PC+4.
#
# I3: beq $t9, $zero, CERO
#   Formato I. opcode=0x04(4), rs=$t9(25), rt=$zero(0), immediate=offset a CERO.
#   Efecto: si $t9 == $zero, PC = PC+4+(imm<<2); si no, PC = PC+4.
#   Es un salto condicional y afecta el flujo de control.
#
# I4: sw $t0, 0($s5)
#   Formato I. opcode=0x2B(43), rs=$s5(21), rt=$t0(8), immediate=0.
#   Efecto: Mem[$s5 + 0] = $t0. La ALU calcula la direccion y se escribe en
#   memoria de datos. PC avanza a PC+4.
#
# J1: j FIN
#   Formato J. opcode=0x02(2), address=26 bits (indice de destino).
#   Efecto: PC = (PC+4)[31:28] || (address<<2). No usa registros directamente;
#   cambia el PC al destino del salto.
#
# Datapath:
# PC: registro con la direccion de la instruccion actual. Se actualiza a PC+4
#     o al destino de un salto/beq.
# Memoria de instrucciones: entrega la instruccion apuntada por el PC.
# Banco de registros: 32 registros; permite dos lecturas (rs y rt) y una escritura
#     (rd en tipo R, rt en lw/addi). $zero siempre vale 0.
# ALU: realiza suma, resta, calculo de direccion y comparacion. Recibe operandos
#     desde registros o desde el inmediato, segun la senal ALUSrc.
# Memoria de datos: usada por lw para leer y por sw para escribir.
# Multiplexores: seleccionan fuente de la ALU, dato de escritura, direccion del PC,
#     entre otros.
# Unidad de control: decodifica opcode/funct y genera senales como RegWrite,
#     MemRead, MemWrite, ALUSrc, PCSrc, etc.
#
# Dependencias relevantes:
# - RAW tipo load-use: lw $t1,0($s3) -> add $t2,$t1,$t1.
# - RAW: add $t2... -> sub $t3,$t2,$t1; add $t4,$t1,$t2;
#        add $t5,$t2,$t3; add $t6,$t2,$t3; sub $t7,$t2,$t3.
# - addi $t1,$zero,8 sobreescribe $t1 despues de sus usos; luego
#   sub $t5,$t2,$t1 depende del nuevo valor de $t1.
# - add $t5,$t2,$t3 y luego sub $t5,$t2,$t1: hay dependencia por $t5
#   (escritura/lectura).
# - beq depende de $t9; sw depende de $t0.
# - beq y j generan hazards de control.

.data
productos:    .word 18
              .space 16
pedidos:      .word 30
              .space 16
estado:       .word 0

.text
.globl main

main:
    la   $s3, productos
    la   $s4, pedidos
    la   $s5, estado

    lw   $t1, 0($s3)
    add  $t2, $t1, $t1
    sub  $t3, $t2, $t1

    add  $t4, $t1, $t2
    addi $t1, $zero, 8

    add  $t5, $t2, $t3
    sub  $t5, $t2, $t1

    add  $t6, $t2, $t3
    sub  $t7, $t2, $t3

    lw   $t8, 0($s4)
    add  $t9, $t6, $t7

    beq  $t9, $zero, CERO
    addi $t0, $zero, 202

    sw   $t0, 0($s5)
    j    FIN

CERO:
    addi $t0, $zero, 0
    sw   $t0, 0($s5)

FIN:
    li   $v0, 10
    syscall
