module linklang::ConcreteSyntax

lexical Identifier = [a-zA-Z][a-zA-Z0-9]* !>> [a-zA-Z0-9];
lexical Whitespace = [\t-\n\r\ ]; 
layout Layoutlist = Whitespace* !>> [\t-\n\r\ ];

//missing rulelist component TODO
start syntax Struct
	= struct: Nodelist; 

// all nodes in the parsed langauge
syntax Nodelist
	= Node+;

// each node type
syntax Node
	= "Node" Identifier NodeFeatures+ "end";

// the properties of the node
syntax NodeFeatures
	= connect: "*" Identifier "[]"? ConnectOperator Identifier
	| val: "^" Identifier "\<-" Type ; 

// connection types
syntax ConnectOperator
	= oneway: "-\>"
	| twoway: "\<\>"
	| back:   "\<-"
	;

//node data member types
syntax Type
	= "string"
	| "int"
	| "double"
	;

//TODO
syntax Rulelist =
	"Rule";