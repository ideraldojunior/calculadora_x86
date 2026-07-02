.global main, a, b, f, resultado
.data
	entrada:	    .asciz	"\nInsira a operação ou tecle (s) para sair:\n"

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


.bss
	.comm	operacao, 1
	.comm  resultado, 8
	.comm	a, 8
	.comm	b, 8
	.comm	f, 8

.text

main:
	call controlador

	movq $60, %rax
	movq $0, %rdi
	syscall

controlador:
	finit
	call mensagem
	call primeiro_operando
	call operador

	cmpb $'s', operacao
	je sair

	cmpb $'!', operacao
	je trata_fatorial

	cmpb $'i', operacao
	je trata_inverso

	cmpb $'r', operacao
	je trata_quadrada

	cmpb $'p', operacao
	je trata_proximo_primo

	call segundo_operando

	cmpb $'+', operacao
	je trata_soma

	cmpb $'-', operacao
	je trata_subtracao

	cmpb $'*', operacao
	je trata_multiplicacao

	cmpb $'/', operacao
	je trata_divisao

	cmpb $'^', operacao
	je trata_exponenciacao

	cmpb $'c', operacao
	je trata_combinacao

	cmpb $'a', operacao
	je trata_arranjo

	cmpb $'l', operacao
	je trata_logaritmo

	jmp controlador

	trata_fatorial:
		fldz
		fcomip %st(1), %st(0)
		ja chama_erro

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, f

		call fatorial
		call imprime_resultado_int
		jmp controlador


	trata_inverso:
		fldz
		fcomip %st(1), %st(0)
		je chama_erro_inverso

		call inverso
		call imprime_resultado_float
		jmp controlador

		chama_erro_inverso:
			call erro_inverso
			jmp controlador



	trata_quadrada:
		fldz
		fcomip %st(1), %st(0)
		jae chama_erro_raiz

		call quadrada
		call imprime_resultado_float
		jmp controlador

		chama_erro_raiz:
			call erro_raiz
			jmp controlador



	trata_proximo_primo:
    	fldz
		fcomip %st(1), %st(0)
		ja chama_erro

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8

		call proximo_primo
		call imprime_resultado_int
		jmp controlador



	trata_soma:
		call soma
		call imprime_resultado_float
		jmp controlador



	trata_subtracao:
		call subtracao
		call imprime_resultado_float
		jmp controlador



	trata_multiplicacao:
		call multiplicacao
		call imprime_resultado_float
		jmp controlador



	trata_divisao:
		fldz
		fcomip %st(1), %st(0)
		je chama_erro_divisao

		call divisao
		call imprime_resultado_float
		jmp controlador

		chama_erro_divisao:
			call erro_divisao_zero
			jmp controlador



	trata_exponenciacao:
        fldl b(%rip)                # Expoente
        fldl a(%rip)                # Base

        fldz                        # Puxa um 0
        fcomip %st(1), %st(0)       # Compara 0 com a base e dá pop
        jbe executa_exp             # Se a base >= 0 pode calcular

        fld1                        # Puxa um 1
        fcomip %st(2), %st(0)       # Compara 1 com o expoente e dá pop
        jbe executa_exp             # Se o expoente >= 1 pode calcular

        # Caso base < 0 e expoente < 1
        fstp %st(0)                 # limpa o topo da pilha
        fstp %st(0)                 # limpa o topo da pilha

        call erro_raiz
        jmp controlador

        executa_exp:
    		call exponenciacao
    		call imprime_resultado_float
    		jmp controlador



	trata_combinacao:
		fcomi %st(1), %st(0)
		ja chama_erro

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, a

		movsd b, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, b

		call combinacao
		call imprime_resultado_int
		jmp controlador



	trata_arranjo:
		fcomi %st(1), %st(0)
		ja chama_erro

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, a

		movsd b, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, b

		call arranjo
		call imprime_resultado_int
		jmp controlador



	trata_logaritmo:
		fldz
		fcomip %st(2), %st(0)
		jae chama_erro

		fld1
		fcomip %st(1), %st(0)
		je chama_erro

		fldz
		fcomip %st(1), %st(0)
		ja chama_erro

		call logaritmo
		call imprime_resultado_float
		jmp controlador


	chama_erro:
		call operacao_invalida
		jmp controlador

	sair:
		ret




#=========================
#INPUT
#=========================

mensagem:
    push %rbp
    movq %rsp, %rbp

	movq $entrada, %rdi
	movq $0, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret


primeiro_operando:
    push %rbp
    movq %rsp, %rbp

	movq $fmt3, %rdi
	movq $a, %rsi
	movq $0, %rax
	call scanf

	fldl a

	movq %rbp, %rsp
	pop %rbp
	ret


operador:
    push %rbp
    movq %rsp, %rbp

	movq $fmt2, %rdi
	movq $operacao, %rsi
	movq $0, %rax
	call scanf

	movq %rbp, %rsp
	pop %rbp
	ret


segundo_operando:
    push %rbp
    movq %rsp, %rbp

	movq $fmt3, %rdi
	movq $b, %rsi
	movq $0, %rax
	call scanf

	fldl b

	movq %rbp, %rsp
	pop %rbp
	ret


#=========================
#OUTPUT
#=========================


erro_divisao_zero:
    push %rbp
    movq %rsp, %rbp

	movq $err_div, %rdi
	movq $0, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret


erro_raiz:
    push %rbp
    movq %rsp, %rbp

	movq $err_raiz, %rdi
	movq $0, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret


erro_inverso:
    push %rbp
    movq %rsp, %rbp

	movq $err_inv, %rdi
	movq $0, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret


operacao_invalida:
    push %rbp
    movq %rsp, %rbp

	movq $err, %rdi
	movq $0, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret


imprime_resultado_float:
    push %rbp
    movq %rsp, %rbp

	movq $saida_float, %rdi
	movq $1, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret


imprime_resultado_int:
    push %rbp
    movq %rsp, %rbp

	movq $saida_int, %rdi
	movq %rax, %rsi
	movq $0, %rax
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret
