%{
	//#include <*.h>
	#include <iostream>
	#include <vector>
	#include <string>
	#include <stdio.h>
	#include <stdlib.h>
	#include <algorithm>
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
	//we may need one for numbers idk yet...
	int stackerId = 1;


	//temporaries...
	//newtemp vectors
//	vector<string> temp_var;
//	//newtemp functions
//	vector<string> temp_func;
//	//newlabel vectors
//	vector<string> label_var;
//	//newlabel functions
//	vector<string> label_func;


	//interpreter string for each function
	vector<string> instruction_list;
	int listId = 0;	//for every line added to list for a function


////handles the exit within the function. should save overhead in the code. Also sometimes we want to check without pushing... wait that doesnt make sense (we shouldnt exit if we want to confirm a varible exists... okay dont make this yet, we'll still need it for the body to check if a varible exists or not)
//	bool checkScope(string a) {
//		if (find(scope_symbol_table.begin(), scope_symbol_table.end(), string(a)) != scope_symbol_table.end()) {
//		//show error code that the identifier is already in use... and exit???
//		//...
//			cerr << "\n\nERROR somewhere. Current ID: " << a << endl;
////			for(int i = 0; i < scope_symbol_table.size(); i++){
////				cout << scope_symbol_table[i] << endl;
////			}
//			exit(0);
//		}
//		else {
//			scope_symbol_table.push_back(a);
//		}
//	}

// does a check before the push to make sure id is non-existant within the scope
	void pushToScope(string a) {
		if (find(scope_symbol_table.begin(), scope_symbol_table.end(), string(a)) != scope_symbol_table.end()) {
		//show error code that the identifier is already in use... and exit???
		//...
			cerr << "\n\nERROR somewhere. Current ID: " << a << endl;
//			for(int i = 0; i < scope_symbol_table.size(); i++){
//				cout << scope_symbol_table[i] << endl;
//			}
			exit(0);
		}
		else {
			scope_symbol_table.push_back(a);
		}
	}

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
};

/* function: FUNCTION identifier SEMICOLON	BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {

	//string identify;
	
	cout << "func " << $2 << endl;
	for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}
	instruction_list.clear();
	scope_symbol_table.clear();
}; */


function: function_id SEMICOLON	params locals body {
	/* for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}*/
	cout << "(FUNCTION DONE)" << endl << endl;

	instruction_list.clear();
	scope_symbol_table.clear();
};

function_id: FUNCTION identifier {
	//we dont use this since this is the first one
	/*for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}*/

	//instruction_list.push_back("func " + string($2));
	cout << "func " + string($2) << endl;


	if (find(functions_symbol_table.begin(), functions_symbol_table.end(), string($2)) != functions_symbol_table.end()) {
		//show error code that the function identifier is already in use... and exit???
		//...
	}
	else {
		functions_symbol_table.push_back(string($2));
	}

	scope_symbol_table.clear();//the table should only contain the func id, remove it!!!

};


params: BEGIN_PARAMS declarations END_PARAMS {

	//cout << "PARAMS^" << endl;
	for(int i = 0; i < scope_symbol_table.size(); i++) {
		cout << "= " << scope_symbol_table[i] << ", $" << i << endl; 
	}

	//paramIndex = scope_symbol_table.size(); //stackerId (changed)
	//instruction_list.clear();

	//We might need to track declarations with a list idk...

	//Now we can print $0 here for param values...
	//...
};

locals: BEGIN_LOCALS declarations END_LOCALS {

	//cout << "LOCALS^" << endl;
	//This is the only reason we have int stackerId defined gloablly...
//	for(int i = stackerId; i < scope_symbol_table.size(); i++) {
//		cout << ". " << scope_symbol_table[i] << endl;
//	}

};

body: BEGIN_BODY statements END_BODY {
	cout << "(BODY HERE)" << endl;
	/*for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}
	instruction_list.clear();*/

};



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
	$$ = $1;
	pushToScope($$);
//	cout << $1 << endl;
	//$$.place = strdup($1.place); //must be passed up tree since it can be integer ID or function ID
	
}
		| identifiers COMMA identifier {
	pushToScope($3);
//	cout << $3 << endl;
	stackerId++;
};


number: NUMBER {
	$$ = $1;
};


declaration: identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {
	//instruction_list.push_back(".[] " + string($1) + ", " + to_string($5));
	//cout << $1 << endl;
	//pushToScope($1);
	for(int i = scope_symbol_table.size() - stackerId; i < scope_symbol_table.size(); i++){
		cout << ".[] " << scope_symbol_table[i] << ", " << to_string($5) << endl;
	}
	stackerId = 1;
}
		| identifiers COLON INTEGER {
	//instruction_list.push_back(". " + string($1));
	//cout << $1 << endl;
	//pushToScope($1);
	for(int i = scope_symbol_table.size() - stackerId; i < scope_symbol_table.size(); i++) {
		cout << ". " << scope_symbol_table[i] << endl;
	}
	stackerId = 1;
	
};

declarations: %empty {}
		| declaration SEMICOLON declarations {
	//CREATE VECTOR of VECTORS... new scope add to the stack
	//...
	//... just thought about this. Maybe keep this empty
	
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


	//just for debugging
//	cout << endl << endl << endl;
//	for(int i = 0; i < functions_symbol_table.size(); i++){
//		cout << functions_symbol_table[i] << endl;
//	}




	return 0;
}


void yyerror(const char *MSG) {
	printf("** Line %d, position %d: %s\n", line, column, MSG);
	//printf("");
	

	//this did not work with strdup ???
	//printf("Error at line %d, column %d: unrecognized symbol \"%.*s\"\n",line, column, yyleng, yytext);
}




