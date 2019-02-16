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
varDecl  -> '(' expression 'AS' var ')' : {'$4', '$2'} .

constructQuery	-> 'CONSTRUCT' constructTemplate datasetClauses whereClause solutionModifier   : {construct, '$2', '$3', '$4', '$5' } .
constructQuery	-> 'CONSTRUCT' constructTemplate whereClause solutionModifier                  : {construct, '$2', nil , '$3', '$4' } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' triplesTemplate '}' solutionModifier : {construct, nil, '$2', '$5', '$7' } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' triplesTemplate '}' solutionModifier                : {construct, nil, nil , '$4', '$6' } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' '}' solutionModifier                 : {construct, nil, '$2', [], '$6' } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' '}' solutionModifier                                : {construct, nil, nil , [], '$5' } .
%% without solutionModifier
constructQuery	-> 'CONSTRUCT' constructTemplate datasetClauses whereClause   : {construct, '$2', '$3', '$4', nil } .
constructQuery	-> 'CONSTRUCT' constructTemplate whereClause                  : {construct, '$2', nil , '$3', nil } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' triplesTemplate '}' : {construct, nil, '$2', '$5', nil } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' triplesTemplate '}'                : {construct, nil, nil , '$4', nil } .
constructQuery	-> 'CONSTRUCT' datasetClauses 'WHERE' '{' '}'                 : {construct, nil, '$2', [], nil } .
constructQuery	-> 'CONSTRUCT' 'WHERE' '{' '}'                                : {construct, nil, nil , [], nil } .

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

whereClause	-> 'WHERE' groupGraphPattern : '$2' .
whereClause	-> groupGraphPattern         : '$1' .

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
groupCondition  -> builtInCall  : '$1' .
groupCondition  -> functionCall : '$1' .
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

triplesTemplate -> triplesSameSubject '.' triplesTemplate : ['$1' | '$3' ] .
triplesTemplate -> triplesSameSubject '.'                 : ['$1'] .
triplesTemplate -> triplesSameSubject                     : ['$1'] .

groupGraphPattern -> '{' subSelect '}'            : {group_graph_pattern, '$2'} .
groupGraphPattern -> '{' groupGraphPatternSub '}' : {group_graph_pattern, '$2'} .
groupGraphPattern -> '{' '}'                      : {group_graph_pattern, [] } .

%% GroupGraphPatternSub -> TriplesBlock? ( GraphPatternNotTriples '.'? TriplesBlock? )*
%% TODO: Note: This can be empty!
groupGraphPatternSub -> triplesBlock graphPatternNotTriplesBlockSeq : [{triples_block, '$1'} | '$2'].
groupGraphPatternSub -> triplesBlock : [{triples_block, '$1'}] .
groupGraphPatternSub -> graphPatternNotTriplesBlockSeq : '$1' .
graphPatternNotTriplesBlockSeq -> graphPatternNotTriplesBlock graphPatternNotTriplesBlockSeq : '$1' ++ '$2' .
graphPatternNotTriplesBlockSeq -> graphPatternNotTriplesBlock                                : '$1' .
graphPatternNotTriplesBlock -> graphPatternNotTriples '.' triplesBlock : ['$1', {triples_block, '$3'}] .
graphPatternNotTriplesBlock -> graphPatternNotTriples '.'              : ['$1'] .
graphPatternNotTriplesBlock -> graphPatternNotTriples triplesBlock     : ['$1', {triples_block, '$2'}] .
graphPatternNotTriplesBlock -> graphPatternNotTriples                  : ['$1'] .

triplesBlock -> triplesSameSubjectPath '.' triplesBlock : ['$1' | '$3'] .
triplesBlock -> triplesSameSubjectPath '.'              : ['$1'] .
triplesBlock -> triplesSameSubjectPath                  : ['$1'] .

graphPatternNotTriples -> groupOrUnionGraphPattern : '$1' .
graphPatternNotTriples -> optionalGraphPattern     : '$1' .
graphPatternNotTriples -> minusGraphPattern        : '$1' .
graphPatternNotTriples -> graphGraphPattern        : '$1' .
graphPatternNotTriples -> serviceGraphPattern      : '$1' .
graphPatternNotTriples -> filter                   : '$1' .
graphPatternNotTriples -> bind                     : '$1' .
graphPatternNotTriples -> inlineData               : '$1' .

