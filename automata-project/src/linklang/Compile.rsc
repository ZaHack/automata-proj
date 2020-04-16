module linklang::Compile

import List;
import IO;
import linklang::AbstractSyntax;


bool compileToFile(STRUCT s){
	str res = compile(s);
	writeFile(|project://automata-project/compiled| + (s.name + ".java"), res);
	return true;
}

// main compilation function
str compile(STRUCT s) {
	//verify the resulting struct is of the proper form
	if (struct(str structName,list[LNODE] lnodes, list[RULE] rules) := s) {
		return  "public class <structName>{
				'	<for ( lnode(str name, list[LNODEFEATURE] features) <- lnodes) {>
				'	private class <name> {
				'		<for ( lvalue(str fname, LTYPE ltype) <- features) {>
				'		public <getLType(ltype)> <fname>;<}>
				'		<for ( connect(str fname, LINKOPERATOR linkop, str target) <- features) {>
				'		public <target> <fname>;
				'		<if (linkop := twoway(), name == fname ) {>
				'		public <target> <fname>b;<}><}>
				'		<for (lnode(str tname, list[LNODEFEATURE] feats) <- lnodes, tname != name, connect(str fname, twoway(), name) <- feats ) {>
				'		public <tname> <fname>;<}>
				'	}
				'	<}>	
				'	<for (r <- rules) {>
				'	<getMethod( r, lnodes )><}>
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
str getMethod( rule(str name, "add", [str lnodeName, str connectionName]), list[LNODE] lnodes){
	if( lnode(lnodeName, list[LNODEFEATURE] feats ) <- lnodes, connect(connectionName, LINKOPERATOR linkop, lnodeName) <- feats ){
		
		return 	"public void <name>( <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- feats ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_) <- feats) {>
				'	newNode.<pname> = <pname>;<}>
				'	<lnodeName> current = handle;
				'	<if (linkop := oneway()) {>
				'	while(current.<connectionName> != null) current = current.<connectionName>;
				'	current.<connectionName> = newNode;<}>
				'	<if (linkop := twoway()) {>
				'	while(current.<connectionName>In != null) current = current.<connectionName>In;
				'	current.<connectionName> = newNode;
				'	newNode.<connectionName>b = current;<}>
				'};";
	};
	throw "Invalid Rule description";
}

//not a method persay, tells the resulting structure where to look for the beggining of the link structure
str getMethod( rule(str name, "head", [str lnodeName ]), list[LNODE] lnodes ){
	return  "public <lnodeName> handle = null;
			'public <lnodeName> <name>(){
			'	return handle;
			'}";
}



