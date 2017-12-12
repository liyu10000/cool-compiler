/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int comment_level = 0; /* records the layers of comments */
int string_length = 0; /* records the number of characters in string */

%}

/*
 * Define names for regular expressions here.
 */

INTEGER			[0-9]+

CLASS			[Cc][Ll][Aa][Ss][Ss]
ELSE			[Ee][Ll][Ss][Ee]
FI				[Ff][Ii]
IF				[Ii][Ff]
IN				[Ii][Nn]
INHERITS		[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
LET				[Ll][Ee][Tt]
LOOP			[Ll][Oo][Oo][Pp]
POOL			[Pp][Oo][Oo][Ll]
THEN			[Tt][Hh][Ee][Nn]
WHILE			[Ww][Hh][Ii][Ll][Ee]
CASE			[Cc][Aa][Ss][Ee]
ESAC			[Ee][Ss][Aa][Cc]
OF				[Oo][Ff]
NEW				[Nn][Ee][Ww]
ISVOID			[Ii][Ss][Vv][Oo][Ii][Dd]
NOT				[Nn][Oo][Tt]
TRUE			t[Rr][Uu][Ee]
FALSE			f[Aa][Ll][Ss][Ee]

TYPEID			[A-Z][0-9a-zA-Z_]*
OBJECTID		[a-z][0-9a-zA-Z_]*

LE				<=
ASSIGN			<-
DARROW			=>
OTHER			[+\-*/<=\.(){}~@:;,]

NEWLINE			\n
WHITESPACE		[ \t\r\f\v]+

%x COMMENT
%x COMMENT_LINE
%x STRING
%X STRING_ERROR

%%

 /*
  *  Nested comments
  */
"(*"			{ BEGIN(COMMENT); comment_level = 1; }
<COMMENT>"(*"	{ comment_level++; }
<COMMENT>.		{ }
<COMMENT>\n		{ curr_lineno++; }
<COMMENT>"*)"	{ comment_level--;
				  if (comment_level == 0)
						BEGIN(INITIAL);
				}
<COMMENT><<EOF>> { cool_yylval.error_msg = "EOF in comment";
				  BEGIN(INITIAL);
				  return ERROR; }
"*)"			{ cool_yylval.error_msg = "Unmatched *)";
				  BEGIN(INITIAL);
				  return ERROR; }

"--"			{ BEGIN(COMMENT_LINE); }
<COMMENT_LINE>. { }
<COMMENT_LINE>\n { curr_lineno++;
				   BEGIN(INITIAL); }

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return DARROW; }
{ASSIGN}		{ return ASSIGN; }
{LE}			{ return LE; }
{OTHER}			{ return (char)*yytext; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{CLASS}			{ return CLASS; }
{ELSE}			{ return ELSE; }
{FI}			{ return FI; }
{IF}			{ return IF; }
{IN}			{ return IN; }
{INHERITS}		{ return INHERITS; }
{LET}			{ return LET; }
{LOOP}			{ return LOOP; }
{POOL}			{ return POOL; }
{THEN}			{ return THEN; }
{WHILE}			{ return WHILE; }
{CASE}			{ return CASE; }
{ESAC}			{ return ESAC; }
{OF}			{ return OF; }
{NEW}			{ return NEW; }
{ISVOID}		{ return ISVOID; }
{NOT}			{ return NOT; }
{INTEGER}		{ cool_yylval.symbol = inttable.add_string(yytext);
				  return INT_CONST; }
{TRUE}			{ cool_yylval.boolean = true; return BOOL_CONST; }
{FALSE}			{ cool_yylval.boolean = false; return BOOL_CONST; }

{TYPEID}		{ cool_yylval.symbol = idtable.add_string(yytext);
				  return TYPEID; }
{OBJECTID}		{ cool_yylval.symbol = idtable.add_string(yytext);
				  return OBJECTID; }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"				{ BEGIN(STRING); }
<STRING>\"		{ cool_yylval.symbol = stringtable.add_string(string_buf);
				  string_length = 0;
				  string_buf[0] = '\0';
				  BEGIN(INITIAL);
				  return STR_CONST; }
<STRING>(\0|\\\0)	{ cool_yylval.error_msg = "String contains null character";
				  BEGIN(STRING_ERROR);
				  return ERROR; }
<STRING>\n		{ cool_yylval.error_msg = "Unterminated string constant";
				  string_length = 0;
				  string_buf[0] = '\0';
				  curr_lineno++;
				  BEGIN(INITIAL);
				  return ERROR; }
<STRING>\\[ntbf] { if ((string_length + 1) >= MAX_STR_CONST) {
					BEGIN(STRING_ERROR);
					string_length = 0;
					string_buf[0] = '\0';
					cool_yylval.error_msg = "String constant too long";
					return ERROR;
				  } else {
					string_length++;
					switch(yytext[1]) {
						case 'n': strcat(string_buf, "\n"); break;
						case 't': strcat(string_buf, "\t"); break;
						case 'b': strcat(string_buf, "\b"); break;
						case 'f': strcat(string_buf, "\f"); break;
					} } }
<STRING>\\\n	{ if ((string_length + 1) >= MAX_STR_CONST) {
					BEGIN(STRING_ERROR);
					string_length = 0;
					string_buf[0] = '\0';
					cool_yylval.error_msg = "String constant too long";
					return ERROR;
				  } else {
					string_length++;
					curr_lineno++;
					strcat(string_buf, "\n");
				  } }
<STRING>\\.		{ if ((string_length + 1) >= MAX_STR_CONST) {
					BEGIN(STRING_ERROR);
					string_length = 0;
					string_buf[0] = '\0';
					cool_yylval.error_msg = "String constant too long";
					return ERROR;
				  } else {
					string_length++;
					strcat(string_buf, &strdup(yytext)[1]);
				  } }
<STRING><<EOF>> { cool_yylval.error_msg = "EOF in comment";
				  curr_lineno++;
				  BEGIN(INITIAL);
				  return ERROR; }
<STRING>.		{ if ((string_length + 1) >= MAX_STR_CONST) {
					BEGIN(STRING_ERROR);
					string_length = 0;
					string_buf[0] = '\0';
					cool_yylval.error_msg = "String constant too long";
					return ERROR;
				  } else {
					string_length++;
					strcat(string_buf, yytext);
				  } }

<STRING_ERROR>\"	{ BEGIN(INITIAL); }
<STRING_ERROR>\\\n	{ curr_lineno++; BEGIN(INITIAL); }
<STRING_ERROR>\n	{ curr_lineno++; BEGIN(INITIAL); }
<STRING_ERROR>.		{ }

{NEWLINE}			{ curr_lineno++; }
{WHITESPACE}		{ }
.					{ cool_yylval.error_msg = yytext;
					  return ERROR; }
%%
