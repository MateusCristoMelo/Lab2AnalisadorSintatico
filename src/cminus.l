/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Project for CES41: Compiladores                  */
/****************************************************/

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \r?\n|\r
whitespace  [ \t]+

%option noyywrap

%%

"auto"          {return AUTO;}
"break"         {return BREAK;}
"case"          {return CASE;}
"char"          {return CHAR;}
"const"         {return CONST;}
"continue"      {return CONTINUE;}
"default"       {return DEFAULT;}
"do"            {return DO;}
"double"        {return DOUBLE;}
"else"          {return ELSE;}
"enum"          {return ENUM;}
"extern"        {return EXTERN;}
"float"         {return FLOAT;}
"for"           {return FOR;}
"goto"          {return GOTO;}
"if"            {return IF;}
"int"           {return INT;}
"long"          {return LONG;}
"register"      {return REGISTER;}
"return"        {return RETURN;}
"short"         {return SHORT;}
"signed"        {return SIGNED;}
"sizeof"        {return SIZEOF;}
"static"        {return STATIC;}
"struct"        {return STRUCT;}
"switch"        {return SWITCH;}
"typedef"       {return TYPEDEF;}
"union"         {return UNION;}
"unsigned"      {return UNSIGNED;}
"void"          {return VOID;}
"volatile"      {return VOLATILE;}
"while"         {return WHILE;}
"="             {return ASSIGN;}
"=="            {return EQ;}
"<"             {return LT;}
"<="            {return LE;}
">"             {return GT;}
">="            {return GE;}
"!="            {return NE;}
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"("             {return LPAREN;}
")"             {return RPAREN;}
";"             {return SEMI;}
","             {return COMMA;}
"{"             {return LBRACE;}
"}"             {return RBRACE;}
"["             {return LBRACKET;}
"]"             {return RBRACKET;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {
                if(linhas[lineno] == NULL)
                  fprintf(listing,"%d: \n",lineno + 1);
                else
                  fprintf(listing,"%d: %s",lineno + 1, linhas[lineno]);
                lineno++;
                }

{whitespace}    {/* skip whitespace */}
"/*" { char c;
       char d;
       //printf("%d: /*", lineno);
       do {
        c = input();
        //printf("%c", c);
        if (c == EOF) break;
        if (c == '\n') 
        {
          lineno++;
          //printf("%d: ", lineno);
          fprintf(listing,"%d: %s",lineno, linhas[lineno - 1]);
        }
        if (c == '*') /* to close the comment, '/' must follow '*' */ 
        {
          d = input();
          if (d == '/') break;
        }
       } while (c);
       //printf("/\n");
      }
.               {return ERROR;}

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    if(linhas[lineno] == NULL)
      fprintf(listing,"%d: \n",lineno + 1);
    else
      fprintf(listing,"%d: %s",lineno + 1, linhas[lineno]);
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}