optionalGraphPattern -> 'OPTIONAL' groupGraphPattern : {optional, '$2'}.
graphGraphPattern    -> 'GRAPH' varOrIri groupGraphPattern .
serviceGraphPattern  -> 'SERVICE' 'SILENT' varOrIri groupGraphPattern .
serviceGraphPattern  -> 'SERVICE' varOrIri groupGraphPattern .

bind -> 'BIND' '(' expression 'AS' var ')' : {bind, '$3', '$5'}.

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

minusGraphPattern -> 'MINUS' groupGraphPattern : {minus, '$2'} .
groupOrUnionGraphPattern -> groupGraphPattern 'UNION' groupOrUnionGraphPattern : {union, '$1', '$3'} .
groupOrUnionGraphPattern -> groupGraphPattern : '$1'.

filter -> 'FILTER' constraint : {filter, '$2' }.

constraint -> brackettedExpression : '$1' .
constraint -> builtInCall          : '$1' .
constraint -> functionCall         : '$1' .

functionCall -> iri argList : {function_call, '$1', '$2'} .

%% ArgList -> NIL | '(' 'DISTINCT'? Expression ( ',' Expression )* ')'
argList -> nil                                         : [] .
argList -> '(' 'DISTINCT' expression expressionSeq ')' : ['$2', '$3' | '$4'] .
argList -> '(' 'DISTINCT' expression  ')'              : ['$2', '$3'] .
argList -> '(' expression expressionSeq ')'            : ['$2' | '$3'] .
argList -> '(' expression  ')'                         : ['$2'] .

%% ExpressionList -> NIL | '(' Expression ( ',' Expression )* ')'
expressionList -> nil                              : [] .
expressionList -> '(' expression ')'               : ['$2'] .
expressionList -> '(' expression expressionSeq ')' : ['$2' | '$3'] .
expressionSeq -> ',' expression expressionSeq : ['$2' | '$3'] .
expressionSeq -> ',' expression               : ['$2'] .

constructTemplate -> '{' constructTriples '}' : '$2' .
constructTemplate -> '{' '}' 									: [] .
constructTriples -> triplesSameSubject '.' constructTriples : ['$1' | '$3'] .
constructTriples -> triplesSameSubject '.'                  : ['$1'] .
constructTriples -> triplesSameSubject                      : ['$1'] .

triplesSameSubject -> varOrTerm propertyListNotEmpty : [{subject, '$1'} | '$2'] .
triplesSameSubject -> triplesNode propertyList       : [{subject, '$1'} | '$2'] .
triplesSameSubject -> triplesNode                    : [{subject, '$1'}] .
propertyList -> propertyListNotEmpty : '$1' .
%% PropertyListNotEmpty -> Verb ObjectList ( ';' ( Verb ObjectList )? )*
propertyListNotEmpty -> verb objectList propertyListNotEmptyVerbObjectList : [{predicate, '$1'} | '$2'] ++ '$3' .
propertyListNotEmpty -> verb objectList                                    : [{predicate, '$1'} | '$2'] .
propertyListNotEmptyVerbObjectList -> ';' verb objectList propertyListNotEmptyVerbObjectList : [{predicate, '$2'} | '$3'] ++ '$4' .
propertyListNotEmptyVerbObjectList -> ';' propertyListNotEmptyVerbObjectList : '$2' .
propertyListNotEmptyVerbObjectList -> ';' verb objectList                    : [{predicate, '$2'} | '$3'].
propertyListNotEmptyVerbObjectList -> ';'                                    : [] .

verb -> varOrIri : '$1' .
verb -> 'a'      : rdf_type() .

objectList -> object ',' objectList : [{object, '$1'} | '$3'] .
objectList -> object                : [{object, '$1'}] .
object     -> graphNode             : '$1' .

