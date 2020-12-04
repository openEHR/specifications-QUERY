// Author: Bostjan Lah
// (c) Copyright, Marand, http://www.marand.com
// Licensed under LGPL: http://www.gnu.org/copyleft/lesser.html
// Based on AQL grammar by Ocean Informatics: http://www.openehr.org/wiki/download/attachments/2949295/EQL_v0.6.grm?version=1&modificationDate=1259650833000

parser grammar AqlParser;

options { tokenVocab=AqlLexer; }

query
    : selectClause fromClause whereClause? orderByClause? limitClause? MINUSMINUS? EOF
    ;

selectClause
    : SELECT top? selectExpr (COMMA selectExpr)*
    ;

fromClause
    : FROM fromExpr
	;

whereClause
    : WHERE whereExpr
    ;

orderByClause
    : ORDERBY orderByExpr (COMMA orderByExpr)*
    ;

limitClause
    : LIMIT limit=NN_INTEGER (OFFSET offset=NN_INTEGER)?
    ;

// (deprecated)
top
    : TOP INTEGER direction=(FORWARD|BACKWARD)?
	;

selectExpr
	: columnVar (AS IDENTIFIER)?
	;

columnVar
	: identifiedPath
	;

fromExpr
    : containsExpr
    ;

containsExpr
    : classExprOperand (CONTAINS containsExpr)?
    | containsExpr AND containsExpr
    | containsExpr OR containsExpr
    | OPEN containsExpr CLOSE
    ;

whereExpr
    : NOT? identifiedExpr
    | whereExpr AND whereExpr
    | whereExpr OR whereExpr
    | OPEN whereExpr CLOSE
    ;

orderByExpr
	: identifiedPath order=(DESCENDING|DESC|ASCENDING|ASC)?
	;



identifiedExpr
    : EXISTS identifiedPath
    | left=identifiedOperand COMPARISON_OPERATOR right=identifiedOperand
    | identifiedOperand LIKE likeOperand
    | identifiedOperand MATCHES OPEN_ACCOLADE matchesOperand CLOSE_ACCOLADE
    ;

identifiedOperand
 	: operand
 	| identifiedPath
 	;

identifiedPath
    : IDENTIFIER predicate? (SLASH objectPath)?
    ;

predicate
 	: OPENBRACKET (standardPredicate | archetypePredicate | nodePredicate) CLOSEBRACKET
 	;

standardPredicate
    : predicateOperand COMPARISON_OPERATOR predicateOperand
    ;

archetypePredicate
    : ARCHETYPEID
    | PARAMETER
    | REGEXPATTERN
    ;

nodePredicate
    : NODEID (COMMA (STRING|PARAMETER))?
    | ARCHETYPEID (COMMA (STRING|PARAMETER))?
    | PARAMETER
    | predicateOperand COMPARISON_OPERATOR predicateOperand
    | predicateOperand MATCHES REGEXPATTERN
    | nodePredicate AND nodePredicate
    | nodePredicate OR nodePredicate
    ;

predicateOperand
    : operand
 	| objectPath
 	;


objectPath
 	: pathPart (SLASH pathPart)*
 	;
pathPart
 	: IDENTIFIER predicate?
 	;

likeOperand
    : STRING
    | PARAMETER
    ;
matchesOperand
 	: valueListItems
 	| URIVALUE
 	;
valueListItems
 	: operand (COMMA operand)*
 	;

operand
    : STRING
    | INTEGER
    | FLOAT
    | DOUBLE
    | DATE
    | BOOLEAN
    | NULL_LITERAL
    | PARAMETER
    ;



classExprOperand
	: IDENTIFIER IDENTIFIER? // RM_TYPE_NAME variable
    | archetypedClassExpr
    | versionedClassExpr
	| versionClassExpr
	;

// RM_TYPE_NAME [archetype_id]
// RM_TYPE_NAME variable [archetype_id]
archetypedClassExpr
 	: IDENTIFIER IDENTIFIER? archetypePredicate
 	;
versionedClassExpr
 	: VERSIONED_OBJECT IDENTIFIER? (OPENBRACKET standardPredicate OPENBRACKET)?
 	;
versionClassExpr
 	: VERSION IDENTIFIER? (OPENBRACKET (standardPredicate|versionPredicate) OPENBRACKET)?
 	;
versionPredicate
 	: LATEST_VERSION
 	| ALL_VERSIONS
 	;
