%% Grammar for the SPARQL 1.1. query and update language as specified in https://www.w3.org/TR/2013/REC-sparql11-query-20130321/#grammar

Nonterminals
  unit prologue decl baseDecl prefixDecl
  query
    selectQuery subSelect selectClause varDecls varDecl
    constructQuery describeQuery describeQuerySubjects describeQuerySubject askQuery
    datasetClauses datasetClause defaultGraphClause namedGraphClause sourceSelector whereClause solutionModifier
    groupClause groupConditions groupCondition havingClause havingConditions havingCondition
    orderClause orderConditions orderCondition limitOffsetClauses limitClause offsetClause valuesClause
  %% update
  %%   update1 load clear drop create add move copy insertData deleteData deleteWhere
  %%   modify deleteClause insertClause usingClause graphOrDefault graphRef graphRefAll
  %%   quadPattern quadData quads quadsNotTriples
  triplesTemplate groupGraphPattern groupGraphPatternSub graphPatternNotTriplesBlockSeq graphPatternNotTriplesBlock
  triplesBlock graphPatternNotTriples optionalGraphPattern graphGraphPattern serviceGraphPattern bind
  inlineData dataBlock inlineDataOneVar inlineDataFull vars dataBlockValuesOrNil dataBlockValue dataBlockValues
  minusGraphPattern groupOrUnionGraphPattern
  filter constraint functionCall argList expressionList expressionSeq constructTemplate constructTriples triplesSameSubject
  propertyList propertyListNotEmpty propertyListNotEmptyVerbObjectList verb objectList object
  triplesSameSubjectPath propertyListPathNotEmpty semicolonSeq
  verbObjectList verbPath verbSimple objectListPath objectPath
  path pathAlternative pathSequence pathElt pathEltOrInverse pathMod pathPrimary
  pathNegatedPropertySet pathNegatedPropertySetSeq pathOneInPropertySet
  triplesNode blankNodePropertyList triplesNodePath blankNodePropertyListPath collection collectionPath
  graphNode graphNodes graphNodePath graphNodePaths varOrTerm varOrIri graphTerm expression conditionalOrExpression conditionalAndExpression valueLogical
  relationalExpression numericExpression additiveExpression multiplicativeExpressionSeq multiplicativeUnaryExpressionSeq multiplicativeUnaryExpression
  multiplicativeExpression unaryExpression primaryExpression brackettedExpression
  builtInCall regexExpression substringExpression strReplaceExpression existsFunc notExistsFunc aggregate iriOrFunction rdfLiteral
  numericLiteral numericLiteralUnsigned numericLiteralPositive numericLiteralNegative booleanLiteral
  iri prefixedName blankNode .

Terminals
  var prefix_ns prefix_ln iriref blank_node_label anon nil
  string_literal_quote langtag integer decimal double boolean
  integer_positive decimal_positive double_positive integer_negative decimal_negative double_negative
  '.' ';' ',' '[' ']' '(' ')' '{' '}' '^^' 'a' '*' '|' '/' '^' '?' '=' '!='
  '<' '>' '<=' '>=' '+' '-' '!' '||' '&&'
  'PREFIX' 'BASE' 'SELECT' 'CONSTRUCT' 'DESCRIBE' 'ASK' 'DISTINCT' 'REDUCED'
  'FROM' 'NAMED' 'AS' 'WHERE' 'GROUP' 'BY' 'HAVING' 'ORDER' 'ASC' 'DESC'
  'LIMIT' 'OFFSET' 'VALUES' 'OPTIONAL' 'GRAPH' 'SERVICE' 'SILENT' 'BIND'
  'UNDEF' 'MINUS' 'UNION' 'FILTER' 'IN'
  'STR' 'LANG' 'LANGMATCHES' 'DATATYPE' 'BOUND' 'IRI' 'URI' 'BNODE' 'RAND' 'ABS'
  'CEIL' 'FLOOR' 'ROUND' 'CONCAT' 'STRLEN' 'UCASE' 'LCASE' 'ENCODE_FOR_URI' 'CONTAINS'
  'STRSTARTS' 'STRENDS' 'STRBEFORE' 'STRAFTER'
  'YEAR' 'MONTH' 'DAY' 'HOURS' 'MINUTES' 'SECONDS' 'TIMEZONE' 'TZ' 'NOW'
  'UUID' 'STRUUID' 'MD5' 'SHA1' 'SHA256' 'SHA384' 'SHA512' 'COALESCE'
  'IF' 'STRLANG' 'STRDT' 'sameTerm' 'isIRI' 'isURI' 'isBLANK' 'isLITERAL' 'isNUMERIC'
  'REGEX' 'SUBSTR' 'REPLACE' 'EXISTS' 'NOT' 'COUNT' 'SUM' 'MIN' 'MAX' 'AVG' 'SAMPLE'
  'GROUP_CONCAT' 'SEPARATOR' .