triplesSameSubjectPath -> varOrTerm propertyListPathNotEmpty       : [{subject, '$1'} | '$2'] .
triplesSameSubjectPath -> triplesNodePath propertyListPathNotEmpty : [{subject, '$1'} | '$2'] .
triplesSameSubjectPath -> triplesNodePath                          : [{subject, '$1'}] .

%% PropertyListPathNotEmpty -> ( VerbPath | VerbSimple ) ObjectListPath ( ';' ( ( VerbPath | VerbSimple ) ObjectListPath )? )*
propertyListPathNotEmpty -> verbObjectList semicolonSeq propertyListPathNotEmpty : '$1' ++ '$3' .
propertyListPathNotEmpty -> verbObjectList semicolonSeq                          : '$1' .
propertyListPathNotEmpty -> verbObjectList                                       : '$1' .
verbObjectList -> verbPath objectListPath   : [{predicate, '$1'} | '$2'] .
verbObjectList -> verbSimple objectListPath : [{predicate, '$1'} | '$2'] .
semicolonSeq -> ';' semicolonSeq .
semicolonSeq -> ';' .

verbPath -> path  : '$1' .
verbSimple -> var : '$1' .
objectListPath -> objectPath ',' objectListPath : [{object, '$1'} | '$3'] .
objectListPath -> objectPath : [{object, '$1'}] .
objectPath -> graphNodePath  : '$1' .

path -> pathAlternative : '$1' .
pathAlternative -> pathSequence '|' pathAlternative .
pathAlternative -> pathSequence : '$1' .
pathSequence -> pathEltOrInverse '/' pathSequence .
pathSequence -> pathEltOrInverse : '$1' .
pathElt -> pathPrimary pathMod .
pathElt -> pathPrimary : '$1' .
pathEltOrInverse -> pathElt : '$1' .
pathEltOrInverse -> '^' pathElt .
pathMod -> '?' .
pathMod -> '*' .
pathMod -> '+' .
pathPrimary -> iri : '$1' .
pathPrimary -> 'a' : rdf_type() .
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

triplesNode -> collection            : '$1' .
triplesNode -> blankNodePropertyList : '$1' .
blankNodePropertyList -> '[' propertyListNotEmpty ']' : {blank_node_property_list, '$2'} .

triplesNodePath -> collectionPath            : '$1' .
triplesNodePath -> blankNodePropertyListPath : '$1' .
blankNodePropertyListPath -> '[' propertyListPathNotEmpty ']' : {blank_node_property_list, '$2'} .

collection -> '(' graphNodes ')'   : {collection, '$2'} .
graphNodes -> graphNode graphNodes : ['$1' | '$2'] .
graphNodes -> graphNode            : ['$1'] .

collectionPath -> '(' graphNodePaths ')'       : {collection, '$2'} .
graphNodePaths -> graphNodePath graphNodePaths : ['$1' | '$2'] .
graphNodePaths -> graphNodePath                : ['$1'] .

graphNode -> varOrTerm   : '$1' .
graphNode -> triplesNode : '$1' .
graphNodePath -> varOrTerm       : '$1' .
graphNodePath -> triplesNodePath : '$1' .

varOrTerm	-> var            : '$1' .
varOrTerm	-> graphTerm      : '$1' .
varOrIri  -> var            : '$1' .
varOrIri  -> iri            : '$1' .
graphTerm -> iri            : '$1' .
graphTerm -> rdfLiteral     : '$1' .
graphTerm -> numericLiteral : '$1' .
graphTerm -> booleanLiteral : '$1' .
graphTerm -> blankNode      : '$1' .
graphTerm -> nil            : '$1' .

