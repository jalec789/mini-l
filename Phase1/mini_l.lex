%{
#include "header.h"
%}
	//DEFINITIONS

	int line = 1, column = 0;

DIGIT [0-9]
LETTER [a-zA-Z]
UNDERSCORE _
COMMENT ##.*\n

%%
	//RULES

	/*Reserved Words*/
function		printf("FUNCTION\n"); column = column + yyleng;
beginparams		printf("BEGIN_PARAMS\n"); column = column + yyleng;
endparams		printf("END_PARAMS\n"); column = column + yyleng;
beginlocals		printf("BEGIN_LOCALS\n"); column = column + yyleng;
endlocals		printf("END_LOCALS\n"); column = column + yyleng;
beginbody		printf("BEGIN_BODY\n"); column = column + yyleng;
endbody			printf("END_BODY\n"); column = column + yyleng;
integer			printf("INTEGER\n"); column = column + yyleng;
array			printf("ARRAY\n"); column = column + yyleng;
of				printf("OF\n"); column = column + yyleng;
if				printf("IF\n"); column = column + yyleng;
then			printf("THEN\n"); column = column + yyleng;
endif			printf("ENDIF\n"); column = column + yyleng;
else			printf("ELSE\n"); column = column + yyleng;
while			printf("WHILE\n"); column = column + yyleng;
do				printf("DO\n"); column = column + yyleng;
for				printf("FOR\n"); column = column + yyleng;
beginloop		printf("BEGINLOOP\n"); column = column + yyleng;
endloop			printf("ENDLOOP\n"); column = column + yyleng;
continue		printf("CONTINUE\n"); column = column + yyleng;
read			printf("READ\n"); column = column + yyleng;
write			printf("WRITE\n"); column = column + yyleng;
and				printf("AND\n"); column = column + yyleng;
or				printf("OR\n"); column = column + yyleng;
not				printf("NOT\n"); column = column + yyleng;
true			printf("TRUE\n"); column = column + yyleng;
false			printf("FALSE\n"); column = column + yyleng;
return			printf("RETURN\n"); column = column + yyleng;

	/*Arithmetic Operators*/
"-"				printf("SUB\n"); column = column + yyleng;
"+"				printf("ADD\n"); column = column + yyleng;
"*"				printf("MULT\n"); column = column + yyleng;
"/"				printf("DIV\n"); column = column + yyleng;
"%"				printf("MOD\n"); column = column + yyleng;

	/*Comparison Operators*/
"=="			printf("EQ\n"); column = column + yyleng;
"<>"			printf("NEQ\n"); column = column + yyleng;
"<"				printf("LT\n"); column = column + yyleng;
">"				printf("GT\n"); column = column + yyleng;
"<="			printf("LTE\n"); column = column + yyleng;
">="			printf("GTE\n"); column = column + yyleng;


	/*Other Special Symbols*/
";"				printf("SEMICOLON\n"); column = column + yyleng;
":"				printf("COLON\n"); column = column + yyleng;
","				printf("COMMA\n"); column = column + yyleng;
"("				printf("L_PAREN\n"); column = column + yyleng;
")"				printf("R_PAREN\n"); column = column + yyleng;
"["				printf("L_SQUARE_BRACKET\n"); column = column + yyleng;
"]"				printf("R_SQUARE_BRACKET\n"); column = column + yyleng;
":="			printf("ASSIGN\n"); column = column + yyleng;

{COMMENT}		++line;


\n				++line; column = 0;
" "|\t			 column = column + yyleng;





	/*Numbers only*/
{DIGIT}+		printf("NUMBER %.*s\n", yyleng, yytext); column = column + yyleng;


	/* Errors */
({DIGIT}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*		printf("Error at line %d, column %d: identifier \"%.*s\" must begin with letter\n", line, column, yyleng, yytext); column = column + yyleng;

({LETTER}|{DIGIT}|{UNDERSCORE})+{UNDERSCORE}		printf("Error at line %d, column %d: identifier \"%.*s\" cannot end with underscore\n",line, column, yyleng, yytext); column = column + yyleng;



	/*Identifiers only*/
{LETTER}({LETTER}|{DIGIT}|{UNDERSCORE})*			printf("IDENT %.*s\n", yyleng, yytext); column = column + yyleng;


	/* More Errors */
.					printf("Error at line %d, column %d: unrecognized symbol \"%.*s\"\n",line, column, yyleng, yytext); column = column + yyleng;


%%
	//USER CODE

int main(int argc, char **argv) {
	++argv, --argc;
	if(argc >0) {
		yyin = fopen(argv[0], "r");
	}
	else {
		yyin = stdin;
	}

	yylex();
	return 0;
}












