%{
	//#include <*.h>
	#include <iostream>
	#include <vector>
	#include <string.h>
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
	
	//struct used for read and write in BODY, default to non-array varible
	struct identifier {
		string ident;
		bool isArray = false;
		string index = "0";
	};
	
	vector<string> functions_symbol_table;

	//used to be scope_symbol_table here
	vector<identifier> sc_symbol_table;	//clear after each function is done
	//we may need a vector table for numbers idk yet...

	vector<identifier> instruction_vals;	//store var: temp values for a single instruction in body. This should clear after every instruction. Used for plural READ and WRITE
	vector<string> expression_vals;	//store expression: temp values for a single instruction in body. This should clear after every instruction. Used for plural parameters for a function in expressions

	int stackCounter = 1;	//used for mulit-declaration, may use for stacks in statements, used in PARAMS and LOCALS
	int temp_count = 0;	//track and number the number of temporary varibles produced, used in BODY 
	int label_count = 0;


	int semicolonCount = 0;	//for debuggin purposes in BODY
	bool writeToArray = false;
	bool readFromArray = false;
	bool pushArray=false;


	//temporaries...
	//newtemp vectors
	vector<string> temp_var;
	//newtemp functions
//	vector<string> temp_func;
	//newlabel vectors
	vector<string> label_var;
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


	//takes a string and checks sc_symbol_table for the index and returns identifier
	// IF in scope return: index int
	// IF not in scope exit(0) the program
	int indexOf(string s) {
		for(int i = 0; i < sc_symbol_table.size(); i++) {
			if(s == sc_symbol_table[i].ident) {
				return i;
			}
		}
		//Error
		string errorMsg = ("Identifier '" + s + "' was not found");
		yyerror(errorMsg.c_str());
	}



	//returns string and increments the tempcount no need to worry about it in the cout statment, don't use temp count for indexing, use size() instead
	string newTemp(){
		string s = "_temp_" + to_string(temp_count++);
		temp_var.push_back(s);
		cout << ". " << s << endl;
		return s;
	}
	
	string newLabel(){
		string s = "_label_" + to_string(label_count++);
		label_var.push_back(s);
		//cout << ". " << s << endl;
		return s;
	}


//checks to see if a function id has been defined yet or not. will exit automatically if it is not found
	bool functionIdExists(string a) {
		if  (find(functions_symbol_table.begin(), functions_symbol_table.end(), string(a)) != functions_symbol_table.end()){
			return true;
		}
		else {
			string errorMsg = "\n\nError: no function of ID: " + a + "() was found";
			yyerror(errorMsg.c_str());	//throw into strdup() line number
		}
	}




// does a check before the push to make sure the id is non-existant within the current scope
	void pushToScope(identifier a) {
		for(int i = 0; i < sc_symbol_table.size(); i++) {
			if(a.ident == sc_symbol_table[i].ident){
				//yyerror("Error: somewhere there already exists an ID: " + a.ident);
				//exit(0);
			}
		}

		sc_symbol_table.push_back(a);
	}




%}

//%define api.value.type variant

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

//%token <std::string> IDENT
//%token <int> NUMBER

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
%type <id> identifier identifiers expression multiplicative-expr term var comp relation-expr relation-and-expr bool-expr pre-bool-expr-then pre-bool-expr-then-statements-else while pre-bool-expr-beginloop do semicolon-label1 bool-expr-semicolon-label2
%type <num> number 



%%
prog_start: %empty	{/*cout << "prog_start -> epsilon\n";*/ /* do we have an error here? NO, I dont think so... */}
		| function prog_start {/*printf("prog_start -> function prog_start\n");*/ 
	functionIdExists("main"); //make sure main() is a function
};

// function: FUNCTION identifier SEMICOLON	BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {};

function: function_id SEMICOLON	params locals body {
	cout << "endfunc" << endl << endl;
	//instruction_list.clear();
	sc_symbol_table.clear();	//clear local scope of function
};