expression -> conditionalOrExpression : '$1' .
conditionalOrExpression -> conditionalAndExpression '||' conditionalOrExpression : {builtin_function_call, '||' , ['$1', '$3']} .
conditionalOrExpression -> conditionalAndExpression : '$1' .
conditionalAndExpression -> valueLogical '&&' conditionalAndExpression : {builtin_function_call, '&&' , ['$1', '$3']} .
conditionalAndExpression -> valueLogical : '$1' .
valueLogical -> relationalExpression : '$1' .
relationalExpression -> numericExpression : '$1' .
relationalExpression -> numericExpression '=' numericExpression     : {builtin_function_call, '=' , ['$1', '$3']} .
relationalExpression -> numericExpression '!=' numericExpression    : {builtin_function_call, '!=', ['$1', '$3']} .
relationalExpression -> numericExpression '<' numericExpression     : {builtin_function_call, '<' , ['$1', '$3']} .
relationalExpression -> numericExpression '>' numericExpression     : {builtin_function_call, '>' , ['$1', '$3']} .
relationalExpression -> numericExpression '<=' numericExpression    : {builtin_function_call, '<=', ['$1', '$3']} .
relationalExpression -> numericExpression '>=' numericExpression    : {builtin_function_call, '>=', ['$1', '$3']} .
relationalExpression -> numericExpression 'IN' expressionList       : {builtin_function_call, 'IN', ['$1', '$3']} .
relationalExpression -> numericExpression 'NOT' 'IN' expressionList : {builtin_function_call, 'NOT_IN', ['$1', '$4']} .
numericExpression -> additiveExpression : '$1' .

%% AdditiveExpression -> MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression | ( NumericLiteralPositive | NumericLiteralNegative ) ( ( '*' UnaryExpression ) | ( '/' UnaryExpression ) )* )*
additiveExpression -> multiplicativeExpression multiplicativeExpressionSeq : arithmetic_expr('$1', '$2') .
additiveExpression -> multiplicativeExpression : arithmetic_expr('$1') .
multiplicativeExpressionSeq -> '+' multiplicativeExpression multiplicativeExpressionSeq : arithmetic_expr('$1', '$2', '$3') .
multiplicativeExpressionSeq -> '-' multiplicativeExpression multiplicativeExpressionSeq : arithmetic_expr('$1', '$2', '$3') .
multiplicativeExpressionSeq -> '+' multiplicativeExpression : ['$1', '$2'] .
multiplicativeExpressionSeq -> '-' multiplicativeExpression : ['$1', '$2'] .
multiplicativeExpressionSeq -> numericLiteralPositive multiplicativeUnaryExpressionSeq multiplicativeExpressionSeq : arithmetic_quirk_expr('+', strip_sign('$1'), '$2', '$3') .
multiplicativeExpressionSeq -> numericLiteralNegative multiplicativeUnaryExpressionSeq multiplicativeExpressionSeq : arithmetic_quirk_expr('-', strip_sign('$1'), '$2', '$3') .
multiplicativeExpressionSeq -> numericLiteralPositive multiplicativeExpressionSeq      : arithmetic_expr('+', strip_sign('$1'), '$2') .
multiplicativeExpressionSeq -> numericLiteralNegative multiplicativeExpressionSeq      : arithmetic_expr('-', strip_sign('$1'), '$2') .
multiplicativeExpressionSeq -> numericLiteralPositive multiplicativeUnaryExpressionSeq : multiplicative_quirk_expr('+', strip_sign('$1'), '$2') .
multiplicativeExpressionSeq -> numericLiteralNegative multiplicativeUnaryExpressionSeq : multiplicative_quirk_expr('-', strip_sign('$1'), '$2') .
multiplicativeExpressionSeq -> numericLiteralPositive : ['+', strip_sign('$1')] .
multiplicativeExpressionSeq -> numericLiteralNegative : ['-', strip_sign('$1')] .
multiplicativeUnaryExpressionSeq -> multiplicativeUnaryExpression multiplicativeUnaryExpressionSeq : arithmetic_expr('$1', '$2') .
multiplicativeUnaryExpressionSeq -> multiplicativeUnaryExpression : '$1' .
multiplicativeUnaryExpression -> '*' unaryExpression : ['$1', '$2'] .
multiplicativeUnaryExpression -> '/' unaryExpression : ['$1', '$2'] .

