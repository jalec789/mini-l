# mini-l
Class project for UCR class CS152 compilers

#### Phase 1:
https://www.cs.ucr.edu/~cxu009/teaching/CS152-winter20/webpages1/phase1_lexer.html
Just a lex file. Nothing really intersting.

#### Phase 2:
https://www.cs.ucr.edu/~cxu009/teaching/CS152-winter20/webpages2/phase2_parser.html

Sample code is provided in Phase3/SampleCode. Use the .min files only and run with:
```
make
./parser [your_code.min]
```
And you'll get the order of the parse tree, remember to read it from the bottom up if you want to start at the most Parent node.

(PDF does not have the NUMBERS production)

#### Phase 3:
https://www.cs.ucr.edu/~cxu009/teaching/CS152-winter20/webpages3/phase3_code_generator.html


## How to run Phase 3
Sample code is provided in Phase3/SampleCode. The interpreter .mil_run was provided by professor. Make the .mil code using ./parser and store into some random txt file. Then using that txt file run ./mil_run with the given interpreter language output.

```
make
./parser [your_code.min] > [some_random_filename.txt]
./mil_run [some_random_filename.txt] 
```

To view the interpreter code
```
make
./parser [your_code.min]
```
