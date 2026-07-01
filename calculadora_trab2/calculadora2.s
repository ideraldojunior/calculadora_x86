.global main, a, b, f, resultado
.data
    entrada:        .ascii  "\n>>> "
    tam_entrada = . - entrada

    msg_salvo:      .ascii  "Salvo com sucesso!\n"
    tam_salvo = . - msg_salvo

    err:            .ascii  "err: Operação invalida!\n"
    tam_err = . - err

    err_div:        .ascii  "err: Divisão por zero!\n"
    tam_err_div = . - err_div

    err_var:        .ascii  "err: Variavel/Funcao nao encontrada!\n"
    tam_err_var = . - err_var

.bss
    .comm   operacao, 1
    .comm   resultado, 8
    .comm   a, 8
    .comm   b, 8
    .comm   f, 8
    .comm   buffer_io, 32
    .comm   ponteiro, 8
    .comm   valor_de_x, 8           
    
    # Memórias Globais
    .comm   mem_vars_valores, 208   
    .comm   mem_vars_status, 26     
    .comm   mem_funcs_strings, 832  
    .comm   mem_funcs_status, 26    
    .comm   mem_funcs_param, 26     
    
    # Escopo Dinâmico
    .comm   param_atual_idx, 8      
    .comm   param_atual_valor, 8    
    .comm   ponteiro_salvo, 8

.text
main:
    call controlador
    movq $60, %rax
    movq $0, %rdi
    syscall

controlador:
    finit                           
    movq $99, param_atual_idx(%rip) 

    call mensagem
    call ler_linha

    call verifica_atribuicao
    cmpq $1, %rax
    je controlador          

    movq ponteiro(%rip), %rsi

pula_espaco_sair:
    movb (%rsi), %al
    cmpb $' ', %al
    jne checa_sair
    incq %rsi
    jmp pula_espaco_sair

checa_sair:
    cmpb $'S', %al
    je sair

    call resolver_expressao

    cmpb $1, %r15b          
    je controlador          
    
    call imprime_resultado_float
    jmp controlador

sair:
    ret


