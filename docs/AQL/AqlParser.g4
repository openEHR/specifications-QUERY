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
    : ORDER BY orderByExpr (COMMA orderByExpr)*
    ;

limitClause
    : LIMIT limit=NN_INTEGER (OFFSET offset=NN_INTEGER)?
    ;


selectExpr
	: columnVar (AS IDENTIFIER)?
	;

fromExpr
    : containsExpr
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


columnVar
	: identifiedPath
	;

containsExpr
    : classExprOperand (CONTAINS containsExpr)?
    | containsExpr AND containsExpr
    | containsExpr OR containsExpr
    | OPEN containsExpr CLOSE
    ;

identifiedExpr
    : EXISTS identifiedPath
    | identifiedPath COMPARISON_OPERATOR identifiedOperand
    | identifiedPath LIKE likeOperand
    | identifiedPath MATCHES OPEN_ACCOLADE matchesOperand CLOSE_ACCOLADE
    ;

identifiedOperand
 	: primitive
 	| PARAMETER
 	| identifiedPath
 	;

identifiedPath
    : IDENTIFIER pathPredicate? (SLASH objectPath)?
    ;

pathPredicate
 	: OPENBRACKET (standardPredicate | archetypePredicate | nodePredicate) CLOSEBRACKET
 	;

standardPredicate
    : objectPath COMPARISON_OPERATOR pathPredicateOperand
    ;

archetypePredicate
    : ARCHETYPEID
    | PARAMETER
    ;

nodePredicate
    : NODEID (COMMA (STRING|PARAMETER))?
    | ARCHETYPEID (COMMA (STRING|PARAMETER))?
    | PARAMETER
    | objectPath COMPARISON_OPERATOR pathPredicateOperand
    | objectPath MATCHES REGEXPATTERN
    | nodePredicate AND nodePredicate
    | nodePredicate OR nodePredicate
    ;

pathPredicateOperand
    : primitive
 	| objectPath
 	| PARAMETER
 	;


objectPath
 	: pathPart (SLASH pathPart)*
 	;
pathPart
 	: IDENTIFIER pathPredicate?
 	;

likeOperand
    : STRING
    | PARAMETER
    ;
matchesOperand
 	: valueListItem (COMMA valueListItem)*
 	| URIVALUE
 	;
valueListItem
 	: primitive
 	| PARAMETER
 	;

primitive
    : STRING
    | INTEGER
    | FLOAT
    | DOUBLE
    | DATE
    | BOOLEAN
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


// (deprecated)
top
    : TOP INTEGER direction=(FORWARD|BACKWARD)?
	;

