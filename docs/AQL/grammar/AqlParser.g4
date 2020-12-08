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
    : selectClause fromClause whereClause? orderByClause? limitClause? SYM_DOUBLE_DASH? EOF
    ;

selectClause
    : SELECT top? selectExpr (SYM_COMMA selectExpr)*
    ;

fromClause
    : FROM fromExpr
    ;

whereClause
    : WHERE whereExpr
    ;

orderByClause
    : ORDER BY orderByExpr (SYM_COMMA orderByExpr)*
    ;

limitClause
    : LIMIT limit=NATURAL_NUMBER (OFFSET offset=WHOLE_NUMBER) ?
    ;


selectExpr
    : columnExpr (AS aliasName=IDENTIFIER)?
    ;

fromExpr
    : containsExpr
    ;

whereExpr
    : NOT? identifiedExpr
    | whereExpr AND whereExpr
    | whereExpr OR whereExpr
    | SYM_LEFT_PAREN whereExpr SYM_RIGHT_PAREN
    ;

orderByExpr
    : identifiedPath order=(DESCENDING|DESC|ASCENDING|ASC)?
    ;


columnExpr
    : identifiedPath
    | primitive
    | aggregateFunctionCall
    | functionCall
    ;

containsExpr
    : classExprOperand (NOT? CONTAINS containsExpr)?
    | containsExpr AND containsExpr
    | containsExpr OR containsExpr
    | SYM_LEFT_PAREN containsExpr SYM_RIGHT_PAREN
    ;

identifiedExpr
    : EXISTS identifiedPath
    | identifiedPath COMPARISON_OPERATOR identifiedOperand
    | functionCall COMPARISON_OPERATOR identifiedOperand
    | identifiedPath LIKE likeOperand
    | identifiedPath MATCHES SYM_LEFT_CURLY matchesOperand SYM_RIGHT_CURLY
    ;

classExprOperand
    : TYPE_ID variable=VARIABLE_ID? (SYM_LEFT_BRACKET archetypePredicate SYM_RIGHT_BRACKET)?                    #classExpression // RM_TYPE_NAME variable [archetype_id]
    | VERSIONED_OBJECT variable=VARIABLE_ID? (SYM_LEFT_BRACKET standardPredicate SYM_RIGHT_BRACKET)?            #versionedClassExpr
    | EHR variable=VARIABLE_ID? (SYM_LEFT_BRACKET standardPredicate SYM_RIGHT_BRACKET)?                         #ehrClassExpr
    | VERSION variable=VARIABLE_ID? (SYM_LEFT_BRACKET (standardPredicate|versionPredicate) SYM_RIGHT_BRACKET)?  #versionClassExpr
    ;

identifiedOperand
    : primitive
    | PARAMETER
    | identifiedPath
    | functionCall
    ;

identifiedPath
    : VARIABLE_ID pathPredicate? (SYM_SLASH objectPath)?
    ;

pathPredicate
    : SYM_LEFT_BRACKET (standardPredicate | archetypePredicate | nodePredicate) SYM_RIGHT_BRACKET
    ;

standardPredicate
    : objectPath COMPARISON_OPERATOR pathPredicateOperand
    ;

archetypePredicate
    : ARCHETYPE_HRID
    | PARAMETER
    ;

nodePredicate
    : (ID_CODE | AT_CODE) (SYM_COMMA (STRING | PARAMETER))?
    | ARCHETYPE_HRID (SYM_COMMA (STRING | PARAMETER))?
    | PARAMETER
    | objectPath COMPARISON_OPERATOR pathPredicateOperand
    | objectPath MATCHES CONTAINED_REGEX
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
    : pathPart (SYM_SLASH pathPart)*
    ;
pathPart
    : ATTRIBUTE_ID pathPredicate?
    ;

likeOperand
    : STRING
    | PARAMETER
    ;
matchesOperand
    : valueListItem (SYM_COMMA valueListItem)*
    | terminologyFunction
    | URI
    ;
valueListItem
    : primitive
    | PARAMETER
    | terminologyFunction
    ;

primitive
    : STRING
    | INTEGER
    | REAL
    | DATE
    | BOOLEAN
    ;

functionCall
    : terminologyFunction
    | name=FUNCTION_ID SYM_LEFT_PAREN functionArg (SYM_COMMA functionArg)* SYM_RIGHT_PAREN
    ;

functionArg
    : primitive
    | identifiedPath
    | PARAMETER
    | functionCall
    ;

aggregateFunctionCall
    : name=COUNT SYM_LEFT_PAREN (DISTINCT? identifiedPath | SYM_ASTERISK) SYM_RIGHT_PAREN
    | name=(MIN | MAX | SUM | AVG) SYM_LEFT_PAREN identifiedPath SYM_RIGHT_PAREN
    ;

terminologyFunction
    : TERMINOLOGY SYM_LEFT_PAREN STRING SYM_COMMA STRING SYM_COMMA STRING SYM_RIGHT_PAREN
    ;

// (deprecated)
top
    : TOP INTEGER direction=(FORWARD|BACKWARD)?
    ;
