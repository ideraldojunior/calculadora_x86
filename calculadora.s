.global main
.data
	entrada:	    .asciz	"\nInsira a operação:\n"

	err:		    .asciz  "err: Operação invalida!\n"
	err_div:	    .asciz	"err: Divisão por zero!\n"
	err_raiz:	    .asciz  "err: Operando não pode ser negativo"
	err_inv:	    .asciz  "err: Operando não pode ser zero"

	continuar:      .asciz	"\nContinuar? (s) (n):"

	saida_int:		.asciz	"Resultado: %lld \n"
	saida_float:	.asciz	"Resultado: %lf \n"

	fmt1:		    .asciz	"%lld"
	fmt2:		    .asciz	" %c"
	fmt3:		    .asciz  "%lf"

	um_float:       .double 1.0
	zero_float:     .double 0.0

.bss
	.lcomm	operacao, 1
	.lcomm	a, 8
	.lcomm	b, 8
	.lcomm	f, 8
	.lcomm  resultado, 8
	.lcomm	cont, 1

.text

main:
	finit
	push %rbp

	#MENSAGEM
	movq $entrada, %rdi
	call printf

	#PRIMEIRO operando
	movq $fmt3, %rdi
	movq $a, %rsi
	call scanf

	fldl a #adiciona a na pilha

	#OPERACAO
	movq $fmt2, %rdi
	movq $operacao, %rsi
	call scanf

	jmp controlador

fim_programa:
	pop %rbp
	ret

#=========================
#CONTROLADOR
#Realiza a busca da operacao solicitada 
#=========================

controlador:

	tenta_fatorial:
		cmpb $'!', operacao
		jne tenta_inverso

		fldz
		fcomip %st(1), %st(0)
		ja operacao_invalida

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, f

		call fatorial
		jmp imprime_resultado_int



	tenta_inverso:
		cmpb $'i', operacao
		jne tenta_quadrada

		fldz
		fcomip %st(1), %st(0)
		je erro_inverso

		call inverso
		jmp imprime_resultado_float



	tenta_quadrada:
		cmpb $'r', operacao
		jne tenta_proximo_primo

		fldz
		fcomip %st(1), %st(0)
		jae erro_raiz

		call quadrada
		jmp imprime_resultado_float



	tenta_proximo_primo:
		cmpb $'p', operacao
		jne tenta_soma

		movsd a, %xmm0          # carrega o float
		cvttsd2si %xmm0, %r8    # converte para inteiro e coloca em %r8

		call proximoprimo
		jmp imprime_resultado_int



	tenta_soma:
		#SEGUNDO operando
		movq $fmt3, %rdi
		movq $b, %rsi
		call scanf

		fldl b

		cmpb $'+', operacao
		jne tenta_sub

		call soma
		jmp imprime_resultado_float



	tenta_sub:
		cmpb $'-', operacao
		jne tenta_multiplicacao

		call subtracao
		jmp imprime_resultado_float



	tenta_multiplicacao:
		cmpb $'*', operacao
		jne tenta_divisao

		call multiplicacao
		jmp imprime_resultado_float



	tenta_divisao:
		cmpb $'/', operacao
		jne tenta_exponenciacao

		fldz
		fcomip %st(1), %st(0)
		je erro_divisao_zero

		call divisao
		jmp imprime_resultado_float



	tenta_exponenciacao:
		cmpb $'^', operacao
		jne tenta_combinacao

		#PERGUNTAR SE É INTEIRO
		movsd b, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, b

		call exponenciacao
		jmp imprime_resultado_float



	tenta_combinacao:
		cmpb $'c', operacao
		jne tenta_arranjos

		fcomi %st(1), %st(0)
		ja operacao_invalida

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, a

		movsd b, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, b

		call combinacao
		jmp imprime_resultado_int



	tenta_arranjos:
		cmpb $'a', operacao
		jne tenta_logaritmo

		fcomi %st(1), %st(0)
		ja operacao_invalida

		movsd a, %xmm0    #converte a para inteiro
		cvttsd2si %xmm0, %r8
		movq %r8, a

		movsd b, %xmm0     #converte b para inteiro
		cvttsd2si %xmm0, %r8
		movq %r8, b

		call arranjo
		jmp imprime_resultado_int



	tenta_logaritmo:
		cmpb $'l', operacao
		jne operacao_invalida

		fldz
		fcomip %st(2), %st(0)
		jae operacao_invalida

		fld1
		fcomip %st(1), %st(0)
		je operacao_invalida

		fldz
		fcomip %st(1), %st(0)
		ja operacao_invalida

		call logaritmo
		jmp imprime_resultado_float




