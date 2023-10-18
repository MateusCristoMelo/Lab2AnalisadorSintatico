/****************************************************/
/* File: tiny.y                                     */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void);
int yyerror(char *s);

%}



%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INT LONG REGISTER RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE 
%token ID NUM 
%token ASSIGN EQ LT LE GT GE NE PLUS MINUS TIMES OVER LPAREN RPAREN SEMI COMMA LBRACE RBRACE LBRACKET RBRACKET 
%token ERROR 

%% /* Grammar for CMINUS */

/* CMINUS
programa → declaração-lista
declaração-lista → declaração-lista declaração | declaração
declaração → var-declaração | fun-declaração
var-declaração → tipo-especificador ID ; | tipo-especificador ID [ NUM ] ;
tipo-especificador → int | void
fun-declaração → tipo-especificador ID ( params ) composto-decl
params → param-lista | void
param-lista → param-lista, param | param
param → tipo-especificador ID | tipo-especificador ID [ ]
composto-decl → { local-declarações statement-lista }
local-declarações → local-declarações var-declaração | vazio
statement-lista → statement-lista statement | vazio
statement → expressao-decl | composto-decl | selecao_decl | iteracao_decl | retorno_decl
expressao-decl → expressao ; | ;
selecao_decl → if ( expressao ) statement | if ( expressao ) statement else statement
iteracao_decl → while ( expressao ) statement
retorno_decl → return ; | return expressao;
expressao → var = expressao | simples_expressao
var → ID | ID [ expressao ]
simples_expressao → soma_expressao  relacional soma_expressao  | soma_expressao 
relacional → <= | < | > | >= | == | !=
soma_expressao  → soma_expressao  soma termo | termo
soma → + | -
termo → termo mult fator | fator
mult → * | /
fator → ( expressao ) | var | ativacao | NUM
ativacao → ID ( args )
args → arg_lista | vazio
arg_lista → arg_lista , expressao | expressao
End of CMINUS */


// Tem que mudar isso pra colocar na gramatica do CMINUS

program: 
          declaracao_lista { savedTree = $1; } 
;

declaracao_lista:
                  declaracao_lista declaracao {}
|                 declaracao {}
;
        
declaracao: 
            var_declaracao {} 
|           fun_declaracao {}
;

var_declaracao:
                tipo_especificador ID SEMI {}
|               tipo_especificador ID LBRACKET NUM RBRACKET SEMI {}
;

tipo_especificador:
                    INT {}
|                   VOID {}
;

fun_declaracao:
                tipo_especificador ID LPAREN params RPAREN composto_decl {}
;

params:
        param_lista {}
|       VOID {}
;

param_lista:
            param_lista COMMA param {}
|           param {}
;

param: 
      tipo_especificador ID {}
|     tipo_especificador ID LBRACKET RBRACKET {}
;

composto_decl:
              LBRACE local_declaracoes statement_lista RBRACE {}
;

local_declaracoes:
                   local_declaracoes var_declaracao {}
|                   /* vazio */ {}
;

statement_lista:
                  statement_lista statement {}
|                  /* vazio */ {}
;

statement:
            expressao_decl  {}
|           composto_decl {}
|           selecao_decl {}
|           iteracao_decl {}
|           retorno_decl {}
;

expressao_decl :
                 expressao SEMI {}
|                SEMI {}
;

selecao_decl : 
               IF LPAREN expressao RPAREN statement {}
|              IF LPAREN expressao RPAREN statement ELSE statement {}
;

iteracao_decl :
               WHILE LPAREN expressao RPAREN statement {}
;

retorno_decl : 
              RETURN SEMI {}
|             RETURN expressao SEMI {}
;

expressao : 
              var ASSIGN expressao {}
|             simples_expressao {}
;

var : 
      ID {}
|     ID LBRACKET expressao RBRACKET {}
;

simples_expressao :
                    soma_expressao relacional soma_expressao {}
|                   soma_expressao {}
;

relacional : 
             LE {}
|            LT {}
|            GT {}
|            GE {}
|            EQ {}
|            NE {}
;

soma_expressao: 
                soma_expressao soma termo {}
|               termo {}

soma : 
      PLUS {}
|     MINUS {}
;

termo : 
        termo mult fator {}
|       fator {}
;

mult : 
      TIMES {}
|     OVER {}
;

fator : 
        LPAREN expressao RPAREN {}
|       var {}
|       ativacao {}
|       NUM {$$ = newExpNode(ConstK);
             $$->attr.val = atoi(tokenString);}
;

ativacao : 
          ID LPAREN args RPAREN {}
;

args : 
      arg_lista {}
|     /* vazio */ {}

arg_lista : 
            arg_lista COMMA expressao {} 
|           expressao {}


/* Tiny

stmt_seq    : stmt_seq SEMI stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; }
                     else $$ = $3;
                 }
            | stmt  { $$ = $1; }
            ;
stmt        : if_stmt { $$ = $1; }
            | repeat_stmt { $$ = $1; }
            | assign_stmt { $$ = $1; }
            | read_stmt { $$ = $1; }
            | write_stmt { $$ = $1; }
            | error  { $$ = NULL; }
            ;
if_stmt     : IF exp IF stmt_seq END
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $2;
                   $$->child[1] = $4;
                 }
            | IF exp IF stmt_seq ELSE stmt_seq END
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $2;
                   $$->child[1] = $4;
                   $$->child[2] = $6;
                 }
            ;
repeat_stmt : REPEAT stmt_seq UNTIL exp
                 { $$ = newStmtNode(RepeatK);
                   $$->child[0] = $2;
                   $$->child[1] = $4;
                 }
            ;
assign_stmt : ID { savedName = copyString(tokenString);
                   savedLineNo = lineno; }
              ASSIGN exp
                 { $$ = newStmtNode(AssignK);
                   $$->child[0] = $4;
                   $$->attr.name = savedName;
                   $$->lineno = savedLineNo;
                 }
            ;
read_stmt   : READ ID
                 { $$ = newStmtNode(ReadK);
                   $$->attr.name =
                     copyString(tokenString);
                 }
            ;
write_stmt  : WRITE exp
                 { $$ = newStmtNode(WriteK);
                   $$->child[0] = $2;
                 }
            ;
exp         : simple_exp LT simple_exp 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = LT;
                 }
            | simple_exp EQ simple_exp
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = EQ;
                 }
            | simple_exp { $$ = $1; }
            ;
simple_exp  : simple_exp PLUS term 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = PLUS;
                 }
            | simple_exp MINUS term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = MINUS;
                 } 
            | term { $$ = $1; }
            ;
term        : term TIMES factor 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = TIMES;
                 }
            | term OVER factor
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = OVER;
                 }
            | factor { $$ = $1; }
            ;
factor      : LPAREN exp RPAREN
                 { $$ = $2; }
            | NUM
                 { $$ = newExpNode(ConstK);
                   $$->attr.val = atoi(tokenString);
                 }
            | ID { $$ = newExpNode(IdK);
                   $$->attr.name =
                         copyString(tokenString);
                 }
            | error { $$ = NULL; }
            ;
End Tiny */ 

%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of 
  TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

