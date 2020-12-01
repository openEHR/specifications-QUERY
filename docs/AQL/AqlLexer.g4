// Author: Bostjan Lah
// (c) Copyright, Marand, http://www.marand.com
// Licensed under LGPL: http://www.gnu.org/copyleft/lesser.html
// Based on AQL grammar by Ocean Informatics: http://www.openehr.org/wiki/download/attachments/2949295/EQL_v0.6.grm?version=1&modificationDate=1259650833000



lexer grammar AqlLexer;

channels {
    ERROR_CHANNEL,
    COMMENT_CHANNEL
}

// SKIP
WS: [ \t\r\n]+ -> skip;
UNICODE_BOM: (
    '\uEFBBBF' // UTF-8 BOM
    | '\uFEFF' // UTF16_BOM
    | '\u0000FEFF' // UTF32_BOM
    ) -> skip;
COMMENT: (
    '-- ' ~[\r\n]* ('\r'? '\n' | EOF)
    | '--' ('\r'? '\n' | EOF)
    ) -> channel(COMMENT_CHANNEL);

// Keywords
// Common Keywords
SELECT: S E L E C T ;
AS: A S ;
FROM: F R O M ;
WHERE: W H E R E ;
ORDERBY: O R D E R ' ' B Y ;
DESC: D E S C ;
DESCENDING: D E S C E N D I N G ;
ASC: A S C ;
ASCENDING: A S C E N D I N G ;
LIMIT: L I M I T ;
OFFSET: O F F S E T ;
// deprecated
TOP: T O P ;
FORWARD: F O R W A R D ;
BACKWARD: B A C K W A R D ;

// Operators
// Containment operator
CONTAINS : C O N T A I N S ;
// Logical operators
AND : A N D ;
OR : O R ;
NOT : N O T ;
EXISTS: E X I S T S ;
// Arithmetical operators
ARITHMETIC_OPERATOR: '*' | '/' | '+' | '-';
// Comparison operators
COMPARISON_OPERATOR: '=' | '!=' | '>' | '>=' | '<' | '<=' ;
LIKE: L I K E ;
MATCHES: M A T C H E S ;


// Constructors symbols
SEMI: ';';


EHR	: E H R ;
VERSION	: V E R S I O N ;
VERSIONED_OBJECT : V E R S I O N E D '_' O B J E C T ;
LATEST_VERSION : L A T E S T '_' V E R S I O N ;
ALL_VERSIONS : A L L '_' V E R S I O N S ;

TRUE: T R U E ;
FALSE: F A L S E ;
NULL: N U L L ;

// Literal primitives
BOOLEAN
    : TRUE
    | FALSE
    ;
STRING
    : SINGLE_QUOTE_SYMB ( ESC_SEQ | ~('\\'|'\'') )* SINGLE_QUOTE_SYMB
    | DOUBLE_QUOTE_SYMB ( ESC_SEQ | ~('\\'|'"') )* DOUBLE_QUOTE_SYMB
    ;
INTEGER
    : '-'? DIGIT+
    ;
FLOAT
    : ('-'? DIGIT+)? '.' DIGIT+
    ;
DECIMAL
    : '-'? DIGIT+ '.' EXPONENT_NUM_PART
    | ('-'? DIGIT+)? '.' (DIGIT+ EXPONENT_NUM_PART)
    | '-'? DIGIT+ EXPONENT_NUM_PART
    ;
DATE
    : SINGLE_QUOTE_SYMB DATE_VALUE SINGLE_QUOTE_SYMB
    | DOUBLE_QUOTE_SYMB DATE_VALUE DOUBLE_QUOTE_SYMB
    ;
DATE_VALUE
    : DT_DATE ('T' DT_TIME ('.' DT_MICRO)? (DT_TIMEZONE)?)?
    ;
DT_DATE
    : DIGIT DIGIT DIGIT DIGIT [0-1] DIGIT [0-3] DIGIT
    | DIGIT DIGIT DIGIT DIGIT '-' [0-1] DIGIT '-' [0-3] DIGIT
    ;
DT_TIME
    : [0-2] DIGIT [0-5] DIGIT [0-5] DIGIT
    | [0-2] DIGIT ':' [0-5] DIGIT ':' [0-5] DIGIT
    ;
