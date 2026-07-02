.global soma, subtracao, multiplicacao, divisao
.global exponenciacao, combinacao, inverso, fatorial
.global arranjo, logaritmo, quadrada, proximo_primo
.global print_int, print_float, read_float, read_operador, ler_linha, print_newline

.data
    mult_dec:   .double 10000.0

.text
#===========
#Soma
#===========

soma:
    push %rbp
    movq %rsp, %rbp

    fadd %st(1), %st(0)
    fstl resultado
    movsd resultado, %xmm0

	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Subtração
#===========

subtracao:
	push %rbp
	movq %rsp, %rbp

	fsubr %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Divisão
#===========


divisao:
	push %rbp
	movq %rsp, %rbp

	fdivr %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Multiplicação
#===========

multiplicacao:
	push %rbp
	movq %rsp, %rbp

	fmul %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Exponenciação
#===========

exponenciacao:
    push %rbp
    movq %rsp, %rbp

    fyl2x                   # %st(0) = y * log2(x)

    fld %st(0)              # Duplica o resultado no topo
    frndint                 # Arredonda %st(0) para o inteiro mais próximo
    fsubr %st, %st(1)       # Subtrai o inteiro do original e obtêm a parte fracionária
    fxch %st(1)             # Troca as posições

    f2xm1                   # Calcula 2^(frac) - 1
    fld1                    # Carrega o número 1.0 em %st(0)
    faddp %st, %st(1)       # Soma 1.0 com (2^(frac) - 1)

    fscale                  # %st(0) = (2^frac) * (2^int)

    fstp %st(1)             # Remove a parte inteira (%st(1)) do topo da pilha

    fstl resultado
    movsd resultado, %xmm0

    movq %rbp, %rsp
    pop %rbp
    ret



#===========
#Combinação
#===========

combinacao:
	push %rbp
	movq %rsp, %rbp
	push %rbx
	push %rcx
	push %r8

	movq b, %r8
	movq %r8, f
	call fatorial
	movq %rax, %rbx

	call arranjo
	movq $0, %rdx
	divq %rbx

	pop %r8
	pop %rcx
	pop %rbx
	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Arranjo
#===========

arranjo:
	push %rbp
	movq %rsp, %rbp
	push %rbx
	push %r8

	movq a, %rax
	subq b, %rax
	movq %rax, f
	call fatorial
	movq %rax, %rbx

	movq a, %r8
	movq %r8, f
	call fatorial

	movq $0, %rdx
	divq %rbx

	pop %r8
	pop %rbx
	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Fatorial
#===========


fatorial:
	push %rbp
	movq %rsp, %rbp
	push %rcx

	movq $1, %rax
	movq f, %rcx

	loop_fat:
		cmpq $0, %rcx
		jle fim_loop_fat

		imulq %rcx
		decq %rcx

		jmp loop_fat

	fim_loop_fat:
		pop %rcx
		movq %rbp, %rsp
		pop %rbp
		ret



#===========
#Inverso
#===========

inverso:
	push %rbp
	movq %rsp, %rbp

	fld1
	fxch %st(1)
	call divisao

	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Quadrada
#===========

quadrada:
	push %rbp
	movq %rsp, %rbp

	fsqrt
	fstl resultado
	movsd resultado, %xmm0

	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Logaritmo
#===========

logaritmo:
	push %rbp
	movq %rsp, %rbp

	fld1
	fxch
	fyl2x

	fxch

	fld1
	fxch
	fyl2x

	fxch
	call divisao
	movq %rbp, %rsp
	pop %rbp
	ret



#===========
#Próximo Primo
#===========

proximo_primo:
	push %rbp
	movq %rsp, %rbp
    push %rcx

    loop_busca_primo:
        addq $1, %r8

        cmpq $2, %r8
        jl eh_menor_2
        je fim_proximoprimo

        movq %r8, %rax
        xor %rdx, %rdx
        movq $2, %rcx
        divq %rcx
        cmpq $0, %rdx
        je loop_busca_primo

        movq $3, %rcx

        loop_verifica_impares:
            movq %rcx, %rax
            imulq %rcx, %rax
            cmpq %r8, %rax
            jg fim_proximoprimo

            movq %r8, %rax
            xor %rdx, %rdx
            divq %rcx
            cmpq $0, %rdx
            je loop_busca_primo

            addq $2, %rcx
            jmp loop_verifica_impares

    eh_menor_2:
        movq $2, %r8

    fim_proximoprimo:
        movq %r8, %rax

		pop %rcx
		movq %rbp, %rsp
		pop %rbp
		ret



#===========
#Print int
#===========