function_id: FUNCTION identifier {
	//we dont use this since this is the first one
	cout << "func " + string($2) << endl;
	if (find(functions_symbol_table.begin(), functions_symbol_table.end(), string($2)) != functions_symbol_table.end()) {
		//show error code that the function identifier is already in use
		char temp[128];
		snprintf(temp, 128, "Redeclaration of function %s", $2);
		yyerror(temp);
		exit(0);
	}
	else {
		functions_symbol_table.push_back(string($2));
	}
	sc_symbol_table.clear();//the table should only contain the func id, remove it!!!
};


params: BEGIN_PARAMS declarations END_PARAMS {
	//cout << "PARAMS^" << endl;
	for(int i = 0; i < sc_symbol_table.size(); i++) {
		cout << "= " << sc_symbol_table[i].ident << ", $" << i << endl; 
	}
};

locals: BEGIN_LOCALS declarations END_LOCALS {
	//cout << "LOCALS^" << endl;
//	//just for debugging
//	cout << endl << endl << endl;
//	for(int i = 0; i < scope_symbol_table.size(); i++){
//		cout << scope_symbol_table[i] << endl;
//	}
	//cout << "(BEGIN BODY)" << endl;
};

body: BEGIN_BODY statements END_BODY {
	//cout << "(BODY HERE)" << endl;
	/*for(int i = 0; i < instruction_list.size(); i++) {
		cout << instruction_list[i] << endl;
	}
	instruction_list.clear();*/
};







//---------------- LOCAL & PARAM STUFF BELOW ---------------------------









identifier: IDENT {
//printf("identifier -> IDENT %s\n", $1);
	//cout << $1 << endl;
	$$ = $1;	//pushes id up the tree, this must remain simple!!!
};

identifiers: identifier	{
	//cout << $1 << endl;
	$$ = $1;//must be passed up tree since it can be integer ID or function ID
	identifier a;
	a.ident = $$;
	pushToScope(a);
}
		| identifiers COMMA identifier {
	//cout << $3 << endl;
	identifier a;
	a.ident = $3;
	pushToScope(a);
	stackCounter++;
};

number: NUMBER {
//printf("number -> NUMBER %d\n", $1);
	$$ = $1;
};

declaration: identifiers COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {
	//instruction_list.push_back(".[] " + string($1) + ", " + to_string($5));
	//cout << $1 << endl;
	//pushToScope($1);
	
	for(int i = sc_symbol_table.size() - stackCounter; i < sc_symbol_table.size(); i++){
		sc_symbol_table[i].isArray = true;
		cout << ".[] " << sc_symbol_table[i].ident << ", " << to_string($5) << endl;
	}
	stackCounter = 1;
}
		| identifiers COLON INTEGER {
	//instruction_list.push_back(". " + string($1));
	//cout << $1 << endl;
	//pushToScope($1);
	for(int i = sc_symbol_table.size() - stackCounter; i < sc_symbol_table.size(); i++) {
		cout << ". " << sc_symbol_table[i].ident << endl;
	}
	stackCounter = 1;
	
};

declarations: %empty {/* leave blank */}
		| declaration SEMICOLON declarations {
	//CREATE VECTOR of VECTORS... new scope add to the stack
	//...
	//... just thought about this. Maybe keep this empty
	
};





//------------------- BODY STUFF BELOW ---------------------------------







statements: statement SEMICOLON statements {/* leave blank */}
		| statement SEMICOLON {/* leave blank */};


