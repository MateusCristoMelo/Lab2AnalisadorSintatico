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

void testezera(void)
{
      fprintf(listing, "Karalhow");
}

%}

%token ELSE IF INT RETURN VOID WHILE 
%token ID NUM 
%token ASSIGN EQ LT LE GT GE NE PLUS MINUS TIMES OVER LPAREN RPAREN SEMI COMMA LBRACE RBRACE LBRACKET RBRACKET 
%token ERROR 

%%

program: 
          declaracao_lista {savedTree = $1;} 
;
//
declaracao_lista: 
                  declaracao_lista declaracao {YYSTYPE t = $1;
                                                if (t != NULL) {
                                                    while (t->sibling != NULL) t = t->sibling;
                                                    t->sibling = $2;
                                                    $$ = $1;
                                                } else {
                                                    $$ = $2;
                                                }
                                              }
|                 declaracao {$$ = $1;}
;
//        
declaracao: 
            var_declaracao {$$ = $1;} 
|           fun_declaracao {$$ = $1;}
;

var_declaracao:
                tipo_especificador ID SEMI {$$ = newStmtNode(VarDecK);
                                            $$->attr.op = $1;
                $$->child[0] = newExpNode(IdK);
                $$->child[0]->attr.name = copyString(id_name);    
                                           }
|               tipo_especificador ID LBRACKET NUM RBRACKET SEMI {     
                                                                  $$ = newStmtNode(VarDecK);
                                                                  $$->attr.op = $1;
                                                                  $$->child[0] = newExpNode(IdK);
                                                                  $$->child[0]->attr.name = copyString(id_name);
                                                                  $$->child[0]->child[0] = newExpNode(ConstK);
                                                                  $$->child[0]->child[0]->attr.val = atoi(tokenString);
                                                                  $$ = $5;
                                                                 }
;
//
tipo_especificador:
                    INT {$$ = INT;}
|                   VOID {$$ = VOID;}
;
//Problema ta aqui
fun_declaracao:
                tipo_especificador ID LPAREN params RPAREN composto_decl {$$ = newStmtNode(FunDecK);                                                                                                                                     
                                                                              $$->attr.op = $1;
                                                                              $$->child[0] = newExpNode(IdK);
                                                                              $$->child[0]->attr.name = copyString(id_name);
                                                                          $$->child[1] = $4;
                                                                          $$->child[2] = $6;
                                                                          }
;
// Problema ta aqui
params:
        param_lista {$$ = $1;}
|       VOID {$$ = NULL;}
;
//
param_lista:
            param_lista COMMA param {YYSTYPE t = $1;
                                      if (t != NULL) {
                                        while (t->sibling != NULL) t = t->sibling;
                                              t->sibling = $3;
                                              $$ = $1;
                                    } else $$ = $3;}
|           param {$$ = $1;}
;
//
param: 
      tipo_especificador ID {$$ = newStmtNode(VarDecK);
			    $$->attr.op = $1;
			    $$->child[0] = newExpNode(IdK);
                      $$->child[0]->attr.name = copyString(id_name);
			   }
|     tipo_especificador ID LBRACKET RBRACKET {$$ = newStmtNode(VarDecK);
			    $$->attr.op = $1;
			    $$->child[0] = newExpNode(IdK);
                      $$->child[0]->attr.name = copyString(id_name);
                       $$ = $3; 
                       }
;
//
composto_decl:
              LBRACE local_declaracoes statement_lista RBRACE {YYSTYPE t = $2;
                if (t != NULL)
                {
                    while (t->sibling != NULL) t = t->sibling;
                    t->sibling = $3;
                    $$ = $2;
			    }
                else 
                  $$ = $3;}
;
//
local_declaracoes:
                   local_declaracoes var_declaracao {YYSTYPE t = $1;
                if (t != NULL) {
			        while (t->sibling != NULL) t = t->sibling;
                    t->sibling = $2;
                    $$ = $1;
			    } else $$ = $2;}
|                   /* vazio */ {$$ = NULL;}
;
//
statement_lista:
                  statement_lista statement {YYSTYPE t = $1;
                if (t != NULL){
			        while (t->sibling != NULL) t = t->sibling;
                    t->sibling = $2;
                    $$ = $1;
			    } else $$ = $2;}
