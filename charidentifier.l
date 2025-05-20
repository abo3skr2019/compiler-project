%{
#include <stdio.h>
%}

%%
[a-zA-Z]     { printf("%s is a letter\n", yytext); }
[0-9]        { printf("%s is a digit\n", yytext); }
.            { printf("%s is not a letter or digit\n", yytext); }
%%

int main() {
    printf("Enter a string: ");
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