Rootsymbol unit.

unit -> query  : {query, '$1'} .
%% TODO: unit -> update : {update, '$1'} .

query -> prologue selectQuery valuesClause    : {'$1', '$2', '$3' } .
query -> prologue constructQuery valuesClause : {'$1', '$2', '$3' } .
query -> prologue describeQuery valuesClause  : {'$1', '$2', '$3' } .
query -> prologue askQuery valuesClause       : {'$1', '$2', '$3' } .
query -> selectQuery valuesClause             : { [],  '$1', '$2' } .
query -> constructQuery valuesClause          : { [],  '$1', '$2' } .
query -> describeQuery valuesClause           : { [],  '$1', '$2' } .
query -> askQuery valuesClause                : { [],  '$1', '$2' } .
%% without valuesClause
query -> prologue selectQuery                 : {'$1', '$2', nil } .
query -> prologue constructQuery              : {'$1', '$2', nil } .
query -> prologue describeQuery               : {'$1', '$2', nil } .
query -> prologue askQuery                    : {'$1', '$2', nil } .
query -> selectQuery                          : { [],  '$1', nil } .
query -> constructQuery                       : { [],  '$1', nil } .
query -> describeQuery                        : { [],  '$1', nil } .
query -> askQuery                             : { [],  '$1', nil } .

prologue -> decl          : ['$1'] .
prologue -> decl prologue : ['$1' | '$2'] .

decl -> baseDecl   : '$1' .
decl -> prefixDecl : '$1' .
prefixDecl -> 'PREFIX' prefix_ns iriref : {prefix_decl, '$2', to_iri_string('$3')} .
baseDecl   -> 'BASE' iriref             : {base_decl, to_iri_string('$2')} .

selectQuery     -> selectClause datasetClauses whereClause solutionModifier : {select, '$1', '$2', '$3', '$4' } .
selectQuery     -> selectClause whereClause solutionModifier                : {select, '$1', nil , '$2', '$3' } .
%% without solutionModifier
selectQuery     -> selectClause datasetClauses whereClause  : {select, '$1', '$2', '$3', nil } .
selectQuery     -> selectClause whereClause                 : {select, '$1', nil , '$2', nil } .

subSelect	      -> selectClause whereClause solutionModifier valuesClause .
subSelect	      -> selectClause whereClause valuesClause .
subSelect	      -> selectClause whereClause solutionModifier .
subSelect	      -> selectClause whereClause .

selectClause	  -> 'SELECT' 'DISTINCT' varDecls : {'$3', distinct} .
selectClause	  -> 'SELECT' 'REDUCED' varDecls  : {'$3', reduced} .
selectClause	  -> 'SELECT' varDecls            : {'$2', nil} .

varDecls -> '*'                         : ['$1'] .
varDecls -> varDecl                     : ['$1'] .
varDecls -> varDecl varDecls            : ['$1' | '$2'] .
varDecl  -> var                         : {'$1', nil} .
varDecl  -> '(' expression 'AS' var ')' : {'$2', '$1'} .

constructQuery	-> 'CONSTRUCT' constructTemplate datasetClauses whereClause solutionModifier   : {construct, '$2', '$3', '$4', '$5' } .
constructQuery	-> 'CONSTRUCT' constructTemplate whereClause solutionModifier                  : {construct, '$2', nil , '$3', '$4' } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' triplesTemplate '}' solutionModifier : {construct, nil, '$2', {where, '$5'}, '$7' } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' triplesTemplate '}' solutionModifier                : {construct, nil, nil , {where, '$4'}, '$6' } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' '}' solutionModifier                 : {construct, nil, '$2', {where, nil}, '$6' } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' '}' solutionModifier                                : {construct, nil, nil , {where, nil}, '$5' } .
%% without solutionModifier
constructQuery	-> 'CONSTRUCT' constructTemplate datasetClauses whereClause   : {construct, '$2', '$3', '$4', nil } .
constructQuery	-> 'CONSTRUCT' constructTemplate whereClause                  : {construct, '$2', nil , '$3', nil } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' triplesTemplate '}' : {construct, nil, '$2', {where, '$5'}, nil } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' triplesTemplate '}'                : {construct, nil, nil , {where, '$4'}, nil } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' '}'                 : {construct, nil, '$2', {where, nil}, nil } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' '}'                                : {construct, nil, nil , {where, nil}, nil } .

