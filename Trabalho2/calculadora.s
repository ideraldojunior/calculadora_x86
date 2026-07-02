.global main, a, b, f, resultado
.data
    entrada:        .ascii  "\nInsira a operacao ou tecle (s) para sair:\n>>> "
    tam_entrada = . - entrada

    err:            .ascii  "err: Operacao invalida!\n"
    tam_err = . - err

    err_div:        .ascii  "err: Divisao por zero!\n"
    tam_err_div = . - err_div

    err_raiz:       .ascii  "err: Operando nao pode ser negativo\n"
    tam_err_raiz = . - err_raiz

    err_inv:        .ascii  "err: Operando nao pode ser zero\n"
    tam_err_inv = . - err_inv

    err_var:        .ascii  "err: Variavel/Funcao nao encontrada!\n"
    tam_err_var = . - err_var

    msg_salvo:      .ascii  "Salvo com sucesso!\n"
    tam_salvo = . - msg_salvo

    saida_int:      .ascii  "Resultado: "
    tam_saida_int = . - saida_int

    saida_float:    .ascii  "Resultado: "
    tam_saida_float = . - saida_float

.bss
    .comm   operacao, 1
    .comm   resultado, 8
    .comm   a, 8
    .comm   b, 8
    .comm   f, 8
    .comm   erro_flag, 8

    .comm   buffer_io, 64
    .comm   ponteiro, 8

    .comm   mem_vars_valores, 208
    .comm   mem_vars_status, 26
    .comm   mem_funcs_strings, 832
    .comm   mem_funcs_status, 26

    .comm   ponteiro_salvo, 8
    .comm   valor_de_x, 8

.text

#=========================
#MAIN E CONTROLADOR
#=========================
main:
    call controlador
    movq $60, %rax
    movq $0, %rdi
    syscall

controlador:
    finit
    movq $0, erro_flag

    call mensagem
    call ler_linha

    call verifica_atribuicao
    cmpq $1, %rax
    je controlador

    movq ponteiro, %rsi
    movb (%rsi), %al
    cmpb $'s', %al
    je sair
    cmpb $'S', %al
    je sair

    call avaliar_expressao

    cmpq $1, erro_flag
    je controlador

    call imprime_resultado_float
    jmp controlador

    sair:
        ret


#=========================
#MATEMÁTICA
#=========================
avaliar_expressao:
    push %rbp
    movq %rsp, %rbp

    call primeiro_operando
    cmpq $1, erro_flag
    je fim_avaliar

    call operador
    cmpb $0, operacao
    je trata_consulta_simples

    cmpb $'!', operacao
    je trata_fatorial

    cmpb $'i', operacao
    je trata_inverso

    cmpb $'r', operacao
    je trata_quadrada

    cmpb $'p', operacao
    je trata_proximo_primo

    call segundo_operando
    cmpq $1, erro_flag
    je fim_avaliar

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

    jmp chama_erro

    trata_consulta_simples:
        fstpl resultado
        movsd resultado, %xmm0
        fldl resultado
        jmp fim_avaliar

    trata_fatorial:
        fldz
        fcomip %st(1), %st(0)
        ja erro_fat
        fstp %st(0)

        movsd a, %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, f

        call fatorial
        push %rax
        fildq (%rsp)
        pop %rax
        fstpl resultado
        movsd resultado, %xmm0
        fldl resultado
        jmp fim_avaliar

    erro_fat:
        fstp %st(0)
        jmp chama_erro

    trata_inverso:
        movsd a, %xmm0
        xorpd %xmm1, %xmm1
        ucomisd %xmm1, %xmm0

        je chama_erro_inverso
        call inverso
        fstp %st(0)
        fstp %st(0)
        fldl resultado

        jmp fim_avaliar

    trata_quadrada:
        fldz
        fcomip %st(1), %st(0)
        jae erro_raiz_fpu

        call quadrada
        fstp %st(0)
        fldl resultado

        jmp fim_avaliar

    erro_raiz_fpu:
        fstp %st(0)
        jmp chama_erro_raiz

    trata_proximo_primo:
        fldz
        fcomip %st(1), %st(0)
        ja erro_primo

        movsd a, %xmm0
        cvttsd2si %xmm0, %r8

        call proximo_primo

        push %rax
        fildq (%rsp)
        pop %rax
        fstpl resultado
        movsd resultado, %xmm0
        fldl resultado
        jmp fim_avaliar

    erro_primo:
        fstp %st(0)
        jmp chama_erro

    trata_soma:
        call soma
        jmp limpa_binario

    trata_subtracao:
        call subtracao
        jmp limpa_binario

    trata_multiplicacao:
        call multiplicacao
        jmp limpa_binario

    trata_divisao:
        movsd b, %xmm0
        xorpd %xmm1, %xmm1
        ucomisd %xmm1, %xmm0

        je chama_erro_divisao
        call divisao
        jmp limpa_binario

    trata_exponenciacao:
        fldl b                
        fldl a              

        fldz                        
        fcomip %st(1), %st(0)      
        ja base_negativa           

        call exponenciacao
        jmp fim_exponenciacao

        base_negativa:
            movsd b, %xmm0        
            cvttsd2si %xmm0, %rax       
            cvtsi2sd %rax, %xmm1        

            ucomisd %xmm0, %xmm1       
            jne chama_erro_exp          

            fabs                    
            call exponenciacao         

            test $1, %rax               
            jz fim_exponenciacao        

            fchs                        
            fstl resultado        
            movsd resultado, %xmm0 

        fim_exponenciacao:
            call imprime_resultado_float
            jmp controlador           

        chama_erro_exp:
            fstp %st(0)            
            fstp %st(0)                
            call erro_raiz           
            jmp controlador

    trata_combinacao:
        movsd a, %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, a

        movsd b, %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, b

        call combinacao
        push %rax
        fildq (%rsp)
        pop %rax
        fstpl resultado
        movsd resultado, %xmm0
        jmp limpa_binario

    trata_arranjo:
        movsd a, %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, a

        movsd b, %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, b

        call arranjo
        push %rax
        fildq (%rsp)
        pop %rax
        fstpl resultado
        movsd resultado, %xmm0
        jmp limpa_binario

    trata_logaritmo:
        call logaritmo
        jmp limpa_binario

    chama_erro:
        call operacao_invalida
        jmp fim_avaliar

    chama_erro_inverso:
        fstp %st(0)
        call erro_inverso
        jmp fim_avaliar

    chama_erro_raiz:
        fstp %st(0)
        call erro_raiz
        jmp fim_avaliar

    chama_erro_divisao:
        fstp %st(0)
        fstp %st(0)
        call erro_divisao_zero
        jmp fim_avaliar

    limpa_binario:
        fstp %st(0)
        fstp %st(0)
        fldl resultado
        jmp fim_avaliar

    fim_avaliar:
        movq %rbp, %rsp
        pop %rbp
        ret


