all: 
	git add .
	git commit -m "o"
	gcc calculadora.s lib.s -o calculadora -no-pie -g

test: 
	./calculadora

debugg:
	gdb ./calculadora
