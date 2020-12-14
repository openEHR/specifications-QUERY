//
//  description:  ANTLR4 lexer grammar for Archetype Query Language (AQL)
//  authors:      Sebastian Iancu, Code24, Netherlands
//                Teun van Hemert, Nedap, Netherlands
//                Thomas Beale, Ars Semantica UK, openEHR Foundation Management Board
//  contributors: This version of the grammar is a complete rewrite of previously published antlr3 grammar,
//                based on current AQL specifications in combination with other grammars from several AQL implementations.
//                The openEHR Foundation would like to recognise the following people for their contributions:
//                  - Chunlan Ma & Heath Frankel, Ocen Health Systems, Australia
//                  - Bostjan Lah, Better, Slovenia
//                  - Christian Chevalley, EHRBase, Germany
//                  - Michael Böckers, Nedap, Netherlands
//  support:      openEHR Specifications PR tracker <https://specifications.openehr.org/releases/QUERY/open_issues>
//  copyright:    Copyright (c) 2020 openEHR Foundation
//  license:      Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>
//

lexer grammar AqlLexer;

channels {
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
    SYM_DOUBLE_DASH ' ' ~[\r\n]* ('\r'? '\n' | EOF)
    | SYM_DOUBLE_DASH ('\r'? '\n' | EOF)
    ) -> channel(COMMENT_CHANNEL);

// Keywords
// Common Keywords
SELECT: S E L E C T ;
AS: A S ;
FROM: F R O M ;
WHERE: W H E R E ;
ORDER: O R D E R ;
BY: B Y ;
DESC: D E S C ;
DESCENDING: D E S C E N D I N G ;
ASC: A S C ;
ASCENDING: A S C E N D I N G ;
LIMIT: L I M I T ;
OFFSET: O F F S E T ;
// other keywords
DISTINCT: D I S T I N C T ;
EHR : E H R ;
VERSION : V E R S I O N ;
VERSIONED_OBJECT : V E R S I O N E D '_' O B J E C T ;
LATEST_VERSION : L A T E S T '_' V E R S I O N ;
ALL_VERSIONS : A L L '_' V E R S I O N S ;
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
ARITHMETIC_OPERATOR: SYM_ASTERISK | SYM_SLASH | SYM_PLUS | SYM_MINUS ;
// Comparison operators
COMPARISON_OPERATOR: SYM_EQ | SYM_NE | SYM_GT | SYM_GE | SYM_LT | SYM_LE ;
LIKE: L I K E ;
MATCHES: M A T C H E S ;

// functions
COUNT: C O U N T ;
MIN: M I N ;
MAX: M A X ;
SUM: S U M ;
AVG: A V G ;
TERMINOLOGY: T E R M I N O L O G Y ;

//
PARAMETER: '$' ALPHA_CHAR WORD_CHAR*;
VARIABLE_ID: IDENTIFIER;
TYPE_ID: IDENTIFIER;
ALIAS_ID: IDENTIFIER;
FUNCTION_ID: IDENTIFIER;
ATTRIBUTE_ID: S_IDENTIFIER;
NATURAL_NUMBER: [1-9] DIGIT*;
WHOLE_NUMBER: DIGIT+;
//! restricted to allow only letters after the 4th character due to conflict with extended NodeId
//Identifier = {Letter}{IdChar}*   ! Conflicts with extended NodeId
//Identifier = {Letter}{IdChar}?{IdChar}?{IdChar}?({Letter}|'_')*  !Conficts with NodeId which may have any length of digit, such as at0.9
//Identifier = {LetterMinusA}{IdCharMinusT}?{IdChar}* | 'a''t'?(({letter}|'_')*|{LetterMinusT}{Alphanumeric}*)
fragment S_IDENTIFIER
    : ('at'|'id') (ALPHA_CHAR|'_') WORD_CHAR*
    | ('at'|'id'|'a'|'i')
    | [b-hj-zA-Z] WORD_CHAR*
    ;






//
//  ======================= Lexical rules ========================
//  The followings are copies of BaseLexer rules, with some slight modifications
//

// ---------- various ADL2 codes -------

ID_CODE      : 'id' CODE_STR ;
AT_CODE      : 'at' CODE_STR ;
fragment CODE_STR : ('0' | [1-9][0-9]*) ( '.' ('0' | [1-9][0-9]* ))* ;

// ---------- Delimited Regex matcher ------------

CONTAINED_REGEX: '{'WS* SLASH_REGEX WS* (';' WS* STRING)? WS* '}';
fragment SLASH_REGEX: '/' SLASH_REGEX_CHAR+ '/';
fragment SLASH_REGEX_CHAR: ~[/\n\r] | ESCAPE_SEQ | '\\/';

// ---------- ISO8601 Date/Time values ----------

ISO8601_DATE
    : YEAR MONTH DAY
    | YEAR '-' MONTH '-' DAY
    ;
ISO8601_TIME
    : HOUR MINUTE SECOND ('.' MICROSECOND)? TIMEZONE?
    | HOUR ':' MINUTE ':' SECOND ('.' MICROSECOND)? TIMEZONE?
    ;