# ==========================================
# MOTOR DE RESOLUÇÃO (COM VALIDAÇÃO DE ZERO)
# ==========================================
resolver_expressao:
    push %rbp
    movq %rsp, %rbp
    movb $0, %r15b          

    call avaliar_token      
    cmpb $1, %r15b          
    je abortar_resolve

    fstpl a(%rip)           
    fldl a(%rip)            

    call operador           
    cmpb $0, operacao(%rip)
    je fim_resolve_simples  

    # OPERADORES UNÁRIOS
    cmpb $'!', operacao(%rip)
    je trata_fatorial
    cmpb $'i', operacao(%rip)
    je trata_inverso
    cmpb $'r', operacao(%rip)
    je trata_quadrada
    cmpb $'p', operacao(%rip)
    je trata_proximo_primo

    # LÊ O SEGUNDO OPERANDO (Se for binário)
    call avaliar_token      
    cmpb $1, %r15b
    je abortar_resolve
    
    fstpl b(%rip)           
    fldl b(%rip)            

    # OPERADORES BINÁRIOS
    cmpb $'+', operacao(%rip)
    je trata_soma
    cmpb $'-', operacao(%rip)
    je trata_subtracao
    cmpb $'*', operacao(%rip)
    je trata_multiplicacao
    cmpb $'/', operacao(%rip)
    je trata_divisao
    cmpb $'^', operacao(%rip)
    je trata_exponenciacao
    cmpb $'c', operacao(%rip)
    je trata_combinacao
    cmpb $'a', operacao(%rip)
    je trata_arranjo
    cmpb $'l', operacao(%rip)  
    je trata_logaritmo

    call operacao_invalida
    movb $1, %r15b
    jmp abortar_resolve

    # --- TRATADORES COM VALIDAÇÃO ---
    trata_fatorial:
        fstp %st(0)         
        movsd a(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, f(%rip)
        call fatorial
        push %rax
        fildq (%rsp)        
        pop %rax
        fstpl resultado(%rip)
        movsd resultado(%rip), %xmm0
        fldl resultado(%rip)
        jmp fim_resolve
    
    trata_inverso:
        # PROTEÇÃO: Se a == 0, erro de divisão por zero
        movsd a(%rip), %xmm0
        xorpd %xmm1, %xmm1
        ucomisd %xmm1, %xmm0
        jp executa_inverso        
        je gatilho_div_zero       
    executa_inverso:
        call inverso
        jmp limpa_fpu_unario

    trata_quadrada:
        call quadrada
        jmp limpa_fpu_unario
        
    trata_proximo_primo:
        fstp %st(0)
        movsd a(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        call proximo_primo
        push %rax
        fildq (%rsp)        
        pop %rax
        fstpl resultado(%rip)
        movsd resultado(%rip), %xmm0
        fldl resultado(%rip)
        jmp fim_resolve
        
    trata_soma:
        call soma
        jmp limpa_fpu_binario
    trata_subtracao:
        call subtracao
        jmp limpa_fpu_binario
    trata_multiplicacao:
        call multiplicacao
        jmp limpa_fpu_binario

    trata_divisao:
        # PROTEÇÃO: Se b == 0, erro de divisão por zero
        movsd b(%rip), %xmm0
        xorpd %xmm1, %xmm1
        ucomisd %xmm1, %xmm0
        jp executa_divisao
        je gatilho_div_zero
    executa_divisao:
        call divisao
        jmp limpa_fpu_binario

    trata_exponenciacao:
        movsd b(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, b(%rip)
        call exponenciacao
        jmp limpa_fpu_binario
    trata_combinacao:
        movsd a(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, a(%rip)
        movsd b(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, b(%rip)
        call combinacao
        push %rax
        fildq (%rsp)        
        pop %rax
        fstpl resultado(%rip)
        movsd resultado(%rip), %xmm0
        jmp fim_resolve_int_bin
    trata_arranjo:
        movsd a(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, a(%rip)
        movsd b(%rip), %xmm0
        cvttsd2si %xmm0, %r8
        movq %r8, b(%rip)
        call arranjo
        push %rax
        fildq (%rsp)        
        pop %rax
        fstpl resultado(%rip)
        movsd resultado(%rip), %xmm0
        jmp fim_resolve_int_bin
    trata_logaritmo:
        call logaritmo
        jmp limpa_fpu_binario

gatilho_div_zero:
    fstp %st(0)
    cmpb $0, operacao(%rip)
    je dispara_erro_div
    fstp %st(0)
dispara_erro_div:
    call erro_divisao_zero
    jmp abortar_resolve

limpa_fpu_binario:
    fstp %st(0)             
    fstp %st(0)             
    fldl resultado(%rip)
    jmp fim_resolve

limpa_fpu_unario:
    fstp %st(0)
    fldl resultado(%rip)
    jmp fim_resolve

fim_resolve_int_bin:
    fstp %st(0)             
    fstp %st(0)             
    fldl resultado(%rip)
    jmp fim_resolve

fim_resolve_simples:
    fstpl resultado(%rip)
    movsd resultado(%rip), %xmm0  
    fldl resultado(%rip)
    jmp fim_resolve

fim_resolve:
abortar_resolve:
    movq %rbp, %rsp
    pop %rbp
    ret

operador:
    push %rbp
    movq %rsp, %rbp
    movq ponteiro(%rip), %rsi
loop_chk_op:
    movb (%rsi), %al
    cmpb $' ', %al
    jne chk_op_char
    incq %rsi
    jmp loop_chk_op
chk_op_char:
    cmpb $0, %al
    je no_op
    cmpb $'\n', %al
    je no_op
    call read_operador
    jmp fim_operador
no_op:
    movb $0, operacao(%rip) 
fim_operador:
    movq %rbp, %rsp
    pop %rbp
    ret


# ==========================================
# AVALIADOR INTELIGENTE 
# ==========================================
avaliar_token:
    push %rbp
    movq %rsp, %rbp
    
    movq ponteiro(%rip), %rsi
pula_espaco_tok:
    movb (%rsi), %al
    cmpb $' ', %al
    jne classificador_token
    incq %rsi
    jmp pula_espaco_tok

classificador_token:
    movq %rsi, ponteiro(%rip)
    cmpb $'0', %al
    jl checa_menos
    cmpb $'9', %al
    jle token_numero
checa_menos:
    cmpb $'-', %al
    je token_numero
    
    cmpb $'A', %al
    jl token_invalido
    cmpb $'z', %al
    jg token_invalido
    cmpb $'Z', %al
    jle eh_letra
    cmpb $'a', %al
    jl token_invalido

eh_letra:
    call pega_indice_letra
    movq %rax, %rbx         

    incq %rsi
pula_espaco_parenteses:
    movb (%rsi), %al
    cmpb $' ', %al
    jne checa_parenteses
    incq %rsi
    jmp pula_espaco_parenteses

checa_parenteses:
    cmpb $'(', %al
    je token_funcao

    # Processa Variável Normal/Global
    cmpq param_atual_idx(%rip), %rbx
    je token_parametro

    leaq mem_vars_status(%rip), %rdx
    cmpb $0, (%rdx, %rbx)
    je erro_var_nao_encontrada

    leaq mem_vars_valores(%rip), %rdx
    fldl (%rdx, %rbx, 8)    
    movq %rsi, ponteiro(%rip)
    jmp fim_token

token_parametro:
    fldl param_atual_valor(%rip)
    movq %rsi, ponteiro(%rip)
    jmp fim_token

token_funcao:
    leaq mem_funcs_status(%rip), %rdx
    cmpb $0, (%rdx, %rbx)
    je erro_var_nao_encontrada

    incq %rsi               
    movq %rsi, ponteiro(%rip)
    
    call avaliar_token
    fstpl valor_de_x(%rip)        

    movq ponteiro(%rip), %rsi
busca_fecha_parenteses:
    cmpb $')', (%rsi)
    je achou_fecha
    cmpb $0, (%rsi)
    je erro_var_nao_encontrada
    incq %rsi
    jmp busca_fecha_parenteses
achou_fecha:
    incq %rsi
    movq %rsi, ponteiro_salvo(%rip)

    # Context Switch
    pushq %rbx
    movq a(%rip), %rax
    pushq %rax
    movq b(%rip), %rax
    pushq %rax
    movzbq operacao(%rip), %rax
    pushq %rax
    pushq param_atual_idx(%rip)
    movq param_atual_valor(%rip), %rax
    pushq %rax

    fldl valor_de_x(%rip)
    fstpl param_atual_valor(%rip)
    leaq mem_funcs_param(%rip), %rdx
    movzbq (%rdx, %rbx), %rax
    movq %rax, param_atual_idx(%rip) 

    movq %rbx, %rax
    imulq $32, %rax
    leaq mem_funcs_strings(%rip), %rdx
    addq %rax, %rdx
    movq %rdx, ponteiro(%rip)

    call resolver_expressao

    subq $8, %rsp
    fstpl (%rsp)

    # Restore Context
    popq %r12
    popq %rax
    movq %rax, param_atual_valor(%rip)
    popq param_atual_idx(%rip)
    popq %rax
    movb %al, operacao(%rip)
    popq %rax
    movq %rax, b(%rip)
    popq %rax
    movq %rax, a(%rip)
    popq %rbx

    movq ponteiro_salvo(%rip), %rsi
    movq %rsi, ponteiro(%rip)
    pushq %r12
    fldl (%rsp)
    popq %r12
    jmp fim_token

token_numero:
    call read_float
    jmp fim_token

token_invalido:
    call operacao_invalida
    movb $1, %r15b
    jmp fim_token

erro_var_nao_encontrada:
    movq $1, %rax
    movq $1, %rdi
    movq $err_var, %rsi
    movq $tam_err_var, %rdx
    syscall
    movb $1, %r15b
    jmp fim_token

fim_token:
    movq %rbp, %rsp
    pop %rbp
    ret


# ==========================================
# IDENTIFICADOR DE ATRIBUIÇÕES
# ==========================================
verifica_atribuicao:
    push %rbp
    movq %rsp, %rbp
    movq ponteiro(%rip), %rsi
    movq $0, %rcx           
busca_igual:
    movb (%rsi, %rcx), %al
    cmpb $0, %al
    je nao_eh_atribuicao
    cmpb $'\n', %al
    je nao_eh_atribuicao
    cmpb $'=', %al
    je eh_atribuicao
    incq %rcx
    jmp busca_igual

nao_eh_atribuicao:
    movq $0, %rax
    jmp fim_verifica

eh_atribuicao:
    movq ponteiro(%rip), %rsi
    call pega_indice_letra
    movq %rax, %rbx         
    movq $1, %rcx           
verifica_paren_antes_igual:
    movb (%rsi, %rcx), %al
    cmpb $'=', %al
    je salva_variavel
    cmpb $'(', %al
    je salva_funcao
    incq %rcx
    jmp verifica_paren_antes_igual

salva_variavel:
    leaq 1(%rsi, %rcx), %rdx 
    movq %rdx, ponteiro(%rip)
    call read_float
    leaq mem_vars_valores(%rip), %rdx
    fstpl (%rdx, %rbx, 8)
    leaq mem_vars_status(%rip), %rdx
    movb $1, (%rdx, %rbx)
    jmp sucesso_atribuicao

salva_funcao:
    movq %rsi, %rdi
    addq %rcx, %rdi
    incq %rdi               
    pushq %rsi
    movq %rdi, %rsi
    call pega_indice_letra
    leaq mem_funcs_param(%rip), %rdx
    movb %al, (%rdx, %rbx)
    popq %rsi
busca_igual_func:
    movb (%rsi), %al
    cmpb $'=', %al
    je inicia_copia_func
    incq %rsi
    jmp busca_igual_func

inicia_copia_func:
    incq %rsi               
    movq %rbx, %rax
    imulq $32, %rax
    leaq mem_funcs_strings(%rip), %rdi
    addq %rax, %rdi
copia_loop:
    movb (%rsi), %al
    cmpb $0, %al
    je fim_copia_loop
    cmpb $'\n', %al
    je fim_copia_loop
    movb %al, (%rdi)
    incq %rsi
    incq %rdi
    jmp copia_loop
fim_copia_loop:
    movb $'\n', (%rdi)      
    movb $0, 1(%rdi)        
    leaq mem_funcs_status(%rip), %rdx
    movb $1, (%rdx, %rbx)

sucesso_atribuicao:
    movq $1, %rax
    movq $1, %rdi
    movq $msg_salvo, %rsi
    movq $tam_salvo, %rdx
    syscall
    movq $1, %rax           
    jmp fim_verifica

fim_verifica:
    movq %rbp, %rsp
    pop %rbp
    ret

# ==========================================
# UTILITÁRIOS E IMPRESSÃO
# ==========================================
pega_indice_letra:
    movzbq (%rsi), %rax
    cmpb $'a', %al
    jl maiuscula
    subb $'a', %al
    jmp fim_indice
maiuscula:
    subb $'A', %al
fim_indice:
    ret

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

erro_divisao_zero:
    push %rbp
    movq %rsp, %rbp
    movq $1, %rax
    movq $1, %rdi
    movq $err_div, %rsi
    movq $tam_err_div, %rdx
    syscall
    movb $1, %r15b
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
