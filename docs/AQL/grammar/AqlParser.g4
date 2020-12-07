//
//  description:  ANTLR4 parser grammar for Archetype Query Language (AQL)
//  author:       Sebastian Iancu
//  contributors: This version of the grammar is a complete rewrite of previously published antlr3 grammar,
//                based on current AQL specifications in combination with other grammars from several AQL implementations.
//                The openEHR Foundation would like to recognise the following people for their contributions:
//                  - Chunlan Ma & Heath Frankel, Ocen Health Systems, Australia
//                  - Bostjan Lah, Better, Slovenia
//                  - Christian Chevalley, EHRBase, Germany
//                  - Teun van Hemert & Michael Böckers, Nedap, Netherlands
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
    : columnExpr (AS IDENTIFIER)?
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


columnExpr
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
    | functionCall COMPARISON_OPERATOR identifiedOperand
    | identifiedPath LIKE likeOperand
    | identifiedPath MATCHES OPEN_CURLY matchesOperand CLOSE_CURLY
    ;

classExprOperand
    : IDENTIFIER variable=IDENTIFIER? (OPEN_BRACKET archetypePredicate CLOSE_BRACKET)?                 #classExpression // RM_TYPE_NAME variable [archetype_id]
    | VERSIONED_OBJECT variable=IDENTIFIER? (OPEN_BRACKET standardPredicate CLOSE_BRACKET)?            #versionedClassExpr
    | EHR variable=IDENTIFIER? (OPEN_BRACKET standardPredicate CLOSE_BRACKET)?                         #ehrClassExpr
    | VERSION variable=IDENTIFIER? (OPEN_BRACKET (standardPredicate|versionPredicate) CLOSE_BRACKET)?  #versionClassExpr
    ;

identifiedOperand
    : primitive
    | PARAMETER
    | identifiedPath
    | functionCall
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

versionPredicate
    : LATEST_VERSION
    | ALL_VERSIONS
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
    | terminologyFunction
    | URIVALUE
    ;
valueListItem
    : primitive
    | PARAMETER
    | terminologyFunction
    ;

primitive
    : STRING
    | INTEGER
    | FLOAT
    | DOUBLE
    | DATE
    | BOOLEAN
    ;

functionCall
    : terminologyFunction
    | function
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
    : COUNT OPEN_PAR (DISTINCT? identifiedPath | STAR) CLOSE_PAR    #countFunction
    | MIN OPEN_PAR identifiedPath CLOSE_PAR                    #minFunction
    | MAX OPEN_PAR identifiedPath CLOSE_PAR                    #maxFunction
    | SUM OPEN_PAR identifiedPath CLOSE_PAR                    #sumFunction
    | AVG OPEN_PAR identifiedPath CLOSE_PAR                    #avgFunction
    ;

terminologyFunction
    : TERMINOLOGY OPEN_PAR STRING COMMA STRING COMMA STRING CLOSE_PAR
    ;

// (deprecated)
top
    : TOP INTEGER direction=(FORWARD|BACKWARD)?
    ;