multiplicativeExpression -> unaryExpression '*' multiplicativeExpression : multiplicative_expr('$2', '$1', '$3') .
multiplicativeExpression -> unaryExpression '/' multiplicativeExpression : multiplicative_expr('$2', '$1', '$3') .
multiplicativeExpression -> unaryExpression                              : '$1' .
unaryExpression -> '!' primaryExpression  : {builtin_function_call, '!', ['$2']} .
unaryExpression -> '+' primaryExpression  : {builtin_function_call, '+', ['$2']} .
unaryExpression -> '-' primaryExpression  : {builtin_function_call, '-', ['$2']} .
unaryExpression -> primaryExpression      : '$1' .
primaryExpression -> brackettedExpression : '$1' .
primaryExpression -> builtInCall          : '$1' .
primaryExpression -> iriOrFunction        : '$1' .
primaryExpression -> rdfLiteral           : '$1' .
primaryExpression -> numericLiteral       : '$1' .
primaryExpression -> booleanLiteral       : '$1' .
primaryExpression -> var                  : '$1' .

brackettedExpression -> '(' expression ')' : '$2' .

builtInCall -> aggregate : '$1' .
builtInCall -> 'STR' '(' expression ')'                              : {builtin_function_call, 'STR', ['$3']} .
builtInCall -> 'LANG' '(' expression ')'                             : {builtin_function_call, 'LANG', ['$3']} .
builtInCall -> 'LANGMATCHES' '(' expression ',' expression ')'       : {builtin_function_call, 'LANGMATCHES', ['$3', '$5']} .
builtInCall -> 'DATATYPE' '(' expression ')'                         : {builtin_function_call, 'DATATYPE', ['$3']} .
builtInCall -> 'BOUND' '(' var ')'                                   : {builtin_function_call, 'BOUND', ['$3']} .
builtInCall -> 'IRI' '(' expression ')'                              : {builtin_function_call, 'IRI', ['$3']} .
builtInCall -> 'URI' '(' expression ')'                              : {builtin_function_call, 'URI', ['$3']} .
builtInCall -> 'BNODE' '(' expression ')'                            : {builtin_function_call, 'BNODE', ['$3']} .
builtInCall -> 'BNODE' nil                                           : {builtin_function_call, 'BNODE', []} .
builtInCall -> 'RAND' nil                                            : {builtin_function_call, 'RAND', []} .
builtInCall -> 'ABS' '(' expression ')'                              : {builtin_function_call, 'ABS', ['$3']} .
builtInCall -> 'CEIL' '(' expression ')'                             : {builtin_function_call, 'CEIL', ['$3']} .
builtInCall -> 'FLOOR' '(' expression ')'                            : {builtin_function_call, 'FLOOR', ['$3']} .
builtInCall -> 'ROUND' '(' expression ')'                            : {builtin_function_call, 'ROUND', ['$3']} .
builtInCall -> 'CONCAT' expressionList                               : {builtin_function_call, 'CONCAT', '$2'} .
builtInCall -> substringExpression                                   : '$1' .
builtInCall -> 'STRLEN' '(' expression ')'                           : {builtin_function_call, 'STRLEN', ['$3']} .
builtInCall -> strReplaceExpression                                  : '$1' .
builtInCall -> 'UCASE' '(' expression ')'                            : {builtin_function_call, 'UCASE', ['$3']} .
builtInCall -> 'LCASE' '(' expression ')'                            : {builtin_function_call, 'LCASE', ['$3']} .
builtInCall -> 'ENCODE_FOR_URI' '(' expression ')'                   : {builtin_function_call, 'ENCODE_FOR_URI', ['$3']} .
builtInCall -> 'CONTAINS' '(' expression ',' expression ')'          : {builtin_function_call, 'CONTAINS', ['$3', '$5']} .
builtInCall -> 'STRSTARTS' '(' expression ',' expression ')'         : {builtin_function_call, 'STRSTARTS', ['$3', '$5']} .
builtInCall -> 'STRENDS' '(' expression ',' expression ')'           : {builtin_function_call, 'STRENDS', ['$3', '$5']} .
builtInCall -> 'STRBEFORE' '(' expression ',' expression ')'         : {builtin_function_call, 'STRBEFORE', ['$3', '$5']} .
builtInCall -> 'STRAFTER' '(' expression ',' expression ')'          : {builtin_function_call, 'STRAFTER', ['$3', '$5']} .
builtInCall -> 'YEAR' '(' expression ')'                             : {builtin_function_call, 'YEAR', ['$3']} .
builtInCall -> 'MONTH' '(' expression ')'                            : {builtin_function_call, 'MONTH', ['$3']} .
builtInCall -> 'DAY' '(' expression ')'                              : {builtin_function_call, 'DAY', ['$3']} .
builtInCall -> 'HOURS' '(' expression ')'                            : {builtin_function_call, 'HOURS', ['$3']} .
builtInCall -> 'MINUTES' '(' expression ')'                          : {builtin_function_call, 'MINUTES', ['$3']} .
builtInCall -> 'SECONDS' '(' expression ')'                          : {builtin_function_call, 'SECONDS', ['$3']} .
builtInCall -> 'TIMEZONE' '(' expression ')'                         : {builtin_function_call, 'TIMEZONE', ['$3']} .
builtInCall -> 'TZ' '(' expression ')'                               : {builtin_function_call, 'TZ', ['$3']} .
builtInCall -> 'NOW' nil                                             : {builtin_function_call, 'NOW', []} .
builtInCall -> 'UUID' nil                                            : {builtin_function_call, 'UUID', []} .
builtInCall -> 'STRUUID' nil                                         : {builtin_function_call, 'STRUUID', []} .
builtInCall -> 'MD5' '(' expression ')'                              : {builtin_function_call, 'MD5', ['$3']} .
builtInCall -> 'SHA1' '(' expression ')'                             : {builtin_function_call, 'SHA1', ['$3']} .
builtInCall -> 'SHA256' '(' expression ')'                           : {builtin_function_call, 'SHA256', ['$3']} .
builtInCall -> 'SHA384' '(' expression ')'                           : {builtin_function_call, 'SHA384', ['$3']} .
builtInCall -> 'SHA512' '(' expression ')'                           : {builtin_function_call, 'SHA512', ['$3']} .
builtInCall -> 'COALESCE' expressionList                             : {builtin_function_call, 'COALESCE', '$2'} .
builtInCall -> 'IF' '(' expression ',' expression ',' expression ')' : {builtin_function_call, 'IF', ['$3', '$5', '$7']} .
builtInCall -> 'STRLANG' '(' expression ',' expression ')'           : {builtin_function_call, 'STRLANG', ['$3', '$5']} .
builtInCall -> 'STRDT' '(' expression ',' expression ')'             : {builtin_function_call, 'STRDT', ['$3', '$5']} .
builtInCall -> 'sameTerm' '(' expression ',' expression ')'          : {builtin_function_call, 'sameTerm', ['$3', '$5']} .
builtInCall -> 'isIRI' '(' expression ')'                            : {builtin_function_call, 'isIRI', ['$3']} .
builtInCall -> 'isURI' '(' expression ')'                            : {builtin_function_call, 'isURI', ['$3']} .
builtInCall -> 'isBLANK' '(' expression ')'                          : {builtin_function_call, 'isBLANK', ['$3']} .
builtInCall -> 'isLITERAL' '(' expression ')'                        : {builtin_function_call, 'isLITERAL', ['$3']} .
builtInCall -> 'isNUMERIC' '(' expression ')'                        : {builtin_function_call, 'isNUMERIC', ['$3']} .
builtInCall -> regexExpression : '$1' .
builtInCall -> existsFunc      : '$1' .
builtInCall -> notExistsFunc   : '$1' .

