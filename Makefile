all: 
	gcc calculadora.s -o calculadora -no-pie -g

test: 
	./calculadora

debugg:
	gdb ./calculadora