#=========================
#INPUT E OPERADORES
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
    call avaliar_token
    cmpq $1, erro_flag
    je fim_primeiro_op
    fstpl a
    fldl a
fim_primeiro_op:
    movq %rbp, %rsp
    pop %rbp
    ret

operador:
    push %rbp
    movq %rsp, %rbp
    movq ponteiro, %rsi

loop_op:
    movb (%rsi), %al
    cmpb $' ', %al
    jne avalia_op
    incq %rsi
    jmp loop_op

avalia_op:
    cmpb $0, %al
    je seta_op_nulo
    cmpb $'\n', %al
    je seta_op_nulo
    call read_operador
    jmp fim_operador

seta_op_nulo:
    movb $0, operacao

fim_operador:
    movq %rbp, %rsp
    pop %rbp
    ret

segundo_operando:
    push %rbp
    movq %rsp, %rbp
    call avaliar_token
    cmpq $1, erro_flag
    je fim_segundo_op
    fstpl b
    fldl b
fim_segundo_op:
    movq %rbp, %rsp
    pop %rbp
    ret


#=========================
#OUTPUT E ERROS
#=========================
erro_divisao_zero:
    push %rbp
    movq %rsp, %rbp
    movq $1, erro_flag
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
    movq $1, erro_flag
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
    movq $1, erro_flag
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
    movq $1, erro_flag
    movq $1, %rax
    movq $1, %rdi
    movq $err, %rsi
    movq $tam_err, %rdx
    syscall
    movq %rbp, %rsp
    pop %rbp
    ret

erro_variavel:
    push %rbp
    movq %rsp, %rbp
    movq $1, erro_flag
    movq $1, %rax
    movq $1, %rdi
    movq $err_var, %rsi
    movq $tam_err_var, %rdx
    syscall
    movq %rbp, %rsp
    pop %rbp
    ret

imprime_resultado_float:
    push %rbp
    movq %rsp, %rbp
    movq $1, %rax
    movq $1, %rdi
    movq $saida_float, %rsi
    movq $tam_saida_float, %rdx
    syscall
    call print_float
    call print_newline
    movq %rbp, %rsp
    pop %rbp
    ret


#=========================
#PARSERS E AMBIENTE
#=========================
ler_linha:
    push %rbp
    mov %rsp, %rbp
    mov $0, %rax
    mov $0, %rdi
    mov $buffer_io, %rsi
    mov $256, %rdx
    syscall
    movq $buffer_io, ponteiro
    pop %rbp
    ret

pega_indice_letra:
    push %rbp
    movq %rsp, %rbp
    movzbq (%rsi), %rax
    subb $'a', %al
    movq %rbp, %rsp
    pop %rbp
    ret

avaliar_token:
    push %rbp
    movq %rsp, %rbp
    movq ponteiro, %rsi

pula_espaco_tok:
    movb (%rsi), %al
    cmpb $' ', %al
    jne define_tipo
    incq %rsi
    jmp pula_espaco_tok

define_tipo:
    movq %rsi, ponteiro
    cmpb $'0', %al
    jl checa_negativo
    cmpb $'9', %al
    jle eh_numero