describeQuery	  -> 'DESCRIBE' describeQuerySubject datasetClauses whereClause solutionModifier : {describe, '$2', '$3', '$4', '$5' } .
describeQuery	  -> 'DESCRIBE' describeQuerySubject whereClause solutionModifier                : {describe, '$2', nil , '$3', '$4' } .
describeQuery	  -> 'DESCRIBE' describeQuerySubject datasetClauses solutionModifier             : {describe, '$2', '$3', nil , '$4' } .
describeQuery	  -> 'DESCRIBE' describeQuerySubject solutionModifier                            : {describe, '$2', nil , nil , '$3' } .
%% without solutionModifier
describeQuery	  -> 'DESCRIBE' describeQuerySubject datasetClauses whereClause : {describe, '$2', '$3', '$4', nil } .
describeQuery	  -> 'DESCRIBE' describeQuerySubject whereClause                : {describe, '$2', nil , '$3', nil } .
describeQuery	  -> 'DESCRIBE' describeQuerySubject datasetClauses             : {describe, '$2', '$3', nil , nil } .
describeQuery	  -> 'DESCRIBE' describeQuerySubject                            : {describe, '$2', nil , nil , nil } .

describeQuerySubject  -> '*'                            : ['$1'] .
describeQuerySubject  -> describeQuerySubjects          : '$1' .
describeQuerySubjects -> varOrIri                       : ['$1'] .
describeQuerySubjects -> varOrIri describeQuerySubjects : ['$1' | '$2'] .

askQuery	      -> 'ASK' datasetClauses whereClause solutionModifier : {ask, '$2', '$3', '$4' } .
askQuery	      -> 'ASK' whereClause solutionModifier                : {ask, nil , '$2', '$3' } .
%% without solutionModifier
askQuery	      -> 'ASK' datasetClauses whereClause                  : {ask, '$2', '$3', nil } .
askQuery	      -> 'ASK' whereClause                                 : {ask, nil , '$2', nil } .

datasetClauses -> datasetClause                : ['$1'] .
datasetClauses -> datasetClause datasetClauses : ['$1' | '$2'] .

datasetClause -> 'FROM' defaultGraphClause .
datasetClause -> 'FROM' namedGraphClause .

defaultGraphClause -> sourceSelector .
namedGraphClause	 -> 'NAMED' sourceSelector .

sourceSelector -> iri : '$1' .

whereClause	-> 'WHERE' groupGraphPattern : {where, '$2'} .
whereClause	-> groupGraphPattern         : {where, '$1'} .

%% SolutionModifier ::= groupClause? havingClause? orderClause? limitOffsetClauses?
solutionModifier -> groupClause  havingClause orderClause limitOffsetClauses .
solutionModifier -> groupClause  orderClause  limitOffsetClauses .
solutionModifier -> groupClause  havingClause limitOffsetClauses .
solutionModifier -> groupClause  havingClause orderClause .
solutionModifier -> havingClause orderClause  limitOffsetClauses .
solutionModifier -> groupClause  havingClause .
solutionModifier -> groupClause  orderClause .
solutionModifier -> groupClause  limitOffsetClauses .
solutionModifier -> havingClause orderClause .
solutionModifier -> havingClause limitOffsetClauses .
solutionModifier -> orderClause  limitOffsetClauses .
solutionModifier -> groupClause .
solutionModifier -> havingClause .
solutionModifier -> orderClause .
solutionModifier -> limitOffsetClauses .

groupClause	    -> 'GROUP' 'BY' groupConditions .
groupConditions -> groupCondition                 : ['$1'] .
groupConditions -> groupCondition groupConditions : ['$1' | '$2'] .
groupCondition  -> builtInCall .
groupCondition  -> functionCall .
groupCondition  -> '(' expression 'AS' var ')' .
groupCondition  -> '(' expression ')' .
groupCondition  -> var .

havingClause     -> 'HAVING' havingConditions .
havingConditions -> havingCondition                  : ['$1'] .
havingConditions -> havingCondition havingConditions : ['$1' | '$2'] .
havingCondition	 -> constraint .

orderClause     -> 'ORDER' 'BY' orderConditions .
orderConditions -> orderCondition                 : ['$1'] .
orderConditions -> orderCondition orderConditions : ['$1' | '$2'] .
orderCondition  -> 'ASC' brackettedExpression .
orderCondition  -> 'DESC' brackettedExpression .
orderCondition  -> constraint .
orderCondition  -> var .

