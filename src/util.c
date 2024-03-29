/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token 
 * and its lexeme 
 */

// Função para inicializar a pilha
void initStack(struct Stack *stack) {
    stack->top = -1;
}

// Função para verificar se a pilha está vazia
int isEmpty(struct Stack *stack) {
    return (stack->top == -1);
}

// Função para verificar se a pilha está cheia
int isFull(struct Stack *stack) {
    return (stack->top == MAX_SIZE - 1);
}

// Função para adicionar um elemento à pilha (push)
void push(struct Stack *stack, void *item) {
    if (isFull(stack)) {
        printf("Erro: a pilha está cheia e não é possível adicionar mais elementos.\n");
    } else {
        stack->items[++stack->top] = item;
    }
}

// Função para retirar um elemento da pilha (pop)
void *pop(struct Stack *stack) {
    if (isEmpty(stack)) {
        printf("Erro: a pilha está vazia e não é possível retirar elementos.\n");
        return NULL;
    } else {
        return stack->items[stack->top--];
    }
}


void printTokenSyn( TokenType token, const char* tokenString )
{ switch (token)
  { 
    case ELSE:
    case IF:
    case RETURN:
    case WHILE:
    case VOID: fprintf(listing,"void\n"); break;
    case INT: fprintf(listing,"int\n"); break;
    case ASSIGN: fprintf(listing,"=\n"); break;
    case EQ: fprintf(listing,"==\n"); break;
    case LT: fprintf(listing,"<\n"); break;
    case LE: fprintf(listing,"<=\n"); break;
    case GT: fprintf(listing,">\n"); break;
    case GE: fprintf(listing,">=\n"); break;
    case NE: fprintf(listing,"!=\n"); break;
    case LPAREN: fprintf(listing,"(\n"); break;
    case RPAREN: fprintf(listing,")\n"); break;
    case SEMI: fprintf(listing,";\n"); break;
    case PLUS: fprintf(listing,"+\n"); break;
    case MINUS: fprintf(listing,"-\n"); break;
    case TIMES: fprintf(listing,"*\n"); break;
    case OVER: fprintf(listing,"/\n"); break;
    case COMMA: fprintf(listing,",\n"); break;
    case LBRACE: fprintf(listing,"{\n"); break;
    case RBRACE: fprintf(listing,"}\n"); break;
    case LBRACKET: fprintf(listing,"[\n"); break;
    case RBRACKET: fprintf(listing,"]\n"); break;
    case ENDFILE: fprintf(listing,"EOF\n"); break;
    case NUM: fprintf(listing, "NUM, val= %s\n",tokenString); break;
    case ID: fprintf(listing, "ID, name= %s\n",tokenString); break;
    case ERROR: fprintf(listing, "ERROR: %s\n",tokenString); break;
    default: /* should never happen */ fprintf(listing,"Unknown token: %d\n",token);
  }
}

void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { 
    case ELSE:
    case IF:
    case RETURN:
    case WHILE:
    case VOID:
    case INT: fprintf(listing,"reserved word: %s\n",tokenString); break;
    case ASSIGN: fprintf(listing,"=\n"); break;
    case EQ: fprintf(listing,"==\n"); break;
    case LT: fprintf(listing,"<\n"); break;
    case LE: fprintf(listing,"<=\n"); break;
    case GT: fprintf(listing,">\n"); break;
    case GE: fprintf(listing,">=\n"); break;
    case NE: fprintf(listing,"!=\n"); break;
    case LPAREN: fprintf(listing,"(\n"); break;
    case RPAREN: fprintf(listing,")\n"); break;
    case SEMI: fprintf(listing,";\n"); break;
    case PLUS: fprintf(listing,"+\n"); break;
    case MINUS: fprintf(listing,"-\n"); break;
    case TIMES: fprintf(listing,"*\n"); break;
    case OVER: fprintf(listing,"/\n"); break;
    case COMMA: fprintf(listing,",\n"); break;
    case LBRACE: fprintf(listing,"{\n"); break;
    case RBRACE: fprintf(listing,"}\n"); break;
    case LBRACKET: fprintf(listing,"[\n"); break;
    case RBRACKET: fprintf(listing,"]\n"); break;
    case ENDFILE: fprintf(listing,"EOF\n"); break;
    case NUM: fprintf(listing, "NUM, val= %s\n",tokenString); break;
    case ID: fprintf(listing, "ID, name= %s\n",tokenString); break;
    case ERROR: fprintf(listing, "ERROR: %s\n",tokenString); break;
    default: /* should never happen */ fprintf(listing,"Unknown token: %d\n",token);
  }
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    pce("Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->kind.stmt = kind;
    t->lineno = lineno;
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    pce("Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->type = Void;
  }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    pce("Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static int indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
  for (i=0;i<indentno;i++)
    pc(" ");
}

/* procedure printTree prints a syntax tree 
 * using indentation to indicate subtrees
 */
void printTree( TreeNode * tree )
{ int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
    if (tree->nodekind==StmtK)
    { switch (tree->kind.stmt) {
        case IfK: fprintf(listing,"If\n"); break;
        case WhileK: fprintf(listing,"While\n"); break;
        case AssignK: fprintf(listing,"Assign:\n"); break;
        case ReturnK: fprintf(listing,"Return\n"); break;
        case CallK: fprintf(listing,"Activation: %s\n", tree->attr.name); /*printTokenSyn(tree->attr.name,"\0"); */break;
        case VarDecK: fprintf(listing,"Type: ");printTokenSyn(tree->attr.op,"\0"); break;
        case FunDecK: fprintf(listing,"Type: ");printTokenSyn(tree->attr.op,"\0"); break;
        default: fprintf(listing,"Unknown ExpNode kind\n"); break;
      }
    }
    else if (tree->nodekind==ExpK)
    { switch (tree->kind.exp) {
        case OpK: fprintf(listing,"Op: "); printTokenSyn(tree->attr.op,"\0"); break;
        case ConstK: fprintf(listing,"Const: %d\n",tree->attr.val); break;
        case IdK: if(tree->attr.name != NULL) fprintf(listing,"Id: %s\n",tree->attr.name); break;
        default: fprintf(listing,"Unknown ExpNode kind\n"); break;
      }
    }
    else fprintf(listing,"Unknown node kind\n");
    for (i=0;i<MAXCHILDREN;i++)
         printTree(tree->child[i]);
    tree = tree->sibling;
  }
  UNINDENT;
}