#=========================
#IMPRESSÕES DE ERRO
#=========================

erro_divisao_zero:
	movq $err_div, %rdi
	call printf
	jmp sair_programa

erro_raiz:
	movq $err_raiz, %rdi
	call printf
	jmp sair_programa

erro_inverso:
	movq $err_inv, %rdi
	call printf
	jmp sair_programa

operacao_invalida:
	movq $err, %rdi
	call printf
	jmp sair_programa




#=========================
#INPUT
#=========================

#===========
#Impressão de float
#===========

imprime_resultado_float:
	movq $saida_float, %rdi
	movq $1, %rax
	call printf
	jmp sair_programa



#===========
#Impressão de inteiro
#===========

imprime_resultado_int:
	movq $saida_int, %rdi
	movq %rax, %rsi
	call printf
	jmp sair_programa



#===========
#Input para finalizar programa
#===========

sair_programa:
	movq $continuar, %rdi
	call printf
	movq $fmt2, %rdi
	movq $cont, %rsi
	call scanf

	pop %rbp
	cmpb $'s', cont
	je main

	cmpb $'n', cont
	jne sair_programa




#=========================
#OPERAÇÕES
#=========================

#===========
#Soma
#===========

soma:
	push %rbp
	movq %rsp, %rbp

	fadd %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	jmp desempilha



#===========
#Subtração
#===========

subtracao:
	push %rbp
	movq %rsp, %rbp

	fsubr %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	jmp desempilha



#===========
#Divisão
#===========

divisao:
	push %rbp
	movq %rsp, %rbp

	fdivr %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	jmp desempilha



#===========
#Multiplicação
#===========

multiplicacao:
	push %rbp
	movq %rsp, %rbp

	fmul %st(1), %st(0)
	fstl resultado
	movsd resultado, %xmm0

	jmp desempilha



#===========
#Exponenciação
#===========

exponenciacao:
	push %rbp
	movq %rsp, %rbp
	push %rcx

	movq b, %rcx
	fstp %st(0) 
	fld1

	loop_exp:
		cmpq $0, %rcx
		jle fim_loop_exp

		call multiplicacao
		decq %rcx
		jmp loop_exp

	fim_loop_exp:
		fstl resultado
		movsd resultado, %xmm0

		pop %rcx
		jmp desempilha


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
	jmp desempilha



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
	jmp desempilha



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
		jmp desempilha



#===========
#Inverso
#===========

inverso:
	push %rbp
	movq %rsp, %rbp

	fld1
	fxch %st(1)
	call divisao

	jmp desempilha



#===========
#Quadrada
#===========

quadrada:
	push %rbp
	movq %rsp, %rbp

	fsqrt
	fstl resultado
	movsd resultado, %xmm0

	jmp desempilha



#===========
#Logaritmo
#===========

logaritmo:
	push %rbp
	movq %rsp, %rbp

	fld1
	fxch 				#troca st(1) com st(0)
	fyl2x 				#calcula logaritmo na base 2

	fxch

	fld1
	fxch
	fyl2x

	fxch
	call divisao
	jmp desempilha



#===========
#Próximo Primo
#===========

proximoprimo:
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
	jmp desempilha




#=========================
#Desempilha
#Obs: existe apenas para enxugar o código
#=========================

desempilha:
	movq %rbp, %rsp
	pop %rbp
	ret
