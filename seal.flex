 /*
  *  The scanner definition for seal.
  */

 /*
  *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
  *  output, so headers and global definitions are placed here to be visible
  * to the code in the file.  Don't remove anything that was here initially
  */
%{

#include <seal-parse.h>  // remove "//" at first
#include <stringtab.h>
#include <utilities.h>
#include <stdint.h>
#include <stdlib.h>

#include <stdio.h>
#include <cmath>
#include <cstring>
using namespace std;

/* The compiler assumes these identifiers. */
#define yylval seal_yylval
#define yylex  seal_yylex

/* Max size of string constants */
#define MAX_STR_CONST 256
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

 /* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the seal compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE seal_yylval;

 /*
 *  Add Your own definitions here
 */

int hexToDecimal(const char* arr)
{
    int n;
    int temp;
    n = strlen(arr)-2;
    int sum = 0;
    for (int i = 2; arr[i]!='\0'; i++)         //最后一位是'\0'，不用算进去
    {
        switch (arr[i])
        {
            case 'a':case 'A': temp = 10; break;
            case 'b':case 'B': temp = 11; break;
            case 'c':case 'C': temp = 12; break;
            case 'd':case 'D': temp = 13; break;
            case 'e':case 'E': temp = 14; break;
            case 'f':case 'F': temp = 15; break;
            default: temp = arr[i] - '0'; break;
        }
        sum = sum + temp * pow(16, n + 1- i);
    }
    return sum;
}

void int2string(char* m, int n)
{
    if (n==0){
        m[0] = '0';
        m[1] = '\0';
        return;
    }
    int len = 0, n_ = n;
    while (n) {
        n /= 10;
        ++len;
    }
    n = n_;
    m[len] = '\0';
    while (len--){
        int tmp = n % 10;
        m[len] = '0'+tmp;
        n /= 10;
    }
    return;
}

int countStr(char* m, char s){
    int cnt = 0;
    for (int i = 0; m[i]!='\0'; ++i){
        if (m[i] == s)
            ++cnt;
    }
    return cnt;
}

void simplifyString(char* proc, char* orig){
    ;
}

%}

 /*
  * Define names for regular expressions here.
  */
%option noyywrap


DIGIT [0-9]
DIGIT_EXCEPT_ZERO [1-9]
FLOAT ^{DIGIT_EXCEPT_ZERO}{DIGIT}*\.{DIGIT}*|0\.{DIGIT}*{DIGIT_EXCEPT_ZERO}{DIGIT}*|0?\.0+|0$
DIGIT_HEX 0x[0-9A-Fa-f]+
SPACE [ \t\r]
EOL [\n|\r\n]
LINE_COMMENT "//"[^\n]*
MUTI_LINE_COMMENT "/*"(.|\n)*"*/"
TYPE "Int"|"Float"|"String"|"Bool"|"Void"
LETTER_LOWERCASE [a-z]
NAME_CONTENT [a-zA-z_0-9]

STRING_QUOTSTION \"([^(\"|\\\n)]*(\\\n)*)*\"
STRING_QUOTSTION_ERROR \"[^\"]*[^\\]\n.*(\"\n)*
STRING_APOSTROPHE `[^`]*`
%%
 /*
 *	Add Rules here. Error function has been given.
 */
{SPACE} {;}
{MUTI_LINE_COMMENT} {
    curr_lineno += countStr(yytext, '\n');
}
{LINE_COMMENT} {;}
{EOL} {
    curr_lineno += 1;
}
[;=] {
    char c = yytext[0];
    return(c);
}
{TYPE} {
    seal_yylval.symbol = idtable.add_string(yytext);
    return(TYPEID);
}
"var" {
    return(VAR);
}
{LETTER_LOWERCASE}{NAME_CONTENT}* {
    seal_yylval.symbol = idtable.add_string(yytext);
    return(OBJECTID);
}
{DIGIT_HEX} {
    char s[strlen(yytext)];
    int2string(s, hexToDecimal(yytext));
    seal_yylval.symbol = inttable.add_string(s);
    return (CONST_INT);
}
{STRING_QUOTSTION} {
    curr_lineno += countStr(yytext, '\n');
    seal_yylval.symbol = stringtable.add_string(yytext);
    return(CONST_STRING);
}
{STRING_QUOTSTION_ERROR} {
    curr_lineno += countStr(yytext, '\n');
    strcpy(seal_yylval.error_msg, "Missing right \".");
    return(ERROR);
}
{STRING_APOSTROPHE} {
    curr_lineno += countStr(yytext, '\n');
    seal_yylval.symbol = stringtable.add_string(yytext);
    return(CONST_STRING);
}
. {
    strcpy(seal_yylval.error_msg, yytext);
    return (ERROR);
}

%%
