%{
	//#include <*.h>
	#include <iostream>
	#include <vector>
	#include <string>
	#include <stdio.h>
	#include <stdlib.h>
	void yyerror(const char *MSG);
	extern int line;
	extern int column;
	extern FILE * yyin;
	extern char* yytext;
	extern int yyleng;
	extern int yylex(void);

	using namespace std;

	vector<string> functions_symbol_table;
	vector<string> scope_symbol_table;	//clear after each function is done


	//temporaries...
	//newtemp vectors
	vector<string> temp_var;
	//newtemp functions
	vector<string> temp_func;
	//newlabel vectors
	vector<string> label_var;
	//newlabel functions
	vector<string> label_func;


	//interpreter string for each function
	vector<string> instruction_list;
	int listId = 0;	//for every line added to list for a function

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

%type <id> identifier identifiers function
%type <num> number



%%
prog_start: %empty	{
	/*cout << "prog_start -> epsilon\n";*/
}
		| function prog_start {
	/*printf("prog_start -> function prog_start\n");*/
	
	//CREATE VECTOR of functions
};


function: FUNCTION identifier SEMICOLON	BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {
	/*printf("function -> FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");*/

	//string identify;
	
	cout << "func " << $2 << endl;
	for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}
	instruction_list.clear();
	scope_symbol_table.clear();
};


// I might fo it this way. it'll be way more organized
/*

function: function_id SEMICOLON	params locals body {

};

function_id: FUNCTION identifier {

};

params: BEGIN_PARAMS declarations END_PARAMS {

};

locals: BEGIN_LOCALS declarations END_LOCALS {

};

body: BEGIN_BODY statements END_BODY {

};
*/



identifier: IDENT { 
	//$$ = $1;
	//symbol a;
	//a.symb = $1;
	//a.ln = line;
	//symbol_table.push_back(a);
	//cout << "\t" << $1 << endl;
	$$ = $1;	//pushes id up the tree
};
identifiers: identifier	{
	//vector<string>* vec = new vector<string>();
	//vec.push_back($1);
	//$$ = vec;
	//cout << $1 << endl;
	$$ = $1; //must be passed up tree since it can be integer ID or function ID
	
}
		| identifiers COMMA identifier {
	instruction_list.push_back(". " + string($3));
};


number: NUMBER {
	$$ = $1;
};


declaration: identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {
	instruction_list.push_back(".[] " + string($1) + ", " + to_string($5));
}
		| identifiers COLON INTEGER {
	instruction_list.push_back(". " + string($1));
	//cout << ". " << $1 << endl;
};
declarations: %empty {}
		| declaration SEMICOLON declarations {
	//CREATE VECTOR of VECTORS... new scope add to the stack
	//...
	
};


statements: statement SEMICOLON statements {}
		| statement SEMICOLON {}
;
statement: var ASSIGN expression {}
		| IF bool-expr THEN statements ENDIF {/* START TESTING HERE */}	
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

	//remember that a function call is a term. should we add more rules???
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


	//for(int i = 0; i < symbol_table.size(); i++){
	//	cout << symbol_table[i].symb << " : " << symbol_table[i].ln << endl;
	//}




	return 0;
}


void yyerror(const char *MSG) {
	printf("** Line %d, position %d: %s\n", line, column, MSG);
	//printf("");
	

	//this did not work with strdup ???
	//printf("Error at line %d, column %d: unrecognized symbol \"%.*s\"\n",line, column, yyleng, yytext);
}