limitOffsetClauses -> limitClause offsetClause .
limitOffsetClauses -> limitClause .
limitOffsetClauses -> offsetClause limitClause .
limitOffsetClauses -> offsetClause .

limitClause   -> 'LIMIT' integer .
offsetClause  -> 'OFFSET' integer .
valuesClause  -> 'VALUES' dataBlock .

%% Update  -> Prologue ( Update1 ( ';' Update )? )?
%% Update1 -> Load | Clear | Drop | Add | Move | Copy | Create | InsertData | DeleteData | DeleteWhere | Modify
%% Load    -> 'LOAD' 'SILENT'? iri ( 'INTO' GraphRef )?
%% Clear   -> 'CLEAR' 'SILENT'? GraphRefAll
%% Drop    -> 'DROP' 'SILENT'? GraphRefAll
%% Create  -> 'CREATE' 'SILENT'? GraphRef
%% Add -> 'ADD' 'SILENT'? GraphOrDefault 'TO' GraphOrDefault
%% Move -> 'MOVE' 'SILENT'? GraphOrDefault 'TO' GraphOrDefault
%% Copy -> 'COPY' 'SILENT'? GraphOrDefault 'TO' GraphOrDefault
%% InsertData -> 'INSERT DATA' QuadData
%% DeleteData -> 'DELETE DATA' QuadData
%% DeleteWhere -> 'DELETE WHERE' QuadPattern
%% Modify -> ( 'WITH' iri )? ( DeleteClause InsertClause? | InsertClause ) UsingClause* 'WHERE' GroupGraphPattern
%% DeleteClause -> 'DELETE' QuadPattern
%% InsertClause -> 'INSERT' QuadPattern
%% UsingClause -> 'USING' ( iri | 'NAMED' iri )
%% GraphOrDefault -> 'DEFAULT' | 'GRAPH'? iri
%% GraphRef -> 'GRAPH' iri
%% GraphRefAll -> GraphRef | 'DEFAULT' | 'NAMED' | 'ALL'
%% QuadPattern -> '{' Quads '}'
%% QuadData -> '{' Quads '}'
%% quads -> triplesTemplate? ( QuadsNotTriples '.'? TriplesTemplate? )*
%% QuadsNotTriples -> 'GRAPH' VarOrIri '{' TriplesTemplate? '}'

triplesTemplate -> triplesSameSubject '.' triplesTemplate .
triplesTemplate -> triplesSameSubject '.' .
triplesTemplate -> triplesSameSubject .

groupGraphPattern -> '{' subSelect '}'            : {group_graph_pattern, '$2'} .
groupGraphPattern -> '{' groupGraphPatternSub '}' : {group_graph_pattern, '$2'} .
groupGraphPattern -> '{' '}'                      : {group_graph_pattern, nil } .

%% GroupGraphPatternSub -> TriplesBlock? ( GraphPatternNotTriples '.'? TriplesBlock? )*
%% TODO: Note: This can be empty!
groupGraphPatternSub -> triplesBlock graphPatternNotTriplesBlockSeq .
groupGraphPatternSub -> triplesBlock .
groupGraphPatternSub -> graphPatternNotTriplesBlockSeq .
graphPatternNotTriplesBlockSeq -> graphPatternNotTriplesBlock graphPatternNotTriplesBlockSeq .
graphPatternNotTriplesBlockSeq -> graphPatternNotTriplesBlock  .
graphPatternNotTriplesBlock -> graphPatternNotTriples '.' triplesBlock .
graphPatternNotTriplesBlock -> graphPatternNotTriples '.' .
graphPatternNotTriplesBlock -> graphPatternNotTriples triplesBlock .
graphPatternNotTriplesBlock -> graphPatternNotTriples .

triplesBlock -> triplesSameSubjectPath '.' triplesBlock .
triplesBlock -> triplesSameSubjectPath '.' .
triplesBlock -> triplesSameSubjectPath .

graphPatternNotTriples -> groupOrUnionGraphPattern .
graphPatternNotTriples -> optionalGraphPattern .
graphPatternNotTriples -> minusGraphPattern .
graphPatternNotTriples -> graphGraphPattern .
graphPatternNotTriples -> serviceGraphPattern .
graphPatternNotTriples -> filter .
graphPatternNotTriples -> bind .
graphPatternNotTriples -> inlineData .

optionalGraphPattern -> 'OPTIONAL' groupGraphPattern .
graphGraphPattern    -> 'GRAPH' varOrIri groupGraphPattern .
serviceGraphPattern  -> 'SERVICE' 'SILENT' varOrIri groupGraphPattern .
serviceGraphPattern  -> 'SERVICE' varOrIri groupGraphPattern .