checa_negativo:
    cmpb $'-', %al
    je eh_numero
    cmpb $'a', %al
    jl token_invalido
    cmpb $'z', %al
    jg token_invalido

    call pega_indice_letra
    movq %rax, %rbx
    incq %rsi

pula_espaco_paren:
    movb (%rsi), %al
    cmpb $' ', %al
    jne verifica_parenteses
    incq %rsi
    jmp pula_espaco_paren

verifica_parenteses:
    cmpb $'(', %al
    je eh_funcao

eh_variavel:
    cmpq $23, %rbx
    je carrega_x_local

    leaq mem_vars_status, %rdx
    cmpb $0, (%rdx, %rbx)
    je erro_token_var

    leaq mem_vars_valores, %rdx
    fldl (%rdx, %rbx, 8)
    movq %rsi, ponteiro
    jmp fim_token

carrega_x_local:
    fldl valor_de_x
    movq %rsi, ponteiro
    jmp fim_token

eh_numero:
    call read_float
    jmp fim_token

eh_funcao:
    incq %rsi
    movq %rsi, ponteiro

    call avaliar_token
    cmpq $1, erro_flag
    je fim_token

    movq ponteiro, %rsi

busca_fecha:
    cmpb $')', (%rsi)
    je executa_recursao
    cmpb $0, (%rsi)
    je erro_token_var
    cmpb $'\n', (%rsi)
    je erro_token_var
    incq %rsi
    jmp busca_fecha

executa_recursao:
    incq %rsi
    movq %rsi, ponteiro

    pushq ponteiro
    movzbq operacao, %rax
    pushq %rax
    movq a, %rax
    pushq %rax
    movq b, %rax
    pushq %rax
    movq valor_de_x, %rax
    pushq %rax

    fstpl valor_de_x

    movq %rbx, %rax
    imulq $32, %rax
    leaq mem_funcs_strings, %rdx
    addq %rax, %rdx
    movq %rdx, ponteiro

    call avaliar_expressao

    subq $8, %rsp
    fstpl (%rsp)
    popq %r10

    popq %rax
    movq %rax, valor_de_x
    popq %rax
    movq %rax, b
    popq %rax
    movq %rax, a
    popq %rax
    movb %al, operacao
    popq %rax
    movq %rax, ponteiro

    pushq %r10
    fldl (%rsp)
    addq $8, %rsp

    jmp fim_token

token_invalido:
    call operacao_invalida
    jmp fim_token

erro_token_var:
    call erro_variavel
    jmp fim_token

fim_token:
    movq %rbp, %rsp
    pop %rbp
    ret

verifica_atribuicao:
    push %rbp
    movq %rsp, %rbp
    movq ponteiro, %rsi
    movq $0, %rcx

busca_igual_attr:
    movb (%rsi, %rcx), %al
    cmpb $0, %al
    je nao_e_atribuicao
    cmpb $'\n', %al
    je nao_e_atribuicao
    cmpb $'=', %al
    je separa_atribuicao
    incq %rcx
    jmp busca_igual_attr

nao_e_atribuicao:
    movq $0, %rax
    jmp fim_verifica

separa_atribuicao:
    movb (%rsi), %al
    cmpb $'a', %al
    jl attr_invalida
    cmpb $'z', %al
    jg attr_invalida
    call pega_indice_letra
    movq %rax, %rbx
    movq $1, %rcx

checa_tipo_attr:
    movb (%rsi, %rcx), %al
    cmpb $'=', %al
    je grava_variavel
    cmpb $'(', %al
    je grava_funcao
    incq %rcx
    jmp checa_tipo_attr

grava_variavel:
    leaq 1(%rsi, %rcx), %rdx
    movq %rdx, ponteiro
    call read_float
    leaq mem_vars_valores, %rdx
    fstpl (%rdx, %rbx, 8)
    leaq mem_vars_status, %rdx
    movb $1, (%rdx, %rbx)
    jmp fim_sucesso_attr

grava_funcao:
acha_igual_str:
    movb (%rsi), %al
    cmpb $'=', %al
    je inicia_copia_str
    incq %rsi
    jmp acha_igual_str

inicia_copia_str:
    incq %rsi
    movq %rbx, %rax
    imulq $32, %rax
    leaq mem_funcs_strings, %rdi
    addq %rax, %rdi

laco_copia_str:
    movb (%rsi), %al
    cmpb $0, %al
    je termina_copia
    cmpb $'\n', %al
    je termina_copia
    movb %al, (%rdi)
    incq %rsi
    incq %rdi
    jmp laco_copia_str

termina_copia:
    movb $'\n', (%rdi)
    movb $0, 1(%rdi)
    leaq mem_funcs_status, %rdx
    movb $1, (%rdx, %rbx)
    jmp fim_sucesso_attr

attr_invalida:
    call operacao_invalida
    movq $1, %rax
    jmp fim_verifica

fim_sucesso_attr:
    movq $1, %rax
    movq $1, %rdi
    movq $msg_salvo, %rsi
    movq $tam_salvo, %rdx
    syscall
    movq $1, %rax

fim_verifica:
    movq %rbp, %rsp
    pop %rbp
    ret