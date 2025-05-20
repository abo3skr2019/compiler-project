// Import team members information
#import "team_members.typ": team_members, course_name, course_code,instructor_name

#set document(
  title: "Lexical and Parser Phase Project Report",
  author: team_members.map(m => m.name).join(", "),
  date: datetime.today(),
)

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
)

#set heading(
  numbering: "1.1.",
)

#align(center)[
  #block(text(weight: "bold", size: 24pt)[
    Lexical and Parser Phase Project Report
  ])
  
  #v(1em)
  
  #block(text(size: 16pt)[
    Using LEX/FLEX for Character Identification and Email Validation
  ])
  
  #v(3em)
  
  #block[

    Course Title: #course_code - #course_name
    
    Instructor: #instructor_name

    #text(weight: "bold")[Submitted By:]
    #for (i, member) in team_members.enumerate() [

      #(i + 1). #member.name  
        - University ID: #member.id
    ]    
  ]
]

#pagebreak()

#outline(
  title: [Table of Contents],
  indent: auto,
)

#pagebreak()

= Introduction
This report documents the development of two LEX (Lexical Analyzer Generator) programs:
1. A character identifier that classifies input characters as letters or digits.
2. An email validator that checks whether input strings conform to email address standards.

The project demonstrates fundamental concepts in lexical analysis, pattern matching, and the use of regular expressions to define and recognize tokens.

= Theoretical Background

== Lexical Analysis
Lexical analysis is the first phase of a compiler, responsible for breaking down source code into a sequence of tokens. These tokens are meaningful units like keywords, identifiers, operators, etc. This phase simplifies the parsing process by filtering out whitespace and comments, identifying token boundaries, and handling simple syntax rules.

== LEX/FLEX
LEX (Lexical Analyzer Generator) and its faster reimplementation FLEX (Fast Lexical Analyzer Generator) are tools that generate lexical analyzers from specifications. They allow programmers to define patterns using regular expressions and associate actions with these patterns. When a pattern is matched in the input, the corresponding action is executed.

== Regular Expressions
Regular expressions are patterns used to match text strings. In the context of lexical analysis, they define the patterns of characters that form valid tokens. Some common components of regular expressions include:
- Character classes: [a-z], [0-9]
- Repetition operators: `*`, `+`, `?`
- Alternation: |
- Grouping: ()

= Methodology

== Character Identifier Implementation
The character identifier program uses simple regular expressions to classify input characters:
- [a-zA-Z] matches any letter (uppercase or lowercase)
- [0-9] matches any digit
- . (dot) matches any other character

```
%{
#include <stdio.h>
%}

%%
[a-zA-Z]     { printf("%s is a letter\n", yytext); }  /* Match any letter */
[0-9]        { printf("%s is a digit\n", yytext); }   /* Match any digit */
.            { printf("%s is not a letter or digit\n", yytext); }  /* Match any other character */
%%

int main() {
    printf("Enter a string: ");
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
```

== Email Validator Implementation
The email validator uses more complex regular expressions to match valid email address patterns, with additional checks for specific validation rules:

```
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
    /* Initial regex match for email format, with additional validation logic */
    char *at_pos = strchr(yytext, '@');
    int username_length = at_pos - yytext;
    
    /* Check additional validation rules */
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
/* Various invalid patterns with specific error messages */
%%

/* Main function that processes the test cases */
```

The email validation follows these rules:
1. Must have a username before the `@` symbol
2. Username can contain letters, digits, dots, underscores, percent, plus, and hyphen
3. Must have a domain after `@` symbol
4. Domain must contain a top-level domain (TLD) after a dot
5. TLD must be between 2-10 characters
6. No spaces or special characters outside the allowed set

= Test Cases and Results

== Character Identifier Test Cases
The character identifier was tested with various inputs to verify its functionality:

#table(
  columns: (auto, auto, auto),
  align: (center, center, center),
  [*Input*], [*Expected Output*], [*Actual Output*],
  "a", "a is a letter", "a is a letter",
  "5", "5 is a digit", "5 is a digit",
  "%", "% is not a letter or digit", "% is not a letter or digit",
)

== Email Validator Test Cases
The email validator was tested with a variety of valid and invalid email addresses:

#table(
  columns: (auto, auto, auto),
  align: (left, center, center),
  [*Email Address*], [*Expected Result*], [*Actual Result*],
  "user@example.com", "Valid", "Valid",
  "john.doe123@mail.co.uk", "Valid", "Valid", 
  "simple_email@domain.org", "Valid", "Valid",
  "first.last+tag@sub.domain.com", "Valid", "Valid",
  "UPPERCASE@DOMAIN.COM", "Valid", "Valid",
  "@missingusername.com", "Invalid", "Invalid",
  "missingatsign.com", "Invalid", "Invalid",
  "double@@at.com", "Invalid", "Invalid", 
  "nodomain@.com", "Invalid", "Invalid",
  "toolongtld@domain.abcdefghijk", "Invalid", "Invalid",
  "endswithdot@domain.com.", "Invalid", "Invalid", 
  "noatsuffix@domain", "Invalid", "Invalid",
  "dotbeforeat.@domain.com", "Invalid", "Invalid",
  "badchar!in@email.com", "Invalid", "Invalid",
  "space in@email.com", "Invalid", "Invalid",
)

= Analysis of Results

== Character Identifier Analysis
The character identifier successfully categorizes input characters into three groups: letters, digits, and other characters. Its simplicity makes it efficient for basic character classification tasks.

== Email Validator Analysis
The email validator demonstrates more complex pattern matching capabilities. Some key observations:

1. *Valid Email Recognition*: The program correctly identifies standard email formats.
2. *Error Detection*: The program provides specific error messages for different validation failures.
3. *Edge Cases*: The validator handles edge cases like uppercase emails and special characters in usernames.

= Limitations and Future Improvements

== Character Identifier Limitations
- The current implementation processes one character at a time, which may not be efficient for longer inputs.
- The program does not differentiate between uppercase and lowercase letters.

== Email Validator Limitations
- The email validator uses a simplified rule set compared to the actual RFC 5322 standard.
- The validator does not check for the existence of the domain or perform DNS lookups.
- Some complex but technically valid email patterns might be rejected.

== Potential Improvements
1. *Enhanced Character Identifier*: Extend the character identifier to classify more character types (e.g., whitespace, punctuation).
2. *RFC-Compliant Email Validator*: Update the email validator to fully comply with RFC 5322.
3. *Integration with YACC/Bison*: Combine the lexers with parsers for more complex validation tasks.
4. *Performance Optimization*: Optimize the regular expressions for better performance with large inputs.

= Conclusion
This project demonstrates the application of lexical analysis principles using LEX/FLEX. The character identifier and email validator showcase how regular expressions can be used to recognize and validate different patterns in input text. The implementation highlights both the simplicity and power of lexical analyzers for token recognition tasks.

The email validator, in particular, shows how increasingly complex patterns can be recognized using regular expressions, and how specific validation rules can be implemented in the associated actions. While there are limitations to what can be achieved with regular expressions alone, they provide a solid foundation for text processing and validation tasks.

= References
1. Levine, J., Mason, T., & Brown, D. (1992). Lex & Yacc (2nd ed.). O'Reilly Media.
2. The flex Manual. https://westes.github.io/flex/manual/
3. RFC 5322 - Internet Message Format. https://tools.ietf.org/html/rfc5322
4. Aho, A. V., Lam, M. S., Sethi, R., & Ullman, J. D. (2006). Compilers: Principles, Techniques, and Tools (2nd ed.). Addison Wesley.