print_int:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %r8

    mov $buffer_io, %rsi
    add $31, %rsi          # Aponta para o fim do buffer
    # movb $'\n', (%rsi)   # Adiciona quebra de linha no final
    mov $10, %rbx          # Divisor base 10
    mov $0, %rcx           # Contador de caracteres (já temos o \n)

    # checar se o número é negativo
    mov $0, %r8            # %r8 = 0 assume que é positivo
    cmp $0, %rax
    jge loop_print_int

    mov $1, %r8            # %r8 = 1, marca que é negativo
    neg %rax               # Inverte o sinal matematicamente (ex: -10 vira 10)

    loop_print_int:
        xor %rdx, %rdx         # Zera o resto para a divisão
        div %rbx               # %rax / 10. Quociente em %rax, Resto em %rdx
        add $'0', %dl          # Converte o resto (dígito) para ASCII (usamos %dl porque é o byte inferior do %rdx)
        dec %rsi               # Decrementa o ponteiro do buffer em uma posição
        movb %dl, (%rsi)       # Salva o caractere
        inc %rcx               # Incrementa contador de tamanho
        test %rax, %rax        # Verifica se o quociente é 0
        jnz loop_print_int

        # adiciona o sinal negativo se a flag %r8 for 1
        cmp $1, %r8
        jne print_int_syscall
        dec %rsi
        movb $'-', (%rsi)
        inc %rcx

    print_int_syscall:
        # Configuração para sys_write
        # %rsi já está apontando para o inicio da nossa string
        mov $1, %rax           # syscall syscall_write
        mov $1, %rdi           # file descriptor 1 (stdout)
        mov %rcx, %rdx         # tamanho da string a ser impressa
        syscall

        pop %r8
        pop %rdi
        pop %rsi
        pop %rdx
        pop %rcx
        pop %rbx
        pop %rbp
        ret


#===========
#Print float
#===========

print_menos:
    push %rbp
    mov %rsp, %rbp
    push %rax
    push %rdi
    push %rsi
    push %rdx

    mov $buffer_io, %rsi
    movb $'-', (%rsi)

    mov $1, %rax
    mov $1, %rdi
    mov $1, %rdx
    syscall

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax
    pop %rbp
    ret

print_ponto:
    push %rbp
    mov %rsp, %rbp
    push %rdx
    push %rsi
    push %rdi

    mov $buffer_io, %rsi
    movb $'.', (%rsi)
    mov $1, %rax           # syscall syscall_write
    mov $1, %rdi           # file descriptor 1 (stdout)
    mov $1, %rdx           # tamanho da string a ser impressa
    syscall

    pop %rdi
    pop %rsi
    pop %rdx
    pop %rbp
    ret

print_fracao:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %rcx
    push %rdx
    push %rsi
    push %rdi

    mov $buffer_io, %rsi
    add $31, %rsi          # Aponta para o fim do buffer


    mov $10, %rbx          # Divisor base 10
    mov $4, %rcx           # Contador: Forçar EXATAMENTE 4 casas decimais

    loop_fracao:
        xor %rdx, %rdx         # Zera resto
        div %rbx               # Divide %rax por 10
        add $'0', %dl          # Converte o resto em caractere
        dec %rsi               # Anda para trás no buffer
        movb %dl, (%rsi)       # Salva o caractere
        dec %rcx               # Diminui o contador
        jnz loop_fracao        # Continua até fazer as 4 casas (mesmo se %rax já for 0)

        # Imprime os 4 dígitos
        mov $1, %rax
        mov $1, %rdi
        mov $4, %rdx
        syscall

        pop %rdi
        pop %rsi
        pop %rdx
        pop %rcx
        pop %rbx
        pop %rbp
        ret

# Printa até 4 casas decimais, alterar mult_dec para mais ou menos casas
print_float:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp

    # zerar a memória local para evitar lixo
    movq $0, -16(%rbp)
    movq $0, -8(%rbp)

    movsd %xmm0, -8(%rbp)
    fldl -8(%rbp)


    # testa o bit de sinal do float.
    btq $63, -8(%rbp)
    jnc float_positivo     # se o bit for 0 o número é positivo e salta

    call print_menos

    fabs                   # força o número no FPU a ficar positivo

    # atualiza a memória com a versão positiva
    fstpl -8(%rbp)
    fldl -8(%rbp)

    float_positivo:
        # Extrai e imprime a parte inteira
        fisttpq -16(%rbp)
        movq -16(%rbp), %rax
        call print_int

        # Imprime o ponto
        call print_ponto

        # Calcula a parte fracionária
        fldl -8(%rbp)
        fildq -16(%rbp)
        fsubrp %st(0), %st(1)   # Faz o float - parte inteira = parte fracionaria

        fmull mult_dec
        fisttpq -16(%rbp)
        movq -16(%rbp), %rax

        # Imprime a fração e finaliza
        call print_fracao

        add $16, %rsp
        pop %rbp
        ret



#================
#Print nova linha
#================

print_newline:
    push %rbp
    mov %rsp, %rbp
    push %rax
    push %rdi
    push %rsi
    push %rdx

    mov $buffer_io, %rsi
    movb $'\n', (%rsi)

    mov $1, %rax
    mov $1, %rdi
    mov $1, %rdx
    syscall

    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax
    pop %rbp
    ret



