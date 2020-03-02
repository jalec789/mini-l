%{
	//#include <*.h>
	#include <iostream>
	#include <vector>
	#include <string>
	#include <stdio.h>
	#include <stdlib.h>
	void yyerror(const char *msg);
	extern int line;
	extern int column;
	extern FILE * yyin;
	extern char* yytext;
	extern int yyleng;
	extern int yylex(void);

	using namespace std;

	struct symbol{
		string symbol;
		vector<int> line;
	};

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

%type <id> identifier prog_start
%type <num> number



%%
prog_start: %empty	{
	/*cout << "prog_start -> epsilon\n";*/
}
		| function prog_start {
	/*printf("prog_start -> function prog_start\n");*/
	
	//CREATE VECTOR...
}
;


function: FUNCTION identifier SEMICOLON	BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {
	/*printf("function -> FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");*/

	//CREATE VECTOR of VECTORS... new scope add to the stack
	//string identify;
	cout << "func " << (string($2)).substr(0, (string($2)).find(";")) << endl;
}
;


identifier: IDENT { 
	//cout << $1 << endl;
	//cout << $1 << endl;
	//$$ = $1;
}
;
identifiers: identifier	{
	//vector<string>* vec = new vector<string>();
	//vec.push_back($1);
	//$$ = vec;
	//cout << $1;
	//$$ = $1;
}
		| identifier COMMA identifiers	{
}
;

number: NUMBER {/*printf("number -> NUMBER %d\n", $1);*/}
;

declaration: identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {}
		| identifiers COLON INTEGER {}
;
declarations: %empty {}
		| declaration SEMICOLON declarations {}
;


statements: statement SEMICOLON statements {}
		| statement SEMICOLON {}
;
statement: var ASSIGN expression {}
		| IF bool-expr THEN statements ENDIF {}	
		| IF bool-expr THEN statements ELSE statements ENDIF {}
		| WHILE bool-expr BEGINLOOP statements ENDLOOP {}
		| DO BEGINLOOP statements ENDLOOP WHILE bool-expr {}
		| FOR var ASSIGN number SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP {}
		| READ vars {}
		| WRITE vars {}
		| CONTINUE {}
		| RETURN expression {}
;


bool-expr: relation-and-expr {}
		| relation-and-expr OR bool-expr {}
;


relation-and-expr: relation-expr {}
		| relation-expr AND relation-and-expr {}
;


relation-expr: expression comp expression {}
		| TRUE {}
		| FALSE {}
		| L_PAREN bool-expr R_PAREN {}
		| NOT expression comp expression {}
		| NOT TRUE {}
		| NOT FALSE {}
		| NOT L_PAREN bool-expr R_PAREN {}
;

comp: EQ {}
		| NEQ {}
		| LT {}
		| GT {}
		| LTE {}
		| GTE {}
;

expressions: expression {}
		| expression COMMA expressions {}
;
expression: multiplicative-expr {}
		| multiplicative-expr ADD expression {}
		| multiplicative-expr SUB expression {}
;


multiplicative-expr: term {}
		| term MULT multiplicative-expr {}
		| term DIV multiplicative-expr {}
		| term MOD multiplicative-expr {}
;


term: var {}
		| number {}
		| L_PAREN expression R_PAREN {}
		| SUB var %prec UMINUS {}
		| SUB number %prec UMINUS {}
		| SUB L_PAREN expression R_PAREN %prec UMINUS {}
		| identifier L_PAREN expressions R_PAREN {}
		| identifier L_PAREN R_PAREN {}
;


vars: var {}
		|var COMMA vars {}
;
var: identifier {}
		| identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {}

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




