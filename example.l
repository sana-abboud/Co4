%{
#include <stdio.h>
#include <string.h>
%}

%option noyywrap

/* Define token types as constants */
%{
#define INDENT 12
#define DEDENT 13
#define IDENTIFIER 1
#define KEYWORD 2
#define LITERAL 3
#define OPERATOR 4
#define DECIMAL_NUMBER 5
#define INTEGER_NUMBER 6
#define BINARY_NUMBER 7
#define STRING_LITERAL 8
#define COMMENT 9
#define SPECIAL_CHARACTER 10
#define STRING 11
%}

/* Regular expressions to match tokens */
DIGIT       [0-9]
LETTER      [_a-zA-Z]
ALPHANUM    {LETTER}|{DIGIT}
IDENTIFIER  {LETTER}{ALPHANUM}*

LITERALSTRING   \"([^\"\\]|\\.)*\"
LITERALCHAR     \'([^\']|\\.)\'


KEYWORD     if|else|while|for|def|class|as|assert|break|continue|del|except|finally|from|global|import|in|is|lambda|nonlocal|not|or|pass|raise|return|try|with|yield
OPERATORS   [+\-*/%<>&^|=!]=?

DECIMAL_NUMBER  {DIGIT}+\.{DIGIT}+
INTEGER_NUMBER  {DIGIT}+
BINARY_NUMBER   0b[01]+

STRING_LITERAL  \"([^\"\\]|\\.)*\"
COMMENT_LINE   \#.+
COMMENT_BLOCK  \/\*[^*]*\*+([^/*][^*]*\*+)*\/

int indentLevel = 0;  

%%
{OPERATORS}             { printf("OPERATOR: %s\n", yytext); }

{KEYWORD}               { printf("Reserved Word: %s\n", yytext); }
{DECIMAL_NUMBER}        { printf("Decimal Number = %s\n", yytext); }
{INTEGER_NUMBER}        { printf("Integer Number = %s\n", yytext); }
{BINARY_NUMBER}         { printf("Binary Number = %s\n", yytext); }
{STRING_LITERAL}        { printf("String Literal = %s\n", yytext); }
{COMMENT_LINE}          { printf("Comment: %s\n", yytext); }  // Print comment line
{COMMENT_BLOCK}         { printf("Comment: %s\n", yytext); }  // Print comment block
{IDENTIFIER}            { printf("IDENTIFIER = %s\n", yytext); }
\"([^\"\\]*(\\\\.[^\"\\]*)*)\"  { printf("STRING: %s\n", yytext); }  // Print string

[ \t\r]+                { /* Ignore whitespace and newlines */ }

[\(\)\[\]\{\}\.,;:]     { printf("SPECIAL_CHARACTER: %s\n", yytext); }

\n                      {  
    int spaces = 0;
    int i = 0;
    while (yytext[i] == ' ') {
        spaces++;
        i++;
    }
    
    if (spaces > indentLevel) {
        for (i = 0; i < (spaces - indentLevel); i++) {
            printf("INDENT\n");
        }
        indentLevel = spaces;
    } else if (spaces < indentLevel) {
        for (i = 0; i < (indentLevel - spaces); i++) {
            printf("DEDENT\n");
        }
        indentLevel = spaces;
    }
}

.                       { printf("Invalid Character: %c\n", yytext[0]); }
%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (file != NULL) {
            yyin = file;
        } else {
            printf("Failed to open file: %s\n", argv[1]);
            return 1;
        }
    } else {
        yyin = stdin;
    }
    yylex();
    return 0;
}