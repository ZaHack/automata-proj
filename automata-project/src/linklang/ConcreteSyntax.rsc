module linklang::ConcreteSyntax

import Prelude;

lexical Identifier = [a-zA-Z][a-zA-Z0-9]* !>> [a-zA-Z0-9] \ "Rule" \ "Node";
lexical Whitespace = [\t-\n\r\ ]; 
layout Layoutlist = Whitespace* !>> [\t-\n\r\ ];

//overall structure definition, parse start position
start syntax Struct
	= struct: "Node" Identifier name Feature+ features "end" Rule+ rules; 

// the properties of the node
syntax Feature
	= connect: "*" Identifier name LinkOperator linkkind Identifier target
	| lvalue: "^" Identifier name "\<-" Type ltype ; 

// connection types
syntax LinkOperator
	= oneway: "-\>"
	| twoway: "\<\>";

//node data member types, int are called lint to avoid a name conflict with rascal
syntax Type
	= string: "string"
	| lint: "int"
	| double: "double";

//rule structure: name of rule, type of rule, parameters for rule
syntax Rule 
	= rule: "Rule" Identifier name Identifier rulekind "(" { Identifier "," }* parameters ")";

//parse functions below

public start[Struct] struct(str s) {
	return parse(#start[Struct], s);
}

public start[Struct] struct(str s, loc l) {
	return parse(#start[Struct], s, l);
}