|                  /* vazio */ {$$ = NULL;}
;
//
statement:
            expressao_decl  {$$ = $1;}
|           composto_decl {$$ = $1;}
|           selecao_decl {$$ = $1;}
|           iteracao_decl {$$ = $1;}
|           retorno_decl {$$ = $1;}
;
//
expressao_decl :
                 expressao SEMI {$$ = $1;}
|                SEMI {$$ = NULL;}
;
//
selecao_decl : 
               IF LPAREN expressao RPAREN statement {$$ = newStmtNode(IfK);
                                                    $$->child[0] = $3;
                                                    $$->child[1] = $5;}
|              IF LPAREN expressao RPAREN statement ELSE statement {$$ = newStmtNode(IfK);
                                                                    $$->child[0] = $3;
                                                                    $$->child[1] = $5;
                                                                    $$->child[2] = $7;}
;
//
iteracao_decl :
               WHILE LPAREN expressao RPAREN statement {$$ = newStmtNode(WhileK);
                                                        $$->child[0] = $3;
                                                        $$->child[1] = $5;}
;
//
retorno_decl : 
              RETURN SEMI {$$ = newStmtNode(ReturnK); }
|             RETURN expressao SEMI {$$ = newStmtNode(ReturnK);
			                               $$->child[0] = $2;}
;
//
expressao : 
              var ASSIGN expressao {$$ = newStmtNode(AssignK);
			    $$->child[0] = $1;
			    $$->child[1] = $3;}
|             simples_expressao {$$ = $1;}
;
//
var : 
      ID {$$ = newExpNode(IdK);
		$$->attr.name = copyString(id_name);
            	    }
|     ID LBRACKET expressao RBRACKET { $$ = newExpNode(IdK);
                $$->attr.name = copyString(id_name);
                $$ = $2;
		       $$->child[0] = $4;}
;
// Treta
simples_expressao :
                    soma_expressao relacional soma_expressao {$$ = newExpNode(OpK);
                      $$->child[0] = $1;
			    $$->attr.op = $2;
			    $$->child[1] = $3;}
|                   soma_expressao {$$ = $1; }
;
// Treta
relacional : 
             LE {$$ = LE; }
|            LT {$$ = LT; }
|            GT {$$ = GT; }
|            GE {$$ = GE; }
|            EQ {$$  = EQ; }
|            NE {$$  = NE; }
;
// Treta
soma_expressao: 
                soma_expressao soma termo {$$ = newExpNode(OpK);
			    $$->child[0] = $1;
			    $$->attr.op = $2;
			    $$->child[2] = $3;}
|               termo {$$ = $1;}
// Treta
soma : 
      PLUS {$$ = PLUS;}
|     MINUS {$$ = MINUS;}
;
// TReta
termo : 
        termo mult fator {$$ = newExpNode(OpK);
			    $$->child[0] = $1;
			    $$->attr.op = $2;
			    $$->child[2] = $3;}
|       fator {$$ = $1;}
;
// Treta
mult : 
      TIMES {$$ = TIMES;}
|     OVER {$$ = OVER;}
;
//
fator : 
        LPAREN expressao RPAREN {$$ = $2;}
|       var {$$ = $1;}
|       ativacao {$$ = $1;}
|       NUM {$$ = newExpNode(ConstK);
             $$->attr.val = atoi(tokenString);}
;
//
ativacao : 
          ID LPAREN args RPAREN {
            $$ = newStmtNode(CallK);
			    $$->child[0] = newExpNode(IdK);
                      $$->child[0]->attr.name = copyString(id_name);
			    
            $$ = $2;
			    $$->child[1] = $4;
          }
;
//
args : 
      arg_lista {$$ = $1;}
|     /* vazio */ {$$ = NULL;}
;
//
arg_lista : 
            arg_lista COMMA expressao {YYSTYPE t = $1;
                                        if (t != NULL) {
                                        while (t->sibling != NULL) t = t->sibling;
                                              t->sibling = $3;
                                              $$ = $1;
                                        } else $$ = $3;
                                        } 
|           expressao {$$ = $1;}
;

teste_final :
            /*vazio*/ {$$ = NULL;}
;

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

