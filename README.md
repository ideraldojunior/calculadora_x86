==============================================
==============================================
Trabalho de PROG. P/ INTERF. HARDWARE E SOFTWARE
==============================================
==============================================

Integrantes:
    Johnny Maia Fernandes            ra: 140363
    Ideraldo Luis Trentini Júnior    ra: 138318




Nesta pasta estão contidos os 2 trabalhos relacionados a calculadora no assembly X86, além disso
o trabalho 2 é uma extensão do trabalho 1, contendo mais funcionalidades.

=======================
Trabalho 1:
=======================
As seguintes operações estão inclusas:
    Soma (+)

    Subtração (-)

    Multiplicação (*)

    Divisão (/)

    Exponenciação (^)

    Combinação (c)

    Arranjo (a)

    Fatorial (!)

    Inverso (i)

    Raiz quadrada(r)

    Logaritmo (l) 

    Próximo Primo (p)

Exemplos: 
>>> 10 + 10
Resultado: 20
>>> 100 - 30
Resultado: 70
>>> 3 !
Resultado: 6
>>> 10 / 5
Resultado: 2

Para sair, apenas coloque (s) no terminal:
>>> s



=======================
Trabalho 2: 
=======================
Além de haver todas as funcionalidades do trabalho 1, ele possuí
    
    - Criação e uso de funções (de a - z)
        IMPORTANTE: aceita somente funções com parametro, além disso, 
        elas devem ser criadas considerando sempre como x parametro

    - Criação e uso de variáveis (de a - z)

    - Não utiliza o lib.c

Exemplos: 
>>> g(x) = x + x
>>> g(2)
Resultado: 4

>>> h(x) = x / 4
>>> h(2)
Resultado: 0.5

>>> z(x) = 20 + 20
>>> z(2)
Resultado: 40

>>> x = 30
>>> x
Resultado: 30

>>> w(x) = x l x
>>> z = 1
>>> w(2) + z
Resultado: 2


=======================
COMO COMPILAR E RODAR
=======================

entre no arquivo do trabalho em especifico e, aproveitando do arquivo MakeFile que apenas simplifica o uso do terminal,
coloque:

>>> make all (compila os arquivos assembly)
>>> make test (executa o objeto gerado)
>>> make debug (adicional, apenas para debugar)



envar o trabalho para: afsilva@uem.br
corpo do e-mail: nome da dupla
um único arquivo compactado
read.me passo-a-passo: como compilar, como executar
