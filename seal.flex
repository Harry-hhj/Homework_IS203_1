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


%}

 /*
  * Define names for regular expressions here.
  */
%option noyywrap

FLOAT ^{DIGIT_EXCEPT_ZERO}{DIGIT}*\.{DIGIT}*|0\.{DIGIT}*{DIGIT_EXCEPT_ZERO}{DIGIT}*|0?\.0+|0$
DIGIT [0-9]
DIGIT_EXCEPT_ZERO [1-9]
DIGIT_HEX 0x[0-9A-Fa-f]+
SPACE [ \t\r]
LINE_COMMENT \/\/[^\n]*
MUTI_LINE_COMMENT /\*(.|\n)*\*/  //correct
STRING_QUOTSTION \"[^\"]*\"  //
STRING_APOSTROPHE `[^]*`  //
%%
 /*
 *	Add Rules here. Error function has been given.
 */
{DIGIT} {seal_yylval.symbol = inttable.add_string(yytext);return (CONST_INT);}
. {strcpy(seal_yylval.error_msg, yytext);return (ERROR);}

%%