regexExpression -> 'REGEX' '(' expression ',' expression ',' expression ')' : {builtin_function_call, 'REGEX', ['$3', '$5', '$7']} .
regexExpression -> 'REGEX' '(' expression ',' expression ')'                : {builtin_function_call, 'REGEX', ['$3', '$5']} .
substringExpression -> 'SUBSTR' '(' expression ',' expression ',' expression ')' : {builtin_function_call, 'SUBSTR', ['$3', '$5', '$7']} .
substringExpression -> 'SUBSTR' '(' expression ',' expression ')'                : {builtin_function_call, 'SUBSTR', ['$3', '$5']} .
strReplaceExpression -> 'REPLACE' '(' expression ',' expression ',' expression ',' expression ')' : {builtin_function_call, 'REPLACE', ['$3', '$5', '$7', '$9']} .
strReplaceExpression -> 'REPLACE' '(' expression ',' expression ',' expression ')'                : {builtin_function_call, 'REPLACE', ['$3', '$5', '$7']} .

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

iriOrFunction -> iri argList : {function_call, '$1', '$2'}.
iriOrFunction -> iri : '$1' .

rdfLiteral -> string_literal_quote '^^' iri    : to_literal('$1', {datatype, '$3'}) .
rdfLiteral -> string_literal_quote langtag     : to_literal('$1', {language, to_langtag('$2')}) .
rdfLiteral -> string_literal_quote             : to_literal('$1') .