bind -> 'BIND' '(' expression 'AS' var ')' .

inlineData -> 'VALUES' dataBlock .
dataBlock  -> inlineDataOneVar .
dataBlock  -> inlineDataFull .
inlineDataOneVar -> var '{' dataBlockValues '}' .
inlineDataOneVar -> var '{' '}' .
%% InlineDataFull -> ( NIL | '(' Var* ')' ) '{' ( '(' DataBlockValue* ')' | NIL )* '}'
inlineDataFull -> '(' vars ')' '{' dataBlockValuesOrNil '}' .
inlineDataFull -> '(' vars ')' '{' '}' .
inlineDataFull -> nil '{' dataBlockValuesOrNil '}' .
inlineDataFull -> nil '{' '}' .
vars -> var vars : ['$1' | '$2'] .
vars -> var      : ['$1'] .
dataBlockValuesOrNil -> '(' dataBlockValues ')' dataBlockValuesOrNil .
dataBlockValuesOrNil -> nil dataBlockValuesOrNil .
dataBlockValuesOrNil -> '(' dataBlockValues ')' .
dataBlockValuesOrNil -> nil .
dataBlockValues -> dataBlockValue dataBlockValues : ['$1' | '$2'] .
dataBlockValues -> dataBlockValue                 : ['$1'] .
dataBlockValue -> iri .
dataBlockValue -> rdfLiteral .
dataBlockValue -> numericLiteral .
dataBlockValue -> booleanLiteral .
dataBlockValue -> 'UNDEF' .

minusGraphPattern -> 'MINUS' groupGraphPattern .
groupOrUnionGraphPattern -> groupGraphPattern 'UNION' groupOrUnionGraphPattern .
groupOrUnionGraphPattern -> groupGraphPattern .

filter -> 'FILTER' constraint .
constraint -> brackettedExpression .
constraint -> builtInCall .
constraint -> functionCall .
functionCall -> iri argList .
%% ArgList -> NIL | '(' 'DISTINCT'? Expression ( ',' Expression )* ')'
argList -> nil .
argList -> '(' 'DISTINCT' expression expressionSeq ')' .
argList -> '(' 'DISTINCT' expression  ')' .
argList -> '(' expression expressionSeq ')' .
argList -> '(' expression  ')' .
%% ExpressionList -> NIL | '(' Expression ( ',' Expression )* ')'
expressionList -> nil .
expressionList -> '(' expression ')' .
expressionList -> '(' expression expressionSeq ')' .
expressionSeq -> ',' expression expressionSeq .
expressionSeq -> ',' expression .
constructTemplate -> '{' constructTriples '}' .
constructTemplate -> '{' '}' .
constructTriples -> triplesSameSubject '.' constructTriples .
constructTriples -> triplesSameSubject '.' .
constructTriples -> triplesSameSubject  .
triplesSameSubject -> varOrTerm propertyListNotEmpty .
triplesSameSubject -> triplesNode propertyList .
triplesSameSubject -> triplesNode .
propertyList -> propertyListNotEmpty .
%% PropertyListNotEmpty -> Verb ObjectList ( ';' ( Verb ObjectList )? )*
propertyListNotEmpty -> verb objectList propertyListNotEmptyVerbObjectList .
propertyListNotEmpty -> verb objectList .
propertyListNotEmptyVerbObjectList -> ';' verb objectList propertyListNotEmptyVerbObjectList .
propertyListNotEmptyVerbObjectList -> ';' propertyListNotEmptyVerbObjectList .
propertyListNotEmptyVerbObjectList -> ';' verb objectList .
propertyListNotEmptyVerbObjectList -> ';' .
verb -> varOrIri .
verb -> 'a' .
objectList -> object ',' objectList .
objectList -> object .
object -> graphNode .
triplesSameSubjectPath -> varOrTerm propertyListPathNotEmpty .
triplesSameSubjectPath -> triplesNodePath propertyListPathNotEmpty .
triplesSameSubjectPath -> triplesNodePath .

%% PropertyListPathNotEmpty -> ( VerbPath | VerbSimple ) ObjectListPath ( ';' ( ( VerbPath | VerbSimple ) ObjectListPath )? )*
propertyListPathNotEmpty -> verbObjectList semicolonSeq propertyListPathNotEmpty .
propertyListPathNotEmpty -> verbObjectList semicolonSeq .
propertyListPathNotEmpty -> verbObjectList .
verbObjectList -> verbPath objectListPath .
verbObjectList -> verbSimple objectListPath .
semicolonSeq -> ';' semicolonSeq .
semicolonSeq -> ';' .

