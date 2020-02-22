%{
	//#include <*.h>
 	#include <stdio.h>
 	#include <stdlib.h>
	void yyerror(const char *msg);
	extern int line;
	extern int column;
	FILE * yyin;
	extern char* yytext;
	extern int yyleng;
%}

%union{
	char* id;
	int num;
}
	//precendence defined here
%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA

%token <id> IDENT
%token <num> NUMBER

%left ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left DIV MULT MOD
%nonassoc UMINUS
%token L_SQUARE_BRACKET R_SQUARE_BRACKET
%token L_PAREN R_PAREN




%%
prog_start: %empty	{printf("prog_start -> epsilon\n");}
		| function prog_start {printf("prog_start -> function prog_start\n");}
;


function: FUNCTION identifier SEMICOLON	BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
;


identifier: IDENT {printf("identifier -> IDENT %s\n", $1);}
;
identifiers: identifier	{printf("identifiers -> identifier\n");}
		| identifier COMMA identifiers	{printf("identifiers -> identifier COMMA identifiers\n");}
;

number: NUMBER {printf("number -> NUMBER %d\n", $1);}
;

declaration: identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER\n");}
		| identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
;
declarations: %empty {printf("declarations -> epsilon\n");}
		| declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
;


statements: statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
		| statement SEMICOLON {printf("statements -> statement SEMICOLON\n");}
;
statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
		| IF bool-expr THEN statements ENDIF {printf("statement -> IF bool-expr THEN statements ENDIF\n");}	
		| IF bool-expr THEN statements ELSE statements ENDIF {printf("statement -> IF bool-expr THEN statements ELSE statements ENDIF\n");}
		| WHILE bool-expr BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool-expr BEGINLOOP statements ENDLOOP\n");}
		| DO BEGINLOOP statements ENDLOOP WHILE bool-expr {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool-expr\n");}
		| FOR var ASSIGN number SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP {printf("FOR var ASSIGN number SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
		| READ vars {printf("statement -> READ vars\n");}
		| WRITE vars {printf("statement -> WRITE vars\n");}
		| CONTINUE {printf("statement -> CONTINUE\n");}
		| RETURN expression {printf("statement -> RETURN expression\n");}
;


bool-expr: relation-and-expr {printf("bool-expr -> relation-and-expr\n");}
		| relation-and-expr OR bool-expr {printf("bool-expr -> relation-and-expr OR bool-expr\n");}
;


relation-and-expr: relation-expr {printf("relation-and-expr -> relation-expr\n");}
		| relation-expr AND relation-and-expr {printf("relation-and-expr -> relation-expr AND relation-and-expr\n");}
;


relation-expr: expression comp expression {printf("relation-expr -> expression comp expression\n");}
		| TRUE {printf("relation-expr -> TRUE\n");}
		| FALSE {printf("relation-expr -> FALSE\n");}
		| L_PAREN bool-expr R_PAREN {printf("relation-expr -> L_PAREN bool-expr R_PAREN\n");}
		| NOT expression comp expression {printf("relation-expr -> NOT expression comp expression\n");}
		| NOT TRUE {printf("relation-expr -> NOT TRUE\n");}
		| NOT FALSE {printf("relation-expr -> NOT FALSE\n");}
		| NOT L_PAREN bool-expr R_PAREN {printf("relation-expr -> NOT L_PAREN bool-expr R_PAREN\n");}
;

comp: EQ {printf("comp -> EQ\n");}
		| NEQ {printf("comp -> NEQ\n");}
		| LT {printf("comp -> LT\n");}
		| GT {printf("comp -> GT\n");}
		| LTE {printf("comp -> LTE\n");}
		| GTE {printf("comp -> GTE\n");}
;

expressions: expression {printf("expressions -> expression\n");}
		| expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");}
;
expression: multiplicative-expr {printf("expression -> multiplicative-expr\n");}
		| multiplicative-expr ADD expression {printf("expression -> multiplicative-expr ADD expression\n");}
		| multiplicative-expr SUB expression {printf("expression -> multiplicative-expr SUB expression \n");}
;


multiplicative-expr: term {printf("multiplicative-expr -> term\n");}
		| term MULT multiplicative-expr {printf("multiplicative-expr -> term MULT multiplicative-expr\n");}
		| term DIV multiplicative-expr {printf("multiplicative-expr -> term DIV multiplicative-expr\n");}
		| term MOD multiplicative-expr {printf("multiplicative-expr -> term MOD multiplicative-expr\n");}
;


term: var {printf("term -> var\n");}
		| number {printf("term -> number\n");}
		| L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
		| SUB var %prec UMINUS {printf("term -> SUB var\n");}
		| SUB number %prec UMINUS {printf("term -> SUB number\n");}
		| SUB L_PAREN expression R_PAREN %prec UMINUS {printf("term -> SUB L_PAREN expression R_PAREN\n");}
		| identifier L_PAREN expressions R_PAREN {printf("term -> identifier L_PAREN expressions R_PAREN\n");}
		| identifier L_PAREN R_PAREN {printf("term -> identifier L_PAREN R_PAREN\n");}
;


vars: var {printf("vars -> var\n");}
		|var COMMA vars {printf("vars -> var COMMA vars\n");}
;
var: identifier {printf("var -> identifier\n");}
		| identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}

;



%%
//USER CODE

int main(int argc, char **argv) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (yyin == NULL){
			printf("syntax: %s filename\n", argv[0]);
		}
	}
	yyparse(); // Calls yylex() for tokens.
	return 0;
}


void yyerror(const char *msg) {
	printf("** Line %d, position %d: %s\n", line, column, msg);
	//printf("");
	

	//this did not work with strdup ???
	//printf("Error at line %d, column %d: unrecognized symbol \"%.*s\"\n",line, column, yyleng, yytext);
}




