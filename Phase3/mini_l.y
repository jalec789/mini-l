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
	//we may need a vector table for numbers idk yet...

	//struct used for read and write in BODY, default to non-array varible
	struct identifier {
		string ident;
		bool isArray = false;
		int index = 0;
	};

	vector<identifier> instruction_vals;	//store var or temp values for a single instruction in body. This should clear after every instruction

	int stackCounter = 1;	//used for mulit-declaration, may use for stacks in statements, used in PARAMS and LOCALS
	int temp_count = 0;	//track and number the number of temporary varibles produced, used in BODY


	int semicolonCount = 0;	//for debuggin purposes in BODY


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
//	vector<string> instruction_list;
//	int listId = 0;	//for every line added to list for a function


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


//checks to see if a function id has been defined yet or not. will exit automatically if it is not found
	bool functionIdExists(string a) {
		if  (find(functions_symbol_table.begin(), functions_symbol_table.end(), string(a)) != functions_symbol_table.end()){
			return true;
		}
		else {
			cerr << "\n\nError: no function of ID: " << a << "() was found" << endl;
			exit(0);	//throw into strdup() line number
		}
	}




// does a check before the push to make sure the id is non-existant within the current scope
	void pushToScope(string a) {
		if (find(scope_symbol_table.begin(), scope_symbol_table.end(), string(a)) != scope_symbol_table.end()) {
		//show error code that the identifier is already in use... and exit???
		//...
			cerr << "\n\nError: somewhere there already exists an ID: " << a << endl;
			exit(0);	//throw into strdup() line number
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

	//anything that utilizes $$ should be a type
%type <id> identifier identifiers var
%type <num> number expression multiplicative-expr term



%%
prog_start: %empty	{/*cout << "prog_start -> epsilon\n";*/ /* do we have an error here??? */}
		| function prog_start {/*printf("prog_start -> function prog_start\n");*/ /* Also make sure to check the function symbol table look for the main function??? */
};

// function: FUNCTION identifier SEMICOLON	BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {};

function: function_id SEMICOLON	params locals body {
	/* for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}*/
	cout << "endfunc" << endl << endl;
	//instruction_list.clear();
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
 		char temp[128];
    		snprintf(temp, 128, "Redeclaration of function %s", $2);
    		yyerror(temp);
		exit(0);
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
};

locals: BEGIN_LOCALS declarations END_LOCALS {
	//cout << "LOCALS^" << endl;
//	//just for debugging
//	cout << endl << endl << endl;
//	for(int i = 0; i < scope_symbol_table.size(); i++){
//		cout << scope_symbol_table[i] << endl;
//	}
	cout << "(BEGIN BODY)" << endl;
};

body: BEGIN_BODY statements END_BODY {
	//cout << "(BODY HERE)" << endl;
	/*for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}
	instruction_list.clear();*/
};







//---------------------- LOCAL & PARAM STUFF BELOW ---------------------------









identifier: IDENT { 
	//cout << $1 << endl;
	$$ = $1;	//pushes id up the tree, this must remain simple!!!
};

identifiers: identifier	{
	//cout << $1 << endl;
	$$ = $1;//must be passed up tree since it can be integer ID or function ID
	pushToScope($$);
}
		| identifiers COMMA identifier {
	//cout << $3 << endl;
	pushToScope($3);
	stackCounter++;
};

number: NUMBER {
	$$ = $1;
};

declaration: identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {
	//instruction_list.push_back(".[] " + string($1) + ", " + to_string($5));
	//cout << $1 << endl;
	//pushToScope($1);
	for(int i = scope_symbol_table.size() - stackCounter; i < scope_symbol_table.size(); i++){
		cout << ".[] " << scope_symbol_table[i] << ", " << to_string($5) << endl;
	}
	stackCounter = 1;
}
		| identifiers COLON INTEGER {
	//instruction_list.push_back(". " + string($1));
	//cout << $1 << endl;
	//pushToScope($1);
	for(int i = scope_symbol_table.size() - stackCounter; i < scope_symbol_table.size(); i++) {
		cout << ". " << scope_symbol_table[i] << endl;
	}
	stackCounter = 1;
	
};

declarations: %empty {}
		| declaration SEMICOLON declarations {
	//CREATE VECTOR of VECTORS... new scope add to the stack
	//...
	//... just thought about this. Maybe keep this empty
	
};





//-------------------------- BODY STUFF BELOW ---------------------------------







	//can statments be empty???
statements: statement SEMICOLON statements {}
		| statement SEMICOLON {};


statement: var ASSIGN expression {
	//...
	instruction_vals.clear();
}
		| IF bool-expr THEN statements ENDIF {
	//...
	instruction_vals.clear();
}	
		| IF bool-expr THEN statements ELSE statements ENDIF {
	//...
	instruction_vals.clear();
}
		| WHILE bool-expr BEGINLOOP statements ENDLOOP {
	//...
	instruction_vals.clear();
}
		| DO BEGINLOOP statements ENDLOOP WHILE bool-expr {
	//...
	instruction_vals.clear();
}
		| FOR var ASSIGN number SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP {
	//...
	instruction_vals.clear();
}
		| READ vars {
	for(int i = 0; i < instruction_vals.size(); i++){
		if(!instruction_vals[i].isArray){
			cout << ".< " << instruction_vals[i].ident << endl;
		}
		else {
			cout << ".[]< " << instruction_vals[i].ident << ", " << instruction_vals[i].index << endl;
		}
	}
	instruction_vals.clear();
}
		| WRITE vars {
	//this is not working correctly right now but I believe we need to complete assign and others for it to look correct
	for(int i = 0; i < instruction_vals.size(); i++){
		if(!instruction_vals[i].isArray){
			cout << ".> " << instruction_vals[i].ident << endl;
		}
		else {
			cout << ".[]> " << instruction_vals[i].ident << ", " << instruction_vals[i].index << endl;
		}
	}
	instruction_vals.clear();
}
		| CONTINUE {
	//...
	instruction_vals.clear();
}
		| RETURN expression {
	//...
	instruction_vals.clear();
}
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

expression: multiplicative-expr {/* new temp is solution */}
		| multiplicative-expr ADD expression {/* new temp is solution */}
		| multiplicative-expr SUB expression {/* new temp is solution */}
;


multiplicative-expr: term {/* new temp is solution */}
		| term MULT multiplicative-expr {/* new temp is solution */}
		| term DIV multiplicative-expr {/* new temp is solution */}
		| term MOD multiplicative-expr {/* new temp is solution */}
;

	//remember that a function call is a term. should we add more rules???
term: var {}
		| number {/* new temp is solution */}
		| L_PAREN expression R_PAREN {/* new temp is solution */}
		| SUB var %prec UMINUS {}
		| SUB number %prec UMINUS {}
		| SUB L_PAREN expression R_PAREN %prec UMINUS {/* new temp is solution */}
		| identifier L_PAREN expressions R_PAREN {
	//check if there exists this function_id
	if (functionIdExists($1)) {
		
		//...
	}
}
		| identifier L_PAREN R_PAREN {}
;


vars: var {}
		|var COMMA vars {};

var: identifier {
	//check to see if id exists, if not error and exit...
	identifier a;
	a.ident = $1;
	instruction_vals.push_back(a);
}
		| identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
	//check to see if id exists, if not error and exit
	identifier a;
	a.ident = $1;
	a.isArray = true;
	a.index = $3;
	instruction_vals.push_back(a);
};



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