verbPath -> path .
verbSimple -> var .
objectListPath -> objectPath ',' objectListPath .
objectListPath -> objectPath .
objectPath -> graphNodePath .

path -> pathAlternative .
pathAlternative -> pathSequence '|' pathAlternative .
pathAlternative -> pathSequence .
pathSequence -> pathEltOrInverse '/' pathSequence .
pathSequence -> pathEltOrInverse .
pathElt -> pathPrimary pathMod .
pathElt -> pathPrimary .
pathEltOrInverse -> pathElt .
pathEltOrInverse -> '^' pathElt .
pathMod -> '?' .
pathMod -> '*' .
pathMod -> '+' .
pathPrimary -> iri .
pathPrimary -> 'a' .
pathPrimary -> '!' pathNegatedPropertySet .
pathPrimary -> '(' path ')' .
pathNegatedPropertySet -> pathOneInPropertySet .
pathNegatedPropertySet -> '(' ')' .
pathNegatedPropertySet -> '(' pathNegatedPropertySetSeq ')' .
pathNegatedPropertySetSeq -> pathOneInPropertySet '|' pathNegatedPropertySetSeq .
pathNegatedPropertySetSeq -> pathOneInPropertySet .
pathOneInPropertySet -> iri .
pathOneInPropertySet -> 'a' .
pathOneInPropertySet -> '^' iri .
pathOneInPropertySet -> '^' 'a' .

triplesNode -> collection .
triplesNode -> blankNodePropertyList .
blankNodePropertyList -> '[' propertyListNotEmpty ']' .
triplesNodePath -> collectionPath .
triplesNodePath -> blankNodePropertyListPath .
blankNodePropertyListPath -> '[' propertyListPathNotEmpty ']' .
collection -> '(' graphNodes ')' .
graphNodes -> graphNode graphNodes .
graphNodes -> graphNode .
collectionPath -> '(' graphNodePaths ')' .
graphNodePaths -> graphNodePath graphNodePaths .
graphNodePaths -> graphNodePath .
graphNode -> varOrTerm .
graphNode -> triplesNode .
graphNodePath -> varOrTerm .
graphNodePath -> triplesNodePath .
varOrTerm	-> var .
varOrTerm	-> graphTerm .
varOrIri -> var .
varOrIri -> iri .
graphTerm -> iri .
graphTerm -> rdfLiteral .
graphTerm -> numericLiteral .
graphTerm -> booleanLiteral .
graphTerm -> blankNode .
graphTerm -> nil .
expression -> conditionalOrExpression .
conditionalOrExpression -> conditionalAndExpression '||' conditionalOrExpression .
conditionalOrExpression -> conditionalAndExpression .
conditionalAndExpression -> valueLogical '&&' conditionalAndExpression .
conditionalAndExpression -> valueLogical .
valueLogical -> relationalExpression .
relationalExpression -> numericExpression .
relationalExpression -> numericExpression '=' numericExpression .
relationalExpression -> numericExpression '!=' numericExpression .
relationalExpression -> numericExpression '<' numericExpression .
relationalExpression -> numericExpression '>' numericExpression .
relationalExpression -> numericExpression '<=' numericExpression .
relationalExpression -> numericExpression '>=' numericExpression .
relationalExpression -> numericExpression 'IN' expressionList .
relationalExpression -> numericExpression 'NOT' 'IN' expressionList .
numericExpression -> additiveExpression .

%% AdditiveExpression -> MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression | ( NumericLiteralPositive | NumericLiteralNegative ) ( ( '*' UnaryExpression ) | ( '/' UnaryExpression ) )* )*
additiveExpression -> multiplicativeExpression multiplicativeExpressionSeq .
additiveExpression -> multiplicativeExpression .
multiplicativeExpressionSeq -> '+' multiplicativeExpression multiplicativeExpressionSeq .
multiplicativeExpressionSeq -> '-' multiplicativeExpression multiplicativeExpressionSeq .
multiplicativeExpressionSeq -> '+' multiplicativeExpression .
multiplicativeExpressionSeq -> '-' multiplicativeExpression .
multiplicativeExpressionSeq -> numericLiteralPositive multiplicativeUnaryExpressionSeq multiplicativeExpressionSeq .
multiplicativeExpressionSeq -> numericLiteralNegative multiplicativeUnaryExpressionSeq multiplicativeExpressionSeq .
multiplicativeExpressionSeq -> numericLiteralPositive multiplicativeExpressionSeq .
multiplicativeExpressionSeq -> numericLiteralNegative multiplicativeExpressionSeq .
multiplicativeExpressionSeq -> numericLiteralPositive multiplicativeUnaryExpressionSeq .
multiplicativeExpressionSeq -> numericLiteralNegative multiplicativeUnaryExpressionSeq .
multiplicativeExpressionSeq -> numericLiteralPositive .
multiplicativeExpressionSeq -> numericLiteralNegative .
multiplicativeUnaryExpressionSeq -> multiplicativeUnaryExpression multiplicativeUnaryExpressionSeq .
multiplicativeUnaryExpressionSeq -> multiplicativeUnaryExpression .
multiplicativeUnaryExpression -> '*' unaryExpression .
multiplicativeUnaryExpression -> '/' unaryExpression .

