parse: mini_l.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex mini_l.lex
	g++ -std=c++11 -o parser lex.yy.c y.tab.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser
