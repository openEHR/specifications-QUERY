//
//  description:  ANTLR4 parser grammar for Archetype Query Language (AQL)
//  author:       Sebastian Iancu
//  contributors: This version of the grammar is a complet rewrite of previously published antlr3 grammar,
//                based on current AQL specifications in combination with other grammars from several AQL implementations.
//                The openEHR Foundation would like to recognise the following people for their contributions:
//                  - Chunlan Ma & Heath Frankel, Ocen Health Systems, Australia
//                  - Bostjan Lah, Better, Slovenia
//                  - Christian Chevalley, EHRBase, Germany
//                  - Teun van Helmert, Nedap, Netherlands
//  support:      openEHR Specifications PR tracker <https://specifications.openehr.org/releases/QUERY/open_issues>
//  copyright:    Copyright (c) 2020 openEHR Foundation
//  license:      Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>
//

parser grammar AqlParser;

options { tokenVocab=AqlLexer; }

selectQuery
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
    | OPEN_PAR whereExpr CLOSE_PAR
    ;

orderByExpr
	: identifiedPath order=(DESCENDING|DESC|ASCENDING|ASC)?
	;


columnVar
	: identifiedPath
	| aggregateFunctionCall
	| functionCall
	;

containsExpr
    : classExprOperand (CONTAINS containsExpr)?
    | containsExpr AND containsExpr
    | containsExpr OR containsExpr
    | OPEN_PAR containsExpr CLOSE_PAR
    ;

identifiedExpr
    : EXISTS identifiedPath
    | identifiedPath COMPARISON_OPERATOR identifiedOperand
    | identifiedPath LIKE likeOperand
    | identifiedPath MATCHES OPEN_CURLY matchesOperand CLOSE_CURLY
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
 	: OPEN_BRACKET (standardPredicate | archetypePredicate | nodePredicate) CLOSE_BRACKET
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
 	: VERSIONED_OBJECT IDENTIFIER? (OPEN_BRACKET standardPredicate OPEN_BRACKET)?
 	;
versionClassExpr
 	: VERSION IDENTIFIER? (OPEN_BRACKET (standardPredicate|versionPredicate) OPEN_BRACKET)?
 	;
versionPredicate
 	: LATEST_VERSION
 	| ALL_VERSIONS
 	;

functionCall
    : function
    ;

function
    : IDENTIFIER OPEN_PAR functionArg (COMMA functionArg)* CLOSE_PAR
    ;

functionArg
    : primitive
    | identifiedPath
    | PARAMETER
    | functionCall
    ;

aggregateFunctionCall
    : countFunction
    | minFunction
    | maxFunction
    | sumFunction
    | avgFunction
    ;

countFunction
    : COUNT OPEN_PAR (DISTINCT? identifiedPath | STAR) CLOSE_PAR
    ;

minFunction
    : MIN OPEN_PAR identifiedPath CLOSE_PAR
    ;

maxFunction
    : MAX OPEN_PAR identifiedPath CLOSE_PAR
    ;

sumFunction
    : SUM OPEN_PAR identifiedPath CLOSE_PAR
    ;

avgFunction
    : AVG OPEN_PAR identifiedPath CLOSE_PAR
    ;


// (deprecated)
top
    : TOP INTEGER direction=(FORWARD|BACKWARD)?
	;
