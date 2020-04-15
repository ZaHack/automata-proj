module linklang::Compile

import List;
import linklang::AbstractSyntax;

// main compilation function
str compile(STRUCT s) {
	//verify the resulting struct is of the proper form
	if (struct(list[LNODE] lnodes, list[RULE] rules) := s) {
		return  "public class struct {
				'
				'	<for ( lnode(str name, list[LNODEFEATURE] features) <- lnodes) {>
				'	private class <name> {
				'		<for ( lvalue(str fname, LTYPE ltype) <- features) {>
				'		public <getLType(ltype)> <fname>; 
				'		<}>
				'		<for ( connect(str fname, LINKOPERATOR linkkind, str target) <- features) {>
				'		public <name> <fname>;
				'		<}>
				'	}
				'	<}>
				'
				'	<for (r <- rules) {>
				'	<getMethod( r, lnodes )>
				'	<}>
				'
				'}";
	}
	throw "Invalid Struct";
}

// convert ltype objects to the respective java type string
str getLType( string() ) = "string";
str getLType( lint() ) = "int";
str getLType( double() ) = "double";

// getMethod returns a method for the requested rule type
//an additional getMethod definition is required for each rule type
//ex. to define foobar rule type
//
//str getMethod( rule(str name, "foobar", list[str] parameters), list[LNODE] lnodes) { return ... }
//
//BEGIN rule definitions
//add: defines a adding method for a linked list like struct, good example of final method parameter generation, this creates a parameter for each data member of the target node 
str getMethod( rule(str name, "add", list[str] parameters), list[LNODE] lnodes) =  
"public void <name>( <intercalate(",",[ "<getLType(ltype)> <pname>"|lnode(str lname,list[LNODEFEATURE] feats) <- lnodes, lname == parameters[0], lvalue(str pname, LTYPE ltype) <- feats ])>){
' //TODO
'};";