global soma, subtracao, multiplicacao, divisao
global exponenciacao, combinacao, inverso, fatorial
global arranjo, logaritmo, quadrada, proximoprimo

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
	fxch 				#troca st(1) com st(0)
	fyl2x 				#calcula logaritmo na base 2

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