numericLiteral -> numericLiteralUnsigned   : '$1' .
numericLiteral -> numericLiteralPositive   : '$1' .
numericLiteral -> numericLiteralNegative   : '$1' .
numericLiteralUnsigned -> integer          : extract_literal('$1') .
numericLiteralUnsigned -> decimal          : extract_literal('$1') .
numericLiteralUnsigned -> double           : extract_literal('$1') .
numericLiteralPositive -> integer_positive : extract_literal('$1') .
numericLiteralPositive -> decimal_positive : extract_literal('$1') .
numericLiteralPositive -> double_positive  : extract_literal('$1') .
numericLiteralNegative -> integer_negative : extract_literal('$1') .
numericLiteralNegative -> decimal_negative : extract_literal('$1') .
numericLiteralNegative -> double_negative  : extract_literal('$1') .

booleanLiteral -> boolean : to_literal('$1') .

iri -> iriref       : to_iri('$1') .
iri -> prefixedName : '$1' .

prefixedName -> prefix_ln : '$1' .
prefixedName -> prefix_ns : '$1' .

blankNode -> blank_node_label : to_bnode('$1') .
blankNode -> anon             : to_bnode('$1') .


Erlang code.

to_iri_string(IRIREF) -> 'Elixir.RDF.Serialization.ParseHelper':to_iri_string(IRIREF) .
to_iri(IRIREF) -> 'Elixir.RDF.Serialization.ParseHelper':to_absolute_or_relative_iri(IRIREF) .
to_bnode(BLANK_NODE) -> 'Elixir.RDF.Serialization.ParseHelper':to_bnode(BLANK_NODE).
to_literal(STRING) -> 'Elixir.RDF.Serialization.ParseHelper':to_literal(STRING).
to_literal(STRING, Type) -> 'Elixir.RDF.Serialization.ParseHelper':to_literal(STRING, Type).
to_langtag(LANGTAG) -> 'Elixir.RDF.Serialization.ParseHelper':to_langtag(LANGTAG).
rdf_type() -> 'Elixir.RDF.Serialization.ParseHelper':rdf_type().
extract_literal(LITERAL) -> 'Elixir.SPARQL.Language.ParseHelper':extract_literal(LITERAL).
arithmetic_expr(EXPR) -> 'Elixir.SPARQL.Language.ParseHelper':arithmetic_expr(EXPR).
arithmetic_expr(LEFT, RIGHT) -> 'Elixir.SPARQL.Language.ParseHelper':arithmetic_expr(LEFT, RIGHT).
arithmetic_expr(OP, LEFT, RIGHT) -> 'Elixir.SPARQL.Language.ParseHelper':arithmetic_expr(OP, LEFT, RIGHT).
arithmetic_quirk_expr(SIGN, LEFT, MIDDLE, RIGHT) -> 'Elixir.SPARQL.Language.ParseHelper':arithmetic_quirk_expr(SIGN, LEFT, MIDDLE, RIGHT).
multiplicative_expr(OP, LEFT, RIGHT) -> 'Elixir.SPARQL.Language.ParseHelper':multiplicative_expr(OP, LEFT, RIGHT).
multiplicative_quirk_expr(SIGN, LEFT, RIGHT) -> 'Elixir.SPARQL.Language.ParseHelper':multiplicative_quirk_expr(SIGN, LEFT, RIGHT).
strip_sign(LITERAL) -> 'Elixir.SPARQL.Language.ParseHelper':strip_sign(LITERAL).
