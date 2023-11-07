%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int indent_level = 0;
%}

%option noyywrap

%x INDENT DEDENT

/* Define token types as constants */
%{


#define IDENTIFIER 1
#define KEYWORD 2
#define LITERAL 3
#define OPERATOR 4
#define DECIMAL_NUMBER 5
#define INTEGER_NUMBER 6
#define BINARY_NUMBER 7
#define STRING_LITERAL 8
#define COMMENT 9
#define STRING 11
%}

/* Regular expressions to match tokens */
DIGIT       [0-9]
LETTER      [_a-zA-Z]
ALPHANUM    {LETTER}|{DIGIT}
IDENTIFIER  {LETTER}{ALPHANUM}*

LITERALSTRING   \"([^\"\\]|\\.)*\"
LITERALCHAR     \'([^\']|\\.)\'


KEYWORD              if|else|elif|while|for|def|class|as|assert|break|continue|del|except|finally|from|global|import|in|is|lambda|nonlocal|not|or|pass|raise|return|try|with|yield|True|print|and|False|None|match|case|async|await|self
OPERATORS            [+\-*/%<>&^|=!]=?

DECIMAL_NUMBER       {DIGIT}+\.{DIGIT}+
INTEGER_NUMBER       {DIGIT}+
BINARY_NUMBER        0b[01]+

STRING_LITERAL       \"([^\"\\]|\\.)*\"
COMMENT_LINE         \#.+
COMMENT_BLOCK        \/\*[^*]*\*+([^/*][^*]*\*+)*\/

SPECIAL_CHARACTER      [()[\]{}.;:]

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
{SPECIAL_CHARACTER}     { printf("SPECIAL_CHARACTER: %s\n", yytext); }

[ \t\r]+                { /* Ignore whitespace and newlines */ }

\n            {
               int c;
               while ((c = getchar()) == ' ' || c == '\t') {}
               ungetc(c, stdin);
               if (indent_level > 0) {
                   printf("DEDENT\n");
                   indent_level--;
               }
               while ((c = getchar()) == ' ' || c == '\t') {}
               ungetc(c, stdin);
               if (c != EOF) {
                   printf("INDENT\n");
                   indent_level++;
               }
            }
.                       { printf("Invalid_Character: %c\n", yytext[0]); }
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