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

    fyl2x

    fld %st(0)
    frndint 
    fsubr %st, %st(1)
    fxch %st(1)

    f2xm1
    fld1
    faddp %st, %st(1) 

    fscale 
    fstp %st(1)             

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
    add $31, %rsi          
    mov $10, %rbx          
    mov $0, %rcx 

    mov $0, %r8 
    cmp $0, %rax
    jge loop_print_int

    mov $1, %r8 
    neg %rax

    loop_print_int:
        xor %rdx, %rdx  
        div %rbx 
        add $'0', %dl 
        dec %rsi 
        movb %dl, (%rsi)
        inc %rcx 
        test %rax, %rax
        jnz loop_print_int

        cmp $1, %r8
        jne print_int_syscall
        dec %rsi
        movb $'-', (%rsi)
        inc %rcx

    print_int_syscall:
        mov $1, %rax   
        mov $1, %rdi      
        mov %rcx, %rdx
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
    mov $1, %rax        
    mov $1, %rdi     
    mov $1, %rdx          
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
    add $31, %rsi          


    mov $10, %rbx         
    mov $4, %rcx          

    loop_fracao:
        xor %rdx, %rdx         
        div %rbx               
        add $'0', %dl          
        dec %rsi              
        movb %dl, (%rsi)       
        dec %rcx               
        jnz loop_fracao       

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

print_float:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp

    movq $0, -16(%rbp)
    movq $0, -8(%rbp)

    movsd %xmm0, -8(%rbp)
    fldl -8(%rbp)

    btq $63, -8(%rbp)
    jnc float_positivo

    call print_menos

    fabs

    fstpl -8(%rbp)
    fldl -8(%rbp)

    float_positivo:
        fisttpq -16(%rbp)
        movq -16(%rbp), %rax
        call print_int

        call print_ponto

        fldl -8(%rbp)
        fildq -16(%rbp)
        fsubrp %st(0), %st(1)

        fmull mult_dec
        fisttpq -16(%rbp)
        movq -16(%rbp), %rax

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
#Ler Linha
#===========
ler_linha:
    push %rbp
    mov %rsp, %rbp

    mov $0, %rax
    mov $0, %rdi
    mov $buffer_io, %rsi
    mov $32, %rdx
    syscall

    movq $buffer_io, ponteiro

    pop %rbp
    ret



#===========
#Read float
#===========

read_float:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp

    push %rax
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %r8
    push %r9
    movq ponteiro, %rsi

    xor %rax, %rax            
    xor %rcx, %rcx
    mov $10, %r8  
    movq $0, -8(%rbp) 

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
        movq $1, -8(%rbp)     
        inc %rsi   

    loop_parte_inteira:
        xor %rcx, %rcx
        movb (%rsi), %cl
        cmp $'.', %cl        
        je prepara_fracao

        cmp $'0', %cl
        jl fim_apenas_inteiro
        cmp $'9', %cl
        jg fim_apenas_inteiro

        sub $'0', %cl              
        mul %r8
        add %rcx, %rax       
        inc %rsi
        jmp loop_parte_inteira

    prepara_fracao:
        inc %rsi                   
        movq %rax, -16(%rbp)    
        xor %rax, %rax            
        mov $1, %r9  

    loop_parte_fracionaria:
        xor %rcx, %rcx
        movb (%rsi), %cl
        cmp $'0', %cl
        jl monta_float_final
        cmp $'9', %cl
        jg monta_float_final

        sub $'0', %cl
        mul %r8                    
        add %rcx, %rax

        push %rax
        mov %r9, %rax
        mul %r8
        mov %rax, %r9
        pop %rax

        inc %rsi
        jmp loop_parte_fracionaria

    monta_float_final:
        movq %rax, -24(%rbp)
        movq %r9, -32(%rbp)

        fildq -16(%rbp)
        fildq -24(%rbp)
        fildq -32(%rbp)

        fdivrp %st(0), %st(1) 
        faddp %st(0), %st(1)
        jmp checa_sinal

    fim_apenas_inteiro:
        movq %rax, -16(%rbp)
        fildq -16(%rbp) 

    checa_sinal:
        cmpq $1, -8(%rbp)  
        jne fim_read_float
        fchs                 

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
        cmp $'\n', %al      
        je pular_op
        cmp $' ', %al 
        je pular_op
        cmp $0, %al
        je pular_op

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
