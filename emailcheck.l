%{
#include <stdio.h>
#include <string.h>

/* Email validation rules:
 * 1. Must have a username before the @ symbol
 * 2. Username can contain letters, digits, dots, underscores, percent, plus, and hyphen
 * 3. Username must not start or end with a dot
 * 4. Username can't have consecutive dots
 * 5. Must have a domain after @ symbol
 * 6. Domain must contain a top-level domain (TLD) after a dot
 * 7. TLD must be between 2-10 characters
 * 8. No spaces or special characters outside the allowed set
 */
%}

%%
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10} { 
    /* Check for consecutive dots which aren't allowed */
    char *at_pos = strchr(yytext, '@');
    int username_length = at_pos - yytext;
    
    if (strstr(yytext, "..") == NULL && 
        yytext[0] != '.' && 
        yytext[strlen(yytext)-1] != '.' &&
        at_pos != NULL &&
        username_length > 0 &&
        *(at_pos-1) != '.') {
        printf("%s is a valid email\n", yytext);
    } else {
        printf("%s is an invalid email (invalid format)\n", yytext);
    }
}

^@.*                         { printf("%s is an invalid email (missing username)\n", yytext); }
.*@$                         { printf("%s is an invalid email (missing domain)\n", yytext); }
.*@[^.]*$                    { printf("%s is an invalid email (missing TLD)\n", yytext); }
.*@@.*                       { printf("%s is an invalid email (double @ symbol)\n", yytext); }
.*[[:space:]].*              { printf("%s is an invalid email (contains spaces)\n", yytext); }
[^@]*                        { printf("%s is an invalid email (missing @ symbol)\n", yytext); }
.+                           { printf("%s is an invalid email (invalid format)\n", yytext); }

%%

int main() {
    FILE *file = fopen("cases", "r");
    char line[256];
    
    if (file == NULL) {
        printf("Enter an email address: ");
        yylex();
        return 0;
    }
    
    printf("Email Validation Results:\n");
    printf("-----------------------\n");
    
    while (fgets(line, sizeof(line), file)) {
        /* Remove newline character if present */
        size_t len = strlen(line);
        if (len > 0 && line[len-1] == '\n') {
            line[len-1] = '\0';
        }
        
        /* Skip empty lines and comments */
        if (strlen(line) == 0 || line[0] == '\n') continue;
        if (line[0] == '/' && line[1] == '/') continue;
        
        printf("Testing: %s\n", line);
        YY_BUFFER_STATE buffer = yy_scan_string(line);
        yylex();
        yy_delete_buffer(buffer);
        printf("\n");
    }
    
    fclose(file);
    return 0;
}

int yywrap() {
    return 1;
}