multiplicativeExpression -> unaryExpression '*' multiplicativeExpression .
multiplicativeExpression -> unaryExpression '/' multiplicativeExpression .
multiplicativeExpression -> unaryExpression .
unaryExpression -> '!' primaryExpression .
unaryExpression -> '+' primaryExpression .
unaryExpression -> '-' primaryExpression .
unaryExpression -> primaryExpression .
primaryExpression -> brackettedExpression .
primaryExpression -> builtInCall .
primaryExpression -> iriOrFunction .
primaryExpression -> rdfLiteral .
primaryExpression -> numericLiteral .
primaryExpression -> booleanLiteral .
primaryExpression -> var .

brackettedExpression -> '(' expression ')' .

builtInCall -> aggregate .
builtInCall -> 'STR' '(' expression ')' .
builtInCall -> 'LANG' '(' expression ')' .
builtInCall -> 'LANGMATCHES' '(' expression ',' expression ')' .
builtInCall -> 'DATATYPE' '(' expression ')' .
builtInCall -> 'BOUND' '(' var ')' .
builtInCall -> 'IRI' '(' expression ')' .
builtInCall -> 'URI' '(' expression ')' .
builtInCall -> 'BNODE' '(' expression ')' .
builtInCall -> 'BNODE' nil .
builtInCall -> 'RAND' nil .
builtInCall -> 'ABS' '(' expression ')' .
builtInCall -> 'CEIL' '(' expression ')' .
builtInCall -> 'FLOOR' '(' expression ')' .
builtInCall -> 'ROUND' '(' expression ')' .
builtInCall -> 'CONCAT' expressionList .
builtInCall -> substringExpression .
builtInCall -> 'STRLEN' '(' expression ')' .
builtInCall -> strReplaceExpression .
builtInCall -> 'UCASE' '(' expression ')' .
builtInCall -> 'LCASE' '(' expression ')' .
builtInCall -> 'ENCODE_FOR_URI' '(' expression ')' .
builtInCall -> 'CONTAINS' '(' expression ',' expression ')' .
builtInCall -> 'STRSTARTS' '(' expression ',' expression ')' .
builtInCall -> 'STRENDS' '(' expression ',' expression ')' .
builtInCall -> 'STRBEFORE' '(' expression ',' expression ')' .
builtInCall -> 'STRAFTER' '(' expression ',' expression ')' .
builtInCall -> 'YEAR' '(' expression ')' .
builtInCall -> 'MONTH' '(' expression ')' .
builtInCall -> 'DAY' '(' expression ')' .
builtInCall -> 'HOURS' '(' expression ')' .
builtInCall -> 'MINUTES' '(' expression ')' .
builtInCall -> 'SECONDS' '(' expression ')' .
builtInCall -> 'TIMEZONE' '(' expression ')' .
builtInCall -> 'TZ' '(' expression ')' .
builtInCall -> 'NOW' nil .
builtInCall -> 'UUID' nil .
builtInCall -> 'STRUUID' nil .
builtInCall -> 'MD5' '(' expression ')' .
builtInCall -> 'SHA1' '(' expression ')' .
builtInCall -> 'SHA256' '(' expression ')' .
builtInCall -> 'SHA384' '(' expression ')' .
builtInCall -> 'SHA512' '(' expression ')' .
builtInCall -> 'COALESCE' expressionList .
builtInCall -> 'IF' '(' expression ',' expression ',' expression ')' .
builtInCall -> 'STRLANG' '(' expression ',' expression ')' .
builtInCall -> 'STRDT' '(' expression ',' expression ')' .
builtInCall -> 'sameTerm' '(' expression ',' expression ')' .
builtInCall -> 'isIRI' '(' expression ')' .
builtInCall -> 'isURI' '(' expression ')' .
builtInCall -> 'isBLANK' '(' expression ')' .
builtInCall -> 'isLITERAL' '(' expression ')' .
builtInCall -> 'isNUMERIC' '(' expression ')' .
builtInCall -> regexExpression .
builtInCall -> existsFunc .
builtInCall -> notExistsFunc .