DT_MICRO
    : DIGIT DIGIT DIGIT
    ;
DT_TIMEZONE
    : [-+] [0-1] DIGIT DIGIT DIGIT
    | [-+] [0-1] DIGIT ':' DIGIT DIGIT
    | Z
    ;



NN_INTEGER:	DIGIT+;

NODEID:	('at'|'id') DIGIT+ ('.' DIGIT+)*;
ARCHETYPEID: LETTER+ '-' LETTER+ '-' (LETTER|'_')+ '.' (IDCHAR|'-')+ '.v' DIGIT+ ('.' DIGIT+)? ('.' DIGIT+)?;
PARAMETER: '$' LETTER IDCHAR*;

//!Identifier  = {Letter}({Alphanumeric}|'_')*   ! Conflicts with UID
//!Identifier  = {Letter}{IdChar}*   ! Conflicts with extended NodeId
//! restricted to allow only letters after the 4th character due to conflict with extended NodeId
//!Identifier  = {Letter}{IdChar}?{IdChar}?{IdChar}?({Letter}|'_')*  !Conficts with NodeId which may have any length of digit, such as at0.9
//Identifier = {LetterMinusA}{IdCharMinusT}?{IdChar}* | 'a''t'?(({letter}|'_')*|{LetterMinusT}{Alphanumeric}*)
// Identifiers should not conflict with NODEID
IDENTIFIER
    : ('at'|'id') (LETTER|'_') IDCHAR*
    | ('at'|'id'|'a'|'i')
    | [b-hj-zA-Z] IDCHAR*
    ;



URIVALUE
    : LETTER+ '://' (URISTRING|'['|']'|', \''|'\'')*
    ;

REGEXPATTERN
    : '{/' REGEXCHAR+ '/}';





SLASH	:	'/';
COMMA	:	',';
OPENBRACKET: '[';
CLOSEBRACKET: ']';
OPEN_ACCOLADE: '{';
CLOSE_ACCOLADE: '}';
OPEN : '(';
CLOSE : ')';
MINUSMINUS: '--';



fragment ESC_SEQ: '\\' ('b'|'t'|'n'|'f'|'r'|'\\"'|'\''|'\\') | UNICODE_ESC | OCTAL_ESC;
fragment OCTAL_ESC: '\\' [0-3] OCTAL_DIGIT OCTAL_DIGIT | '\\' OCTAL_DIGIT OCTAL_DIGIT | '\\' OCTAL_DIGIT;
fragment UNICODE_ESC: '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT;
fragment QUOTE_SYMB: SINGLE_QUOTE_SYMB | DOUBLE_QUOTE_SYMB ;
fragment SINGLE_QUOTE_SYMB: '\'';
fragment DOUBLE_QUOTE_SYMB: '"';
fragment DIGIT: [0-9];
fragment OCTAL_DIGIT: [0-7];
fragment HEX_DIGIT: [0-9a-fA-F];
fragment EXPONENT_NUM_PART: E [-+]? DIGIT+;
fragment LETTER: [a-zA-Z];
fragment ALPHANUM : LETTER|DIGIT;
fragment IDCHAR : ALPHANUM|'_';
fragment URISTRING: ALPHANUM|'_'|'-'|'/'|':'|'.'|'?'|'&'|'%'|'$'|'#'|'@'|'!'|'+'|'='|'*';
fragment REGEXCHAR: URISTRING|'('|')'|'\\'|'^'|'{'|'}'|']'|'[';

// Fragment letters
fragment A: [aA];
fragment B: [bB];
fragment C: [cC];
fragment D: [dD];
fragment E: [eE];
fragment F: [fF];
fragment G: [gG];
fragment H: [hH];
fragment I: [iI];
fragment J: [jJ];
fragment K: [kK];
fragment L: [lL];
fragment M: [mM];
fragment N: [nN];
fragment O: [oO];
fragment P: [pP];
fragment Q: [qQ];
fragment R: [rR];
fragment S: [sS];
fragment T: [tT];
fragment U: [uU];
fragment V: [vV];
fragment W: [wW];
fragment X: [xX];
fragment Y: [yY];
fragment Z: [zZ];

UNEXPECTED_CHAR: . -> channel(ERROR_CHANNEL);
