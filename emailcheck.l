/* 
 * Email Validation using Flex
 * This program analyzes strings and determines whether they conform to email address standards.
 */

%{
/* C code section - included at the beginning of the generated C file */
#include <stdio.h>
#include <string.h>

/* Email validation rules:
 * 1. Must have a username before the @ symbol
 * 2. Username can contain letters, digits, dots, underscores, percent, plus, and hyphen
 * 3. Username must not start or end with a dot
 * 4. Username can't have consecutive dots
 * 5. Must have a domain after @ symbol
 * 6. Domain must contain a top-level domain (TLD) after a dot
 * 7. TLD must be between 2-63 characters
 * 8. No spaces or special characters outside the allowed set
 */
%}

/* Rules section - pattern matching rules and associated actions */
%%
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63} { 
    /* Initial regex match for email format with additional validation checks */
    char *at_pos = strchr(yytext, '@');  /* Find position of @ symbol */
    int username_length = at_pos - yytext;  /* Calculate length of username part */
    
    /* Check for additional validation rules that regex alone cannot verify */
    if (strstr(yytext, "..") == NULL &&  /* No consecutive dots */
        yytext[0] != '.' &&              /* Username doesn't start with dot */
        yytext[strlen(yytext)-1] != '.' && /* Email doesn't end with dot */
        at_pos != NULL &&                /* @ symbol exists (redundant due to regex) */
        username_length > 0 &&           /* Username is not empty */
        *(at_pos-1) != '.') {            /* Username doesn't end with dot */
        printf("%s is a valid email\n", yytext);
    } else {
        printf("%s is an invalid email (invalid format)\n", yytext);
    }
}

^@.*                         { printf("%s is an invalid email (missing username)\n", yytext); }  /* Email starts with @ */
.*@$                         { printf("%s is an invalid email (missing domain)\n", yytext); }  /* Email ends with @ */
.*@[^.]*$                    { printf("%s is an invalid email (missing TLD)\n", yytext); }  /* No dot after @ */
.*@@.*                       { printf("%s is an invalid email (double @ symbol)\n", yytext); }  /* Contains multiple @ */
.*[[:space:]].*              { printf("%s is an invalid email (contains spaces)\n", yytext); }  /* Contains whitespace */
[^@]*                        { printf("%s is an invalid email (missing @ symbol)\n", yytext); }  /* No @ symbol */
.+                           { printf("%s is an invalid email (invalid format)\n", yytext); }  /* Catch-all rule */

%%

/* C code section - included at the end of the generated C file */
int main() {
    FILE *file = fopen("cases", "r");  /* Open test cases file */
    char line[256];
    
    if (file == NULL) {
        /* If file can't be opened, process input from stdin */
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
        /* Create a buffer for the scanner to read from the string */
        YY_BUFFER_STATE buffer = yy_scan_string(line);
        yylex();  /* Process the string */
        yy_delete_buffer(buffer);  /* Clean up the buffer */
        printf("\n");
    }
    
    fclose(file);
    return 0;
}

/* yywrap function is called when EOF is reached */
int yywrap() {
    return 1;  /* Return 1 to indicate end of input processing */
}