statement: var ASSIGN expression {
	//instruction_vals should really only be used for multiple things like vars and expressions but I'll use it here... idk

	identifier id = sc_symbol_table[indexOf($1)];	//this is a cheese... idc... dont use index to refernece the actual array being created	
	if(id.isArray) {
		cout << "[]= " << id.ident << ", " << id.index << ", " << $3 << endl;
	}
	else {
		cout << "= " << $1 << ", " << $3 << endl;
	}

//	//cout << pushArray << "start\n";
//	for(int i = 0; i < instruction_vals.size(); i++) {
//		cout << "THIS: " << instruction_vals[i].ident << endl;
//	}
//	//cout << "end\n";

	//cout << "= " << $1 << ", " << $3 << endl;	
	//while it's graceful we need a way to determine between array or non-array identifer only for var. Dont worry about expression a temp value will be pushed up into expression
	
	//reset and default
	instruction_vals.clear();
	expression_vals.clear();
	writeToArray = false;
	readFromArray = false;
}
	//changed: IF bool-expr THEN statements ENDIF
		| IF pre-bool-expr-then statements ENDIF {
	cout << ": " << $2 << endl;//this is the last label to skip THEN
	instruction_vals.clear();
	expression_vals.clear();
}
	//changed: IF bool-expr THEN statements ELSE statements ENDIF
		| IF pre-bool-expr-then-statements-else statements ENDIF {
	cout << ": " << $2 << endl;
	instruction_vals.clear();
	expression_vals.clear();
}
		| while pre-bool-expr-beginloop statements ENDLOOP {
	cout << ":= " << $1 << endl;
	cout << ": " << $2 << endl;
	instruction_vals.clear();
	expression_vals.clear();
}
		| do BEGINLOOP statements ENDLOOP WHILE bool-expr {
	string t = $6;
	cout << "?:= " << $1 << ", " << t << endl;
	instruction_vals.clear();
	expression_vals.clear();
}
		| FOR var ASSIGN number semicolon-label1 bool-expr-semicolon-label2 var ASSIGN expression BEGINLOOP statements ENDLOOP {
	//whatever is in var ASSIGN expression needs to go here
	identifier id = sc_symbol_table[indexOf($7)];
	if(id.isArray) {
		cout << "[]= " << id.ident << ", " << id.index << ", " << $9 << endl;
	}
	else {
		cout << "= " << $7 << ", " << $9 << endl;
	}
	instruction_vals.clear();
	expression_vals.clear();
	writeToArray = false;
	readFromArray = false;
	
	//after that we can just cout labels
	string l1 = $5;
	string l3 = $6;
	cout << ":= " << l1 << endl;
	cout << ": " << l3 << endl;
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
	expression_vals.clear();
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
	expression_vals.clear();
}
		| CONTINUE {
	//this doesnt really do anything. we can leave it as is
	instruction_vals.clear();
	expression_vals.clear();
}
		| RETURN expression {
	cout << "ret "<< $2 << endl;
	instruction_vals.clear();
	expression_vals.clear();
};




//	***************************************************************
//	*******  Create a label making rules only for NON-LOOPS *******
//	***************************************************************

pre-bool-expr-then: bool-expr THEN {
	string l1 = newLabel();
	string l2 = newLabel();
	string t = $1;
	cout << "?:= "<< l1 << ", " << t << endl;	//then label
	cout << ":= " << l2 << endl;	//skip label
	cout << ": " << l1 << endl;
	$$ = strdup(l2.c_str());	//pass up the skip label
	//when id's get made this will populate. but wihtout this it will disturb the statements in IF so we should clear here
	instruction_vals.clear();
	expression_vals.clear();
};

pre-bool-expr-then-statements-else: pre-bool-expr-then statements ELSE {
	string l3 = newLabel();
	string l2 = $1;
	cout << ":= " << l3 << endl;
	cout << ": " << l2 << endl;
	$$ = strdup(l3.c_str());
	instruction_vals.clear();
	expression_vals.clear();
}


//	***************************************************************
//	*******  Create a label making rules only for LOOPS ***********
//	***************************************************************

//	while
pre-bool-expr-beginloop: bool-expr BEGINLOOP {
	string l1 = newLabel();
	string l2 = newLabel();
	string t = $1;
	cout << "?:= " << l1 << ", " << t << endl;
	cout << ":= " << l2 << endl;
	cout << ": " << l1 << endl;
	$$ = strdup(l2.c_str());
	//is this the same thing... yeah it is oh well
	instruction_vals.clear();
	expression_vals.clear();
};

while: WHILE{
	string l3 = newLabel();
	cout << ": " << l3 << endl;
	$$ = strdup(l3.c_str());
};