#===========
# Ler Linha
#===========
ler_linha:
    push %rbp
    mov %rsp, %rbp

    mov $0, %rax
    mov $0, %rdi
    mov $buffer_io, %rsi
    mov $32, %rdx
    syscall

    movq $buffer_io, ponteiro  # Coloca o ponteiro apontando para a 1ª letra do buffer

    pop %rbp
    ret



#===========
#Read float
#===========

read_float:
    push %rbp
    mov %rsp, %rbp

    # -8(%rbp)  = Flag de Negativo
    # -16(%rbp) = Parte Inteira
    # -24(%rbp) = Parte Fracionaria
    # -32(%rbp) = Divisor
    sub $32, %rsp

    push %rax
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %r8
    push %r9
    movq ponteiro, %rsi

    xor %rax, %rax             # %rax vai acumular os inteiros
    xor %rcx, %rcx             # %rcx vai ler os caracteres
    mov $10, %r8               # Multiplicador base 10
    movq $0, -8(%rbp)          # Zera a flag de negativo

    pula_espacos_float:
        movb (%rsi), %cl
        cmp $' ', %cl
        jne verifica_sinal
        inc %rsi
        jmp pula_espacos_float

    verifica_sinal:
        movb (%rsi), %cl
        cmp $'-', %cl
        jne loop_parte_inteira
        movq $1, -8(%rbp)          # Ativa flag de negativo
        inc %rsi                   # Pula o caractere '-'

    loop_parte_inteira:
        xor %rcx, %rcx
        movb (%rsi), %cl
        cmp $'.', %cl               # Se achou ponto, vai pra fração
        je prepara_fracao

        # Testa se o caracter está entre '0' e '9'
        cmp $'0', %cl
        jl fim_apenas_inteiro
        cmp $'9', %cl
        jg fim_apenas_inteiro

        sub $'0', %cl              # Converte ASCII '5' para número 5
        mul %r8                    # Multiplica acumulador por 10
        add %rcx, %rax             # Soma o novo dígito
        inc %rsi
        jmp loop_parte_inteira

    prepara_fracao:
        inc %rsi                   # Pula o '.'
        movq %rax, -16(%rbp)       # Salva a parte inteira na RAM
        xor %rax, %rax             # Zera o acumulador para a fração
        mov $1, %r9                # %r9 será o divisor

    loop_parte_fracionaria:
        xor %rcx, %rcx
        movb (%rsi), %cl
        cmp $'0', %cl
        jl monta_float_final
        cmp $'9', %cl
        jg monta_float_final

        sub $'0', %cl
        mul %r8                    # fração * 10
        add %rcx, %rax

        # Multiplica o divisor por 10 também
        push %rax
        mov %r9, %rax
        mul %r8
        mov %rax, %r9
        pop %rax

        inc %rsi
        jmp loop_parte_fracionaria

    monta_float_final:
        movq %rax, -24(%rbp)       # Salva a parte fracionária
        movq %r9, -32(%rbp)        # Salva o divisor

        fildq -16(%rbp)            # PUSH Int
        fildq -24(%rbp)            # PUSH Frac (Fica em st(0), int em st(1))
        fildq -32(%rbp)            # PUSH Divisor (Fica em st(0), frac em st(1))

        fdivrp %st(0), %st(1)      # st(1) = st(1) / st(0) e dá POP (frac / divisor)
        faddp %st(0), %st(1)       # Soma a fração calculada com a parte inteira
        jmp checa_sinal

    fim_apenas_inteiro:
        movq %rax, -16(%rbp)
        fildq -16(%rbp)            # Joga o inteiro na FPU

    checa_sinal:
        cmpq $1, -8(%rbp)          # é negativo?
        jne fim_read_float
        fchs                       # Inverte o sinal na FPU (vira negativo)

    fim_read_float:
        movq %rsi, ponteiro
        pop %r9
        pop %r8
        pop %rdi
        pop %rsi
        pop %rdx
        pop %rcx
        pop %rax
        add $32, %rsp
        pop %rbp
        ret



#=============
#Read operador
#=============

read_operador:
    push %rbp
    mov %rsp, %rbp
    push %rax
    push %rsi

    movq ponteiro, %rsi

    loop_busca_op:
        movb (%rsi), %al
        cmp $'\n', %al             # Ignora quebras de linha
        je pular_op
        cmp $' ', %al              # Ignora espaços
        je pular_op
        cmp $0, %al
        je pular_op

        # Achou o operador, salva na memória global
        movb %al, operacao
        inc %rsi
        movq %rsi, ponteiro
        jmp fim_read_op

    pular_op:
        inc %rsi
        jmp loop_busca_op

    fim_read_op:
        pop %rsi
        pop %rax
        pop %rbp
        ret