regexExpression -> 'REGEX' '(' expression ',' expression ',' expression ')' .
regexExpression -> 'REGEX' '(' expression ',' expression ')' .
substringExpression -> 'SUBSTR' '(' expression ',' expression ',' expression ')' .
substringExpression -> 'SUBSTR' '(' expression ',' expression ')' .
strReplaceExpression -> 'REPLACE' '(' expression ',' expression ',' expression ',' expression ')' .
strReplaceExpression -> 'REPLACE' '(' expression ',' expression ',' expression ')' .

existsFunc -> 'EXISTS' groupGraphPattern .
notExistsFunc -> 'NOT' 'EXISTS' groupGraphPattern .

aggregate -> 'COUNT' '(' 'DISTINCT' '*' ')' .
aggregate -> 'COUNT' '(' 'DISTINCT' expression ')' .
aggregate -> 'COUNT' '(' '*' ')' .
aggregate -> 'COUNT' '(' expression ')' .
aggregate -> 'SUM' '(' 'DISTINCT' expression ')' .
aggregate -> 'SUM' '(' expression ')' .
aggregate -> 'MIN' '(' 'DISTINCT' expression ')' .
aggregate -> 'MIN' '(' expression ')' .
aggregate -> 'MAX' '(' 'DISTINCT' expression ')' .
aggregate -> 'MAX' '(' expression ')' .
aggregate -> 'AVG' '(' 'DISTINCT' expression ')' .
aggregate -> 'AVG' '(' expression ')' .
aggregate -> 'SAMPLE' '(' 'DISTINCT' expression ')' .
aggregate -> 'SAMPLE' '(' expression ')' .
aggregate -> 'GROUP_CONCAT' '(' 'DISTINCT' expression ';' 'SEPARATOR' '=' string_literal_quote ')' .
aggregate -> 'GROUP_CONCAT' '(' 'DISTINCT' expression ')' .
aggregate -> 'GROUP_CONCAT' '(' expression ';' 'SEPARATOR' '=' string_literal_quote ')' .
aggregate -> 'GROUP_CONCAT' '(' expression ')' .

iriOrFunction -> iri argList .
iriOrFunction -> iri .

rdfLiteral -> string_literal_quote '^^' iri    : to_literal('$1', {datatype, '$3'}) .
rdfLiteral -> string_literal_quote langtag     : to_literal('$1', {language, to_langtag('$2')}) .
rdfLiteral -> string_literal_quote             : to_literal('$1') .

numericLiteral -> numericLiteralUnsigned .
numericLiteral -> numericLiteralPositive .
numericLiteral -> numericLiteralNegative .
numericLiteralUnsigned -> integer .
numericLiteralUnsigned -> decimal .
numericLiteralUnsigned -> double .
numericLiteralPositive -> integer_positive .
numericLiteralPositive -> decimal_positive .
numericLiteralPositive -> double_positive .
numericLiteralNegative -> integer_negative .
numericLiteralNegative -> decimal_negative .
numericLiteralNegative -> double_negative .

booleanLiteral -> boolean : to_literal('$1') .

iri -> iriref       : to_iri('$1') .
iri -> prefixedName : '$1' .

prefixedName -> prefix_ln : '$1' .
prefixedName -> prefix_ns : '$1' .

blankNode -> blank_node_label : to_bnode('$1') .
blankNode -> anon             : {anon} .


Erlang code.

to_iri_string(IRIREF) -> 'Elixir.RDF.Serialization.ParseHelper':to_iri_string(IRIREF) .
to_iri(IRIREF) -> 'Elixir.RDF.Serialization.ParseHelper':to_absolute_or_relative_iri(IRIREF) .
to_bnode(BLANK_NODE) -> 'Elixir.RDF.Serialization.ParseHelper':to_bnode(BLANK_NODE).
to_literal(STRING) -> 'Elixir.RDF.Serialization.ParseHelper':to_literal(STRING).
to_literal(STRING, Type) -> 'Elixir.RDF.Serialization.ParseHelper':to_literal(STRING, Type).
to_langtag(LANGTAG) -> 'Elixir.RDF.Serialization.ParseHelper':to_langtag(LANGTAG).
rdf_type() -> 'Elixir.RDF.Serialization.ParseHelper':rdf_type().
