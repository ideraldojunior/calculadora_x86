.global main, a, b, f, resultado
.data
    entrada:        .ascii  "\nInsira a operação ou tecle (s) para sair:\n"
    tam_entrada = . - entrada

    err:            .ascii  "err: Operação invalida!\n"
    tam_err = . - err

    err_div:        .ascii  "err: Divisão por zero!\n"
    tam_err_div = . - err_div

    err_raiz:       .ascii  "err: Operando não pode ser negativo\n"
    tam_err_raiz = . - err_raiz

    err_inv:        .ascii  "err: Operando não pode ser zero\n"
    tam_err_inv = . - err_inv

.bss
    .comm   operacao, 1
    .comm   resultado, 8
    .comm   a, 8
    .comm   b, 8
    .comm   f, 8
    .comm   buffer_io, 32
    .comm   ponteiro, 8

.text
main:
    call controlador

    movq $60, %rax
    movq $0, %rdi
    syscall

controlador:
    finit
    call mensagem
    call ler_linha
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
        movsd b, %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, b

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

    movq $1, %rax
    movq $1, %rdi
    movq $entrada, %rsi
    movq $tam_entrada, %rdx
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret


primeiro_operando:
    push %rbp
    movq %rsp, %rbp

    call read_float

    fstpl a
    fldl a

    movq %rbp, %rsp
    pop %rbp
    ret


operador:
    push %rbp
    movq %rsp, %rbp

    call read_operador

    movq %rbp, %rsp
    pop %rbp
    ret


segundo_operando:
    push %rbp
    movq %rsp, %rbp

    call read_float

    fstpl b
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

    movq $1, %rax
    movq $1, %rdi
    movq $err_div, %rsi
    movq $tam_err_div, %rdx
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret


erro_raiz:
    push %rbp
    movq %rsp, %rbp

    movq $1, %rax
    movq $1, %rdi
    movq $err_raiz, %rsi
    movq $tam_err_raiz, %rdx
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret


erro_inverso:
    push %rbp
    movq %rsp, %rbp

    movq $1, %rax
    movq $1, %rdi
    movq $err_inv, %rsi
    movq $tam_err_inv, %rdx
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret


operacao_invalida:
    push %rbp
    movq %rsp, %rbp

    movq $1, %rax
    movq $1, %rdi
    movq $err, %rsi
    movq $tam_err, %rdx
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret


imprime_resultado_float:
    call print_float
    call print_newline
    ret

imprime_resultado_int:
    call print_int
    call print_newline
    ret