//	do-while
do: DO {
	string l1 = newLabel();
	cout << ": " << l1 << endl;
	$$ = strdup(l1.c_str());
};

//	for loop
semicolon-label1: SEMICOLON {
	string l1 = newLabel();
	cout << ": " << l1 << endl;
	$$ = strdup(l1.c_str());
};

bool-expr-semicolon-label2: bool-expr SEMICOLON {
	string l2 = newLabel();
	string l3 = newLabel();
	string t = $1;
	cout << "?:= " << l2 << ", " << t << endl;
	cout << ":= " << l3 << endl;
	cout << ": " << l2 << endl;
	$$ = strdup(l3.c_str());
};










bool-expr: relation-and-expr {/* leave blank */}
		| relation-and-expr OR bool-expr {
	string t = newTemp();
	cout << "|| " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
};


relation-and-expr: relation-expr {/* leave blank */}
		| relation-expr AND relation-and-expr {
	string t = newTemp();
	cout << "&& " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
};



relation-expr: expression comp expression {
	string t = newTemp();
	cout << $2 << " " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
}
		| TRUE {
	string temp = "1";
	$$ = strdup(temp.c_str());
}
		| FALSE {
	string temp = "0";
	$$ = strdup(temp.c_str());
}
		| L_PAREN bool-expr R_PAREN {
	$$ = $2;
}
		| NOT relation-expr{
	string t = newTemp();
	cout << "! " << t << ", " << $2 << endl;
	$$ = strdup(t.c_str());
}
//		| NOT expression comp expression {
//	//This one is unclear what they are asking for...???
//	//couldnt we rewrite it as NOT relation-expr
//	//what about NOT expression
//	string t = newTemp();
//	cout << "! " << t << ", " << $2 << endl;
//	$$ = strdup(t.c_str());
//}
//		| NOT TRUE {
//	string temp = "0";
//	$$ = strdup(temp.c_str());
//}
//		| NOT FALSE {
//	string temp = "1";
//	$$ = strdup(temp.c_str());
//}
//		| NOT L_PAREN bool-expr R_PAREN {}
;

comp: EQ {
	string t = "==";
	$$ = strdup(t.c_str());
}
		| NEQ {
	string t = "!=";
	$$ = strdup(t.c_str());
}
		| LT {
	string t = "<";
	$$ = strdup(t.c_str());
}
		| GT {
	string t = ">";
	$$ = strdup(t.c_str());
}
		| LTE {
	string t = "<=";
	$$ = strdup(t.c_str());
}
		| GTE {
	string t = ">=";
	$$ = strdup(t.c_str());
};



	//the only time plural expressions is used is during funciton parameters, this populate the expression array
expressions: expression {
	expression_vals.push_back($1);
}
		| expression COMMA expressions {/* leave blank */}
;

expression: multiplicative-expr {
	$$ = $1;
}
		| multiplicative-expr ADD expression {
	string t = newTemp();
	cout << "+ " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
}
		| multiplicative-expr SUB expression {
	string t = newTemp();
	cout << "- " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
};


multiplicative-expr: term {
	$$ = $1;
}
		| term MULT multiplicative-expr {
	string t = newTemp();
	cout << "* " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
}
		| term DIV multiplicative-expr {
	string t = newTemp();
	cout << "/ " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
}
		| term MOD multiplicative-expr {
	string t = newTemp();
	cout << "% " << t << ", " << $1 << ", " << $3 << endl;
	$$ = strdup(t.c_str());
}
;

	//term values should place into temps
