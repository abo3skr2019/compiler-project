/* 
 * Character Identifier using Flex
 * This program analyzes characters and classifies them as:
 * - Letters (a-z, A-Z)
 * - Digits (0-9)
 * - Other characters
 */

%{
/* C code section - included at the beginning of the generated C file */
#include <stdio.h>
%}

/* Rules section - pattern matching rules and associated actions */
%%
[a-zA-Z]     { printf("%s is a letter\n", yytext); }  /* Match any uppercase or lowercase letter */
[0-9]        { printf("%s is a digit\n", yytext); }   /* Match any digit */
.            { printf("%s is not a letter or digit\n", yytext); }  /* Match any other character */
%%

/* C code section - included at the end of the generated C file */
int main() {
    printf("Enter a string: ");  /* Prompt for user input */
    yylex();                     /* Start the lexical analyzer - processes characters */
    return 0;
}

/* yywrap function is called when EOF is reached */
int yywrap() {
    return 1;  /* Return 1 to indicate end of input processing */
}
