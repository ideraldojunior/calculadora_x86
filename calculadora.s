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


.bss
	.lcomm	operacao, 1
	.lcomm	a, 8
	.lcomm	b, 8
	.lcomm	f, 8

.text

main:
	finit
	push %rbp
	
	call controlador

	pop %rbp
	ret


controlador:
	call mensagem
	call primeiro_operando
	call operacao

	cmpb $'!', operacao
	je trata_fatorial

	cmpb $'i', operacao
	je trata_inverso

	cmpb $'r', operacao
	je trata_quadrada

	cmpb $'p', operacao
	je trata_primo

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

	movq %rbp, %rsp
	pop %rbp
	ret

	trata_fatorial:
		fldz
		fcomip %st(1), %st(0)
		ja operacao_invalida

		movsd a, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, f

		call fatorial
		jmp imprime_resultado_int



	trata_inverso:
		fldz
		fcomip %st(1), %st(0)
		je erro_inverso

		call inverso
		jmp imprime_resultado_float



	trata_quadrada:
		fldz
		fcomip %st(1), %st(0)
		jae erro_raiz

		call quadrada
		jmp imprime_resultado_float



	trata_proximo_primo:
		movsd a, %xmm0          
		cvttsd2si %xmm0, %r8    

		call proximoprimo
		jmp imprime_resultado_int



	trata_soma:
		call soma
		jmp imprime_resultado_float



	trata_sub:
		call subtracao
		jmp imprime_resultado_float



	trata_multiplicacao:
		call multiplicacao
		jmp imprime_resultado_float



	trata_divisao:
		fldz
		fcomip %st(1), %st(0)
		je erro_divisao_zero

		call divisao
		jmp imprime_resultado_float



	trata_exponenciacao:
		movsd b, %xmm0
		cvttsd2si %xmm0, %r8
		movq %r8, b

		call exponenciacao
		jmp imprime_resultado_float



	trata_combinacao:
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



	trata_arranjos:
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



	trata_logaritmo:
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
#INPUT
#=========================

mensagem:
    push %rbp
    movq %rsp, %rbp

	movq $entrada, %rdi
	call printf

	movq %rbp, %rsp
	pop %rbp
	ret



primeiro_operando:
    push %rbp
    movq %rsp, %rbp

	movq $fmt3, %rdi
	movq $a, %rsi
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
	call scanf

	movq %rbp, %rsp
	pop %rbp
	ret


segundo_operando:
    push %rbp
    movq %rsp, %rbp

	movq $fmt3, %rdi
	movq $b, %rsi
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
	call printf
	jmp controlador

	movq %rbp, %rsp
	pop %rbp
	ret

erro_raiz:
    push %rbp
    movq %rsp, %rbp

	movq $err_raiz, %rdi
	call printf
	jmp controlador

	movq %rbp, %rsp
	pop %rbp
	ret

erro_inverso:
    push %rbp
    movq %rsp, %rbp

	movq $err_inv, %rdi
	call printf
	jmp controlador

	movq %rbp, %rsp
	pop %rbp
	ret

operacao_invalida:
    push %rbp
    movq %rsp, %rbp

	movq $err, %rdi
	call printf
	jmp controlador

	movq %rbp, %rsp
	pop %rbp
	ret

imprime_resultado_float:
    push %rbp
    movq %rsp, %rbp

	movq $saida_float, %rdi
	movq $1, %rax
	call printf
	jmp controlador

	movq %rbp, %rsp
	pop %rbp
	ret

imprime_resultado_int:
    push %rbp
    movq %rsp, %rbp
	
	movq $saida_int, %rdi
	movq %rax, %rsi
	call printf
	jmp controlador

	movq %rbp, %rsp
	pop %rbp
	ret
