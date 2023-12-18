%% \00=NULL
%% \01-\x1F=control codes
%% \x20=space

Definitions.

COMMENT = #[^\n\r]*

WS	  =	[\s\t\n\r]
ANON	=	\[{WS}*\]
NIL	  =	\({WS}*\)

HEX           = ([0-9]|[A-F]|[a-f])
ECHAR         = \\[tbnrf"'\\]
PERCENT	      =	(%{HEX}{HEX})
PN_CHARS_BASE = ([A-Z]|[a-z]|[\x{00C0}-\x{00D6}]|[\x{00D8}-\x{00F6}]|[\x{00F8}-\x{02FF}]|[\x{0370}-\x{037D}]|[\x{037F}-\x{1FFF}]|[\x{200C}-\x{200D}]|[\x{2070}-\x{218F}]|[\x{2C00}-\x{2FEF}]|[\x{3001}-\x{D7FF}]|[\x{F900}-\x{FDCF}]|[\x{FDF0}-\x{FFFD}]|[\x{10000}-\x{EFFFF}])
PN_CHARS_U    = ({PN_CHARS_BASE}|_)
PN_CHARS      = ({PN_CHARS_U}|-|[0-9]|\x{00B7}|[\x{0300}-\x{036F}]|[\x{203F}-\x{2040}])
PN_PREFIX	    =	({PN_CHARS_BASE}(({PN_CHARS}|\.)*{PN_CHARS})?)
PN_LOCAL_ESC  =	\\(_|~|\.|\-|\!|\$|\&|\'|\(|\)|\*|\+|\,|\;|\=|\/|\?|\#|\@|\%)
%% Other implementations allow escaping of colons. Why?
%% PN_LOCAL_ESC  =	\\(_|~|\.|\-|\!|\$|\&|\'|\(|\)|\*|\+|\,|\;|\=|\/|\?|\#|\@|\%|\:)
PLX           =	({PERCENT}|{PN_LOCAL_ESC})
PN_LOCAL	    =	({PN_CHARS_U}|:|[0-9]|{PLX})(({PN_CHARS}|\.|:|{PLX})*({PN_CHARS}|:|{PLX}))?
PNAME_NS	    =	{PN_PREFIX}?:
PNAME_LN	    =	{PNAME_NS}{PN_LOCAL}

EXPONENT	=	([eE][+-]?[0-9]+)
BOOLEAN   = [Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]
INTEGER	  =	[0-9]+
DECIMAL	  =	[0-9]*\.[0-9]+
DOUBLE	  =	([0-9]+\.[0-9]*{EXPONENT}|\.[0-9]+{EXPONENT}|[0-9]+{EXPONENT})
INTEGER_POSITIVE	= [+]{INTEGER}
DECIMAL_POSITIVE	=	[+]{DECIMAL}
DOUBLE_POSITIVE	  =	[+]{DOUBLE}
INTEGER_NEGATIVE	=	[-]{INTEGER}
DECIMAL_NEGATIVE	=	[-]{DECIMAL}
DOUBLE_NEGATIVE	  =	[-]{DOUBLE}

IRIREF = <([^\x00-\x20<>"{}|^`\\])*>
STRING_LITERAL_QUOTE              = "([^"\\\n\r]|{ECHAR})*"
STRING_LITERAL_SINGLE_QUOTE	      =	'([^'\\\n\r]|{ECHAR})*'
STRING_LITERAL_LONG_SINGLE_QUOTE	=	'''(('|'')?([^'\\]|{ECHAR}))*'''
STRING_LITERAL_LONG_QUOTE	        =	"""(("|"")?([^"\\]|{ECHAR}))*"""
BLANK_NODE_LABEL = _:({PN_CHARS_U}|[0-9])(({PN_CHARS}|\.)*({PN_CHARS}))?
LANGTAG	=	@[a-zA-Z]+(-[a-zA-Z0-9]+)*

VARNAME = ({PN_CHARS_U}|[0-9])({PN_CHARS_U}|[0-9]|\x{00B7}|[\x{0300}-\x{036F}]|[\x{203F}-\x{2040}])*
VAR1 = \?{VARNAME}
VAR2 = \${VARNAME}


BASE            = [Bb][Aa][Ss][Ee]
PREFIX          = [Pp][Rr][Ee][Ff][Ii][Xx]
SELECT          = [Ss][Ee][Ll][Ee][Cc][Tt]
CONSTRUCT       = [Cc][Oo][Nn][Ss][Tt][Rr][Uu][Cc][Tt]
DESCRIBE        = [Dd][Ee][Ss][Cc][Rr][Ii][Bb][Ee]
ASK             = [Aa][Ss][Kk]
DISTINCT        = [Dd][Ii][Ss][Tt][Ii][Nn][Cc][Tt]
REDUCED         = [Rr][Ee][Dd][Uu][Cc][Ee][Dd]
FROM            = [Ff][Rr][Oo][Mm]
NAMED           = [Nn][Aa][Mm][Ee][Dd]
AS              = [Aa][Ss]
WHERE           = [Ww][Hh][Ee][Rr][Ee]
GROUP           = [Gg][Rr][Oo][Uu][Pp]
BY              = [Bb][Yy]
HAVING          = [Hh][Aa][Vv][Ii][Nn][Gg]
ORDER           = [Oo][Rr][Dd][Ee][Rr]
ASC             = [Aa][Ss][Cc]
DESC            = [Dd][Ee][Ss][Cc]
LIMIT           = [Ll][Ii][Mm][Ii][Tt]
OFFSET          = [Oo][Ff][Ff][Ss][Ee][Tt]
VALUES          = [Vv][Aa][Ll][Uu][Ee][Ss]
OPTIONAL        = [Oo][Pp][Tt][Ii][Oo][Nn][Aa][Ll]
GRAPH           = [Gg][Rr][Aa][Pp][Hh]
SERVICE         = [Ss][Ee][Rr][Vv][Ii][Cc][Ee]
SILENT          = [Ss][Ii][Ll][Ee][Nn][Tt]
BIND            = [Bb][Ii][Nn][Dd]
UNDEF           = [Uu][Nn][Dd][Ee][Ff]
MINUS           = [Mm][Ii][Nn][Uu][Ss]
UNION           = [Uu][Nn][Ii][Oo][Nn]
FILTER          = [Ff][Ii][Ll][Tt][Ee][Rr]
IN              = [Ii][Nn]
STR             = [Ss][Tt][Rr]
LANG            = [Ll][Aa][Nn][Gg]
LANGMATCHES     = [Ll][Aa][Nn][Gg][Mm][Aa][Tt][Cc][Hh][Ee][Ss]
DATATYPE        = [Dd][Aa][Tt][Aa][Tt][Yy][Pp][Ee]
BOUND           = [Bb][Oo][Uu][Nn][Dd]
IRI             = [Ii][Rr][Ii]
URI             = [Uu][Rr][Ii]
BNODE           = [Bb][Nn][Oo][Dd][Ee]
RAND            = [Rr][Aa][Nn][Dd]
ABS             = [Aa][Bb][Ss]
CEIL            = [Cc][Ee][Ii][Ll]
FLOOR           = [Ff][Ll][Oo][Oo][Rr]
ROUND           = [Rr][Oo][Uu][Nn][Dd]
CONCAT          = [Cc][Oo][Nn][Cc][Aa][Tt]
STRLEN          = [Ss][Tt][Rr][Ll][Ee][Nn]
UCASE           = [Uu][Cc][Aa][Ss][Ee]
LCASE           = [Ll][Cc][Aa][Ss][Ee]
ENCODE_FOR_URI  = [Ee][Nn][Cc][Oo][Dd][Ee]_[Ff][Oo][Rr]_[Uu][Rr][Ii]
CONTAINS        = [Cc][Oo][Nn][Tt][Aa][Ii][Nn][Ss]
STRSTARTS       = [Ss][Tt][Rr][Ss][Tt][Aa][Rr][Tt][Ss]
STRENDS         = [Ss][Tt][Rr][Ee][Nn][Dd][Ss]
STRBEFORE       = [Ss][Tt][Rr][Bb][Ee][Ff][Oo][Rr][Ee]
STRAFTER        = [Ss][Tt][Rr][Aa][Ff][Tt][Ee][Rr]
YEAR            = [Yy][Ee][Aa][Rr]
MONTH           = [Mm][Oo][Nn][Tt][Hh]
DAY             = [Dd][Aa][Yy]
HOURS           = [Hh][Oo][Uu][Rr][Ss]
MINUTES         = [Mm][Ii][Nn][Uu][Tt][Ee][Ss]
SECONDS         = [Ss][Ee][Cc][Oo][Nn][Dd][Ss]
TIMEZONE        = [Tt][Ii][Mm][Ee][Zz][Oo][Nn][Ee]
TZ              = [Tt][Zz]
NOW             = [Nn][Oo][Ww]
UUID            = [Uu][Uu][Ii][Dd]
STRUUID         = [Ss][Tt][Rr][Uu][Uu][Ii][Dd]
MD5             = [Mm][Dd]5
SHA1            = [Ss][Hh][Aa]1
SHA256          = [Ss][Hh][Aa]256
SHA384          = [Ss][Hh][Aa]384
SHA512          = [Ss][Hh][Aa]512
COALESCE        = [Cc][Oo][Aa][Ll][Ee][Ss][Cc][Ee]
IF              = [Ii][Ff]
STRLANG         = [Ss][Tt][Rr][Ll][Aa][Nn][Gg]
STRDT           = [Ss][Tt][Rr][Dd][Tt]
SameTerm        = [Ss][Aa][Mm][Ee][Tt][Ee][Rr][Mm]
IsIRI           = [Ii][Ss][Ii][Rr][Ii]
IsURI           = [Ii][Ss][Uu][Rr][Ii]
IsBLANK         = [Ii][Ss][Bb][Ll][Aa][Nn][Kk]
IsLITERAL       = [Ii][Ss][Ll][Ii][Tt][Ee][Rr][Aa][Ll]
IsNUMERIC       = [Ii][Ss][Nn][Uu][Mm][Ee][Rr][Ii][Cc]
REGEX           = [Rr][Ee][Gg][Ee][Xx]
SUBSTR          = [Ss][Uu][Bb][Ss][Tt][Rr]
REPLACE         = [Rr][Ee][Pp][Ll][Aa][Cc][Ee]
EXISTS          = [Ee][Xx][Ii][Ss][Tt][Ss]
NOT             = [Nn][Oo][Tt]
COUNT           = [Cc][Oo][Uu][Nn][Tt]
SUM             = [Ss][Uu][Mm]
MIN             = [Mm][Ii][Nn]
MAX             = [Mm][Aa][Xx]
AVG             = [Aa][Vv][Gg]
SAMPLE          = [Ss][Aa][Mm][Pp][Ll][Ee]
GROUP_CONCAT    = [Gg][Rr][Oo][Uu][Pp]_[Cc][Oo][Nn][Cc][Aa][Tt]
SEPARATOR       = [Ss][Ee][Pp][Aa][Rr][Aa][Tt][Oo][Rr]


Rules.

{BASE}                             : {token, {'BASE', TokenLine}}.
{PREFIX}                           : {token, {'PREFIX', TokenLine}}.
{SELECT}                           : {token, {'SELECT', TokenLine}}.
{CONSTRUCT}                        : {token, {'CONSTRUCT', TokenLine}}.
{DESCRIBE}                         : {token, {'DESCRIBE', TokenLine}}.
{ASK}                              : {token, {'ASK', TokenLine}}.
{DISTINCT}                         : {token, {'DISTINCT', TokenLine}}.
{REDUCED}                          : {token, {'REDUCED', TokenLine}}.
{FROM}                             : {token, {'FROM', TokenLine}}.
{NAMED}                            : {token, {'NAMED', TokenLine}}.
{AS}                               : {token, {'AS', TokenLine}}.
{WHERE}                            : {token, {'WHERE', TokenLine}}.
{GROUP}                            : {token, {'GROUP', TokenLine}}.
{BY}                               : {token, {'BY', TokenLine}}.
{HAVING}                           : {token, {'HAVING', TokenLine}}.
{ORDER}                            : {token, {'ORDER', TokenLine}}.
{ASC}                              : {token, {'ASC', TokenLine}}.
{DESC}                             : {token, {'DESC', TokenLine}}.
{LIMIT}                            : {token, {'LIMIT', TokenLine}}.
{OFFSET}                           : {token, {'OFFSET', TokenLine}}.
{VALUES}                           : {token, {'VALUES', TokenLine}}.
{OPTIONAL}                         : {token, {'OPTIONAL', TokenLine}}.
{GRAPH}                            : {token, {'GRAPH', TokenLine}}.
{SERVICE}                          : {token, {'SERVICE', TokenLine}}.
{SILENT}                           : {token, {'SILENT', TokenLine}}.
{BIND}                             : {token, {'BIND', TokenLine}}.
{UNDEF}                            : {token, {'UNDEF', TokenLine}}.
{MINUS}                            : {token, {'MINUS', TokenLine}}.
{UNION}                            : {token, {'UNION', TokenLine}}.
{FILTER}                           : {token, {'FILTER', TokenLine}}.
{IN}                               : {token, {'IN', TokenLine}}.
{STR}                              : {token, {'STR', TokenLine}}.
{LANG}                             : {token, {'LANG', TokenLine}}.
{LANGMATCHES}                      : {token, {'LANGMATCHES', TokenLine}}.
{DATATYPE}                         : {token, {'DATATYPE', TokenLine}}.
{BOUND}                            : {token, {'BOUND', TokenLine}}.
{IRI}                              : {token, {'IRI', TokenLine}}.
{URI}                              : {token, {'URI', TokenLine}}.
{BNODE}                            : {token, {'BNODE', TokenLine}}.
{RAND}                             : {token, {'RAND', TokenLine}}.
{ABS}                              : {token, {'ABS', TokenLine}}.
{CEIL}                             : {token, {'CEIL', TokenLine}}.
{FLOOR}                            : {token, {'FLOOR', TokenLine}}.
{ROUND}                            : {token, {'ROUND', TokenLine}}.
{CONCAT}                           : {token, {'CONCAT', TokenLine}}.
{STRLEN}                           : {token, {'STRLEN', TokenLine}}.
{UCASE}                            : {token, {'UCASE', TokenLine}}.
{LCASE}                            : {token, {'LCASE', TokenLine}}.
{ENCODE_FOR_URI}                   : {token, {'ENCODE_FOR_URI', TokenLine}}.
{CONTAINS}                         : {token, {'CONTAINS', TokenLine}}.
{STRSTARTS}                        : {token, {'STRSTARTS', TokenLine}}.
{STRENDS}                          : {token, {'STRENDS', TokenLine}}.
{STRBEFORE}                        : {token, {'STRBEFORE', TokenLine}}.
{STRAFTER}                         : {token, {'STRAFTER', TokenLine}}.
{YEAR}                             : {token, {'YEAR', TokenLine}}.
{MONTH}                            : {token, {'MONTH', TokenLine}}.
{DAY}                              : {token, {'DAY', TokenLine}}.
{HOURS}                            : {token, {'HOURS', TokenLine}}.
{MINUTES}                          : {token, {'MINUTES', TokenLine}}.
{SECONDS}                          : {token, {'SECONDS', TokenLine}}.
{TIMEZONE}                         : {token, {'TIMEZONE', TokenLine}}.
{TZ}                               : {token, {'TZ', TokenLine}}.
{NOW}                              : {token, {'NOW', TokenLine}}.
{UUID}                             : {token, {'UUID', TokenLine}}.
{STRUUID}                          : {token, {'STRUUID', TokenLine}}.
{MD5}                              : {token, {'MD5', TokenLine}}.
{SHA1}                             : {token, {'SHA1', TokenLine}}.
{SHA256}                           : {token, {'SHA256', TokenLine}}.
{SHA384}                           : {token, {'SHA384', TokenLine}}.
{SHA512}                           : {token, {'SHA512', TokenLine}}.
{COALESCE}                         : {token, {'COALESCE', TokenLine}}.
{IF}                               : {token, {'IF', TokenLine}}.
{STRLANG}                          : {token, {'STRLANG', TokenLine}}.
{STRDT}                            : {token, {'STRDT', TokenLine}}.
{SameTerm}                         : {token, {'sameTerm', TokenLine}}.
{IsIRI}                            : {token, {'isIRI', TokenLine}}.
{IsURI}                            : {token, {'isURI', TokenLine}}.
{IsBLANK}                          : {token, {'isBLANK', TokenLine}}.
{IsLITERAL}                        : {token, {'isLITERAL', TokenLine}}.
{IsNUMERIC}                        : {token, {'isNUMERIC', TokenLine}}.
{REGEX}                            : {token, {'REGEX', TokenLine}}.
{SUBSTR}                           : {token, {'SUBSTR', TokenLine}}.
{REPLACE}                          : {token, {'REPLACE', TokenLine}}.
{EXISTS}                           : {token, {'EXISTS', TokenLine}}.
{NOT}                              : {token, {'NOT', TokenLine}}.
{COUNT}                            : {token, {'COUNT', TokenLine}}.
{SUM}                              : {token, {'SUM', TokenLine}}.
{MIN}                              : {token, {'MIN', TokenLine}}.
{MAX}                              : {token, {'MAX', TokenLine}}.
{AVG}                              : {token, {'AVG', TokenLine}}.
{SAMPLE}                           : {token, {'SAMPLE', TokenLine}}.
{GROUP_CONCAT}                     : {token, {'GROUP_CONCAT', TokenLine}}.
{SEPARATOR}                        : {token, {'SEPARATOR', TokenLine}}.


{VAR1}                             : {token, {var, TokenLine, variable(TokenChars)}}.
{VAR2}                             : {token, {var, TokenLine, variable(TokenChars)}}.
{LANGTAG}                          : {token, {langtag, TokenLine, langtag_str(TokenChars)}}.
{IRIREF}                           : {token, {iriref,  TokenLine, quoted_content_str(TokenChars)}}.
{DOUBLE}                           : {token, {double,  TokenLine, double(TokenChars)}}.
{DECIMAL}                          : {token, {decimal, TokenLine, decimal(TokenChars)}}.
{INTEGER}	                         : {token, {integer, TokenLine, integer(TokenChars)}}.
{DOUBLE_POSITIVE}                  : {token, {double_positive,  TokenLine, double(TokenChars)}}.
{DECIMAL_POSITIVE}                 : {token, {decimal_positive, TokenLine, decimal(TokenChars)}}.
{INTEGER_POSITIVE}	               : {token, {integer_positive, TokenLine, integer(TokenChars)}}.
{DOUBLE_NEGATIVE}                  : {token, {double_negative,  TokenLine, double(TokenChars)}}.
{DECIMAL_NEGATIVE}                 : {token, {decimal_negative, TokenLine, decimal(TokenChars)}}.
{INTEGER_NEGATIVE}	               : {token, {integer_negative, TokenLine, integer(TokenChars)}}.
{BOOLEAN}                          : {token, {boolean, TokenLine, boolean(TokenChars)}}.
{STRING_LITERAL_SINGLE_QUOTE}      : {token, {string_literal_quote, TokenLine, quoted_content_str(TokenChars)}}.
{STRING_LITERAL_QUOTE}             : {token, {string_literal_quote, TokenLine, quoted_content_str(TokenChars)}}.
{STRING_LITERAL_LONG_SINGLE_QUOTE} : {token, {string_literal_quote, TokenLine, long_quoted_content_str(TokenChars)}}.
{STRING_LITERAL_LONG_QUOTE}        : {token, {string_literal_quote, TokenLine, long_quoted_content_str(TokenChars)}}.
{BLANK_NODE_LABEL}                 : {token, {blank_node_label, TokenLine, bnode_str(TokenChars)}}.
{ANON}	                           : {token, {anon, TokenLine}}.
{NIL}	                             : {token, {nil, TokenLine}}.
a                                  : {token, {'a', TokenLine}}.
{PNAME_NS}                         : {token, {prefix_ns, TokenLine, prefix_ns(TokenChars)}}.
{PNAME_LN}                         : {token, {prefix_ln, TokenLine, prefix_ln(TokenChars)}}.
; 	                               : {token, {';', TokenLine}}.
, 	                               : {token, {',', TokenLine}}.
\.	                               : {token, {'.', TokenLine}}.
\[	                               : {token, {'[', TokenLine}}.
\]	                               : {token, {']', TokenLine}}.
\(	                               : {token, {'(', TokenLine}}.
\)	                               : {token, {')', TokenLine}}.
\^\^	                             : {token, {'^^', TokenLine}}.

\{	                               : {token, {'{', TokenLine}}.
\}	                               : {token, {'}', TokenLine}}.
\*	                               : {token, {'*', TokenLine}}.
\|	                               : {token, {'|', TokenLine}}.
\/	                               : {token, {'/', TokenLine}}.
\^	                               : {token, {'^', TokenLine}}.
\?	                               : {token, {'?', TokenLine}}.
\!	                               : {token, {'!', TokenLine}}.
= 	                               : {token, {'=', TokenLine}}.
\+	                               : {token, {'+', TokenLine}}.
\-	                               : {token, {'-', TokenLine}}.
\<	                               : {token, {'<', TokenLine}}.
\>	                               : {token, {'>', TokenLine}}.
\<=	                               : {token, {'<=', TokenLine}}.
\>=	                               : {token, {'>=', TokenLine}}.
\!=	                               : {token, {'!=', TokenLine}}.
\|\|	                             : {token, {'||', TokenLine}}.
\&\&	                             : {token, {'&&', TokenLine}}.


{WS}+                              : skip_token.
{COMMENT}                          : skip_token.


Erlang code.

integer(TokenChars)  -> 'Elixir.RDF.Serialization.ParseHelper':integer(TokenChars).
decimal(TokenChars)  -> 'Elixir.RDF.Serialization.ParseHelper':decimal(TokenChars).
double(TokenChars)   -> 'Elixir.RDF.Serialization.ParseHelper':double(TokenChars).
boolean(TokenChars)  -> 'Elixir.RDF.Serialization.ParseHelper':boolean(string:lowercase(TokenChars)).
quoted_content_str(TokenChars) -> 'Elixir.RDF.Serialization.ParseHelper':quoted_content_str(TokenChars).
long_quoted_content_str(TokenChars) -> 'Elixir.RDF.Serialization.ParseHelper':long_quoted_content_str(TokenChars).
bnode_str(TokenChars) -> 'Elixir.RDF.Serialization.ParseHelper':bnode_str(TokenChars).
langtag_str(TokenChars) -> 'Elixir.RDF.Serialization.ParseHelper':langtag_str(TokenChars).
prefix_ns(TokenChars) -> 'Elixir.RDF.Serialization.ParseHelper':prefix_ns(TokenChars).
prefix_ln(TokenChars) -> 'Elixir.RDF.Serialization.ParseHelper':prefix_ln(TokenChars).
variable(TokenChars)  -> 'Elixir.SPARQL.Language.ParseHelper':variable(TokenChars).