ISO8601_DATE_TIME
    : YEAR MONTH DAY ('T' HOUR MINUTE SECOND ('.' MICROSECOND)? TIMEZONE?)?
    | YEAR '-' MONTH '-' DAY ('T' HOUR ':' MINUTE ':' SECOND ('.' MICROSECOND)? TIMEZONE?)?
    ;
fragment MICROSECOND: [0-9][0-9][0-9] ;

fragment TIMEZONE: 'Z' | [+-] HOUR ( ':'? MINUTE )? ;  // hour offset, e.g. `+09:30`, or else literal `Z` indicating +0000.
fragment YEAR: [0-9][0-9][0-9][0-9] ; // Year in ISO8601:2004 is 4 digits with 0-filling as needed
fragment MONTH: ( [0][1-9] | [1][0-2] ) ;  // month in year
fragment DAY: ( [0][1-9] | [12][0-9] | [3][0-1] ) ; // day in month
fragment HOUR: ( [01][0-9] | [2][0-3] ) ; // hour in 24 hour clock
fragment MINUTE: [0-5][0-9] ; // minutes
fragment SECOND: [0-5][0-9] ; // seconds

// ------------------- special word symbols --------------

SYM_TRUE: T R U E ;
SYM_FALSE: F A L S E ;
SYM_NULL: N U L L ;

// ---------------------- Identifiers ---------------------

ARCHETYPE_HRID      : ARCHETYPE_HRID_ROOT '.v' VERSION_ID ;
ARCHETYPE_REF       : ARCHETYPE_HRID_ROOT '.v' DIGIT+ ( '.' DIGIT+ )* ;
fragment ARCHETYPE_HRID_ROOT : (NAMESPACE '::')? IDENTIFIER '-' IDENTIFIER '-' IDENTIFIER '.' ARCHETYPE_CONCEPT_ID ;
VERSION_ID          : DIGIT+ '.' DIGIT+ '.' DIGIT+ ( ( '-rc' | '-alpha' ) ( '.' DIGIT+ )? )? ;
fragment IDENTIFIER : ALPHA_CHAR WORD_CHAR* ;
fragment ARCHETYPE_CONCEPT_ID : ALPHA_CHAR NAME_CHAR* ;

// --------------------- composed primitive types -------------------

// URIs - simple recogniser based on https://tools.ietf.org/html/rfc3986 and
// http://www.w3.org/Addressing/URL/5_URI_BNF.html
URI : URI_SCHEME ':' URI_HIER_PART ( '?' URI_QUERY )? ('#' URI_FRAGMENT)? ;

fragment URI_HIER_PART : ( '//' URI_AUTHORITY ) URI_PATH_ABEMPTY
    | URI_PATH_ABSOLUTE
    | URI_PATH_ROOTLESS
    | URI_PATH_EMPTY;

fragment URI_SCHEME : ALPHA_CHAR ( ALPHA_CHAR | DIGIT | '+' | '-' | '.')* ;

fragment URI_AUTHORITY : ( URI_USERINFO '@' )? URI_HOST ( ':' URI_PORT )? ;
fragment URI_USERINFO: (URI_UNRESERVED | URI_PCT_ENCODED | URI_SUB_DELIMS | ':' )* ;
fragment URI_HOST : URI_IP_LITERAL | URI_IPV4_ADDRESS | URI_REG_NAME ; //TODO: ipv6
fragment URI_PORT: DIGIT*;

fragment URI_IP_LITERAL   : '[' URI_IPV6_LITERAL ']'; //TODO, if needed: IPvFuture
fragment URI_IPV4_ADDRESS : URI_DEC_OCTET '.' URI_DEC_OCTET '.' URI_DEC_OCTET '.' URI_DEC_OCTET ;
fragment URI_IPV6_LITERAL : HEX_QUAD (':' HEX_QUAD )* '::' HEX_QUAD (':' HEX_QUAD )* ;

fragment URI_DEC_OCTET  : DIGIT | [1-9] DIGIT | '1' DIGIT DIGIT | '2' [0-4] DIGIT | '25' [0-5];
fragment URI_REG_NAME: (URI_UNRESERVED | URI_PCT_ENCODED | URI_SUB_DELIMS)*;
fragment HEX_QUAD : HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT ;

fragment URI_PATH_ABEMPTY: ('/' URI_SEGMENT ) *;
fragment URI_PATH_ABSOLUTE: '/' ( URI_SEGMENT_NZ ( '/' URI_SEGMENT )* )?;
fragment URI_PATH_NOSCHEME: URI_SEGMENT_NZ_NC ( '/' URI_SEGMENT )*;
fragment URI_PATH_ROOTLESS: URI_SEGMENT_NZ ( '/' URI_SEGMENT )*;
fragment URI_PATH_EMPTY: ;