term: var {

	string t = newTemp();
	//identifier a = instruction_vals[instruction_vals.size() - 1];
	
	identifier id = sc_symbol_table[indexOf($1)];
	//we could have just used instruction_vals.(top).isArray right? NO!!!
	if(id.isArray){
		cout << "=[] " << t << ", " << id.ident << ", " << id.index << endl;
	}
	else {
		cout << "= " << t << ", " << $1 << endl;
	}
	$$ = strdup(t.c_str());
	pushArray = false;
	
//cout << "term -> var: " << $$ << endl;
	
//	if(pushArray){
//		string t = newTemp();
//		cout << "=[] " << t << ", " << $1 << ", " << instruction_vals[instruction_vals.size() - 1].index << endl;
//		$$ = strdup(t.c_str());
//		pushArray = false;
//	}
//	else {
//		string t = newTemp();
//		cout << "= " << t << ", " << $1 << endl;
//		$$ = strdup(t.c_str());
//	}
}
		| number {
	string t = newTemp();
	cout << "= " << t << ", " << to_string($1) << endl;
	$$ = strdup(t.c_str());
//	cout << "term -> number: " << $$ << endl;
}
		| L_PAREN expression R_PAREN {
	$$ = $2;
}
		| SUB var %prec UMINUS {}
		| SUB number %prec UMINUS {
//	string t = newTemp();
//	cout << "= " << t << ", -" << to_string($2) << endl;//how do we post negative values???
//	$$ = strdup(t.c_str());
}
		| SUB L_PAREN expression R_PAREN %prec UMINUS {}
		| identifier L_PAREN expressions R_PAREN {
	//check if there exists this function_id, this function call will exit if not
	if (functionIdExists($1)) {
		//start at 1 since index 0 will have the function id
		for(int i = 0; i < expression_vals.size(); i++){
			cout << "param " << expression_vals[i] << endl;
		}
		//instruction_vals.clear();
		expression_vals.clear();
	}
	string t = newTemp();
	cout << "call " << $1 << ", " << t << endl;
	$$ = strdup(t.c_str());
}
		| identifier L_PAREN R_PAREN {
	if (functionIdExists($1)){
		string t = newTemp();
		cout << "call " << $1 << ", " << t << endl;
		$$ = strdup(t.c_str());
	}
}
;

//we'll have (var: identifier) handle purals with push_back() - No can do here, it must be made in singular var. leave blank for now
vars: var {/* leave blank... (it would be nice to populate vector here but we can't since we need to recieve 2 values of input for array type identifiers) */}
		|var COMMA vars {/* leave blank... */};


//These should populate a vector (to make array types work) AND if needed return the id
var: identifier {
	//indexOf: checks to see if id exists
	identifier &a = sc_symbol_table[indexOf($1)];
	//checks IS NOT array type otherwise yyerror()
	if(a.isArray){
		yyerror("Identifier is Array type and requires [index]");
	}
	else {
		identifier a;
		a.ident = $1;
		instruction_vals.push_back(a);
		$$ = $1;
	}
}
		| identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
	//indexOf: checks to see if id exists
	identifier &a = sc_symbol_table[indexOf($1)];
	//yeah this is the only time i'll use a de-ref
	//AND IS array type otherwise yyerror()
	if(a.isArray){
		a.ident = $1;
		a.isArray = true;
		a.index = $3;	//no checking index that will be a runtime error
	}
	else {
		yyerror("Identifier is not array type");
	}
	//cout << "HELP: " << a.ident << a.index << endl << endl;
	instruction_vals.push_back(a);
//	for(int i = 0; i < instruction_vals.size(); i++){
//		cout << instruction_vals[i].ident << endl;
//	}
//	cout << "CHECK: " << sc_symbol_table[indexOf($1)].index << endl << endl;
	pushArray = true;	//we know when to push an array type, only used if we have a array type on the right hand side of a statement
	$$ = $1;
};







//  **************************************************************
//  ************************ E N D *******************************
//  **************************************************************
//  **************************************************************

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
	printf("**ERROR: Line %d, position %d: %s\n", line, column, MSG);	//error position not outputting correctly in some cases
	//printf("** Line %d, position %d: \n", line, MSG);//error position not outputting correctly in some cases, maybe i read it worng, just double check???
	//printf("");
	exit(0);
	
	//printf("Error at line %d, column %d: unrecognized symbol \"%.*s\"\n",line, column, yyleng, yytext);
}