fragment URI_SEGMENT: URI_PCHAR*;
fragment URI_SEGMENT_NZ: URI_PCHAR+;
fragment URI_SEGMENT_NZ_NC: ( URI_UNRESERVED | URI_PCT_ENCODED | URI_SUB_DELIMS | '@' )+; //non-zero-length segment without any colon ":"

fragment URI_PCHAR: URI_UNRESERVED | URI_PCT_ENCODED | URI_SUB_DELIMS | ':' | '@';

//fragment URI_PATH   : '/' | ( '/' URI_XPALPHA+ )+ ('/')?;
fragment URI_QUERY : (URI_PCHAR | '/' | '?')*;
fragment URI_FRAGMENT  : (URI_PCHAR | '/' | '?')*;

fragment URI_PCT_ENCODED : '%' HEX_DIGIT HEX_DIGIT ;

fragment URI_UNRESERVED: ALPHA_CHAR | DIGIT | '-' | '.' | '_' | '~';
fragment URI_RESERVED: URI_GEN_DELIMS | URI_SUB_DELIMS;
fragment URI_GEN_DELIMS: ':' | '/' | '?' | '#' | '[' | ']' | '@'; //TODO: migrate to [/?#...] notation
fragment URI_SUB_DELIMS: '!' | '$' | '&' | '\'' | '(' | ')'
                         | '*' | '+' | ',' | ';' | '=';

// According to IETF http://tools.ietf.org/html/rfc1034[RFC 1034] and http://tools.ietf.org/html/rfc1035[RFC 1035],
// as clarified by http://tools.ietf.org/html/rfc2181[RFC 2181] (section 11)
fragment NAMESPACE: LABEL ('.' LABEL)* ;
fragment LABEL: ALPHA_CHAR (NAME_CHAR|URI_PCT_ENCODED)* ;

// --------------------- atomic primitive types -------------------

BOOLEAN: SYM_TRUE | SYM_FALSE ;

INTEGER: '-'? DIGIT+ E_SUFFIX? ;
REAL: ('-'? DIGIT+)? '.' DIGIT+ E_SUFFIX? ;
fragment E_SUFFIX: E [-+]? DIGIT+ ;

DATE
    : SYM_SINGLE_QUOTE ISO8601_DATE SYM_SINGLE_QUOTE
    | SYM_DOUBLE_QUOTE ISO8601_DATE SYM_DOUBLE_QUOTE
    ;

TIME
    : SYM_SINGLE_QUOTE ISO8601_TIME SYM_SINGLE_QUOTE
    | SYM_DOUBLE_QUOTE ISO8601_TIME SYM_DOUBLE_QUOTE
    ;

DATETIME
    : SYM_SINGLE_QUOTE ISO8601_DATE_TIME SYM_SINGLE_QUOTE
    | SYM_DOUBLE_QUOTE ISO8601_DATE_TIME SYM_DOUBLE_QUOTE
    ;

STRING
    : SYM_SINGLE_QUOTE ( ESCAPE_SEQ | UTF8CHAR | OCTAL_ESC | ~('\\'|'\'') )* SYM_SINGLE_QUOTE
    | SYM_DOUBLE_QUOTE ( ESCAPE_SEQ | UTF8CHAR | OCTAL_ESC | ~('\\'|'"') )* SYM_DOUBLE_QUOTE
    ;

fragment ESCAPE_SEQ: '\\' ['"?abfnrtv\\] ;

// ------------------- character fragments ------------------

fragment NAME_CHAR: WORD_CHAR | '-' ;
fragment WORD_CHAR: ALPHANUM_CHAR | '_' ;
fragment ALPHANUM_CHAR: ALPHA_CHAR | DIGIT ;

fragment ALPHA_CHAR: [a-zA-Z];
fragment UTF8CHAR: '\\u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT ;

fragment DIGIT: [0-9];
fragment HEX_DIGIT: [0-9a-fA-F];

fragment OCTAL_ESC: '\\' [0-3] OCTAL_DIGIT OCTAL_DIGIT | '\\' OCTAL_DIGIT OCTAL_DIGIT | '\\' OCTAL_DIGIT;
fragment OCTAL_DIGIT: [0-7];

// ---------- symbols ----------

SYM_SEMICOLON: ';' ;
SYM_LT: '<' ;
SYM_GT: '>' ;
SYM_LE: '<=' ;
SYM_GE: '>=' ;
SYM_NE: '!=' ;
SYM_EQ: '=' ;
SYM_LEFT_PAREN: '(' ;
SYM_RIGHT_PAREN: ')' ;
SYM_COMMA: ',';

SYM_SLASH: '/';
SYM_ASTERISK: '*';
SYM_PLUS: '+';
SYM_MINUS: '-';
SYM_LEFT_BRACKET: '[';
SYM_RIGHT_BRACKET: ']';
SYM_LEFT_CURLY: '{';
SYM_RIGHT_CURLY: '}';
SYM_DOUBLE_DASH: '--';

fragment SYM_SINGLE_QUOTE: '\'';
fragment SYM_DOUBLE_QUOTE: '"';

// ------------------- Fragment letters ---------------------
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
