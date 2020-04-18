module linklang::Compile

import List;
import IO;
import linklang::AbstractSyntax;
import linklang::Load;


// string to .java file
bool compileToFile(str s){
	return compileToFile(load(s));
}

// load result to .java file
bool compileToFile(STRUCT s){
	str res = compile(s);
	writeFile(|project://automata-project/compiled| + (s.name + ".java"), res);
	return true;
}

// compile from string, calls load
str compile(str s){ return compile(load(s));}

// compile from struct, main compilation function, takes load output
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
				'		<if (linkop := twoway(), name == target ) {>
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
//str getMethod( rule(str name, "foobar", list[str] [ptype1 parameter1, ..., ptypen parametern]), list[LNODE] lnodes ) { return ... }
//
//BEGIN rule definitions
//append: defines a adding method for a linked list like struct, good example of final method parameter generation, this creates a parameter for each data member of the target node 
str getMethod( rule(str name, "append", [str lnodeName, str connectionName]), list[LNODE] lnodes){
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
	throw "Invalid Rule description append";
}

//prepend: similar as above, adds new list elements to the front of the list
str getMethod( rule(str name, "prepend", [str lnodeName, str connectionName]), list[LNODE] lnodes){
	if( lnode(lnodeName, list[LNODEFEATURE] feats) <- lnodes, connect(connectionName, LINKOPERATOR linkop, lnodeName) <- feats ){
		return 	"public void <name>( <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- feats ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_) <- feats) {>
				'	newNode.<pname> = <pname>;<}>
				'	<if (linkop := oneway()) {>
				'	newNode.<connectionName> = handle;
				'	handle = newNode;<}>
				'	<if (linkop := twoway()) {>
				'	newNode.<connectionName> = handle;
				'	handle.<connectionName>b = newNode;
				'	handle = newNode;<}>
				'};";
	};
	throw "Invalid Rule description prepend";
}

//addbin: add function for binary search tree like structures
str getMethod( rule(str name, "addbin", [str lnodeName, str connectNameLeft, str connectNameRight, str lvalueName]), list[LNODE] lnodes){
	if( lnode(lnodeName, list[LNODEFEATURE] feats) <- lnodes,
		connect( connectNameLeft, LINKOPERATOR linkopl, lnodeName) <- feats, 
		connect( connectNameRight, LINKOPERATOR linkopr, lnodeName) <- feats,
		lvalue( lvalueName,_) <- feats){
		return  "public void <name>(<intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- feats ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_) <- feats) {>
				'	newNode.<pname> = <pname>;<}>
				'	<lnodeName> current = handle;
				'	while((current.<connectNameLeft> != null && current.<lvalueName> \> <lvalueName>)||(current.<connectNameRight> != null && current.<lvalueName> \< <lvalueName>)){
				'		if(current.<lvalueName> \> <lvalueName>){
				'			current = current.<connectNameLeft>;
				'		} else {
				'			current = current.<connectNameRight>;
				'		}
				'	}
				'	if(current.<lvalueName> \> <lvalueName>){
				'		<if (linkopl := oneway()){>
				'		current.<connectNameLeft> = newNode;<}>
				'		<if (linkopl := twoway()){>
				'		current.<connectNameLeft> = newNode;
				'		newNode.<connectNameLeft>b = current;<}>
				'	} else if (current.<lvalueName> \< <lvalueName>) {
				'		<if (linkopr := oneway()){>
				'		current.<connectNameRight> = newNode;<}>
				'		<if (linkopr := twoway()){>
				'		current.<connectNameRight> = newNode;
				'		newNode.<connectNameRight>b = current;<}>
				'	} else {
				'		<for (lvalue(str pname,_) <- feats) {>
				'		current.<pname> = <pname>;<}>
				'	}
				'};";
	};
	throw "Invalid Rule description addbin";
}

//remove: delete function for link list like structures
str getMethod( rule(str name, "remove", [str lnodeName, str connectionName, str lvalueName]), list[LNODE] lnodes){
	if( lnode(lnodeName, list[LNODEFEATURE] feats) <- lnodes, connect(connectionName, LINKOPERATOR linkop, lnodeName) <- feats, lvalue(lvalueName, LTYPE ltype) <- feats ){
		return  "public void <name>(<getLType(ltype)> <lvalueName>){
				'	<lnodeName> current = handle;
				'	<if (linkop := oneway()){>
				'	<lnodeName> previous = current;
				'	while(current.<connectionName> != null && current.<lvalueName> != <lvalueName>){
				'		previous = current;
				'		current = current.<connectionName>;
				'	}
				'	if(current.<lvalueName> == <lvalueName>){
				'		if(previous == current){
				'			handle = current.<connectionName>;
				'		}else{
				'			previous.<connectionName> = current.<connectionName>;
				'		}
				'	}<}><if (linkop := twoway()){>
				'	while(current.<connectionName> != null && current.<lvalueName> != <lvalueName>){
				'		current = current.<connectionName>;
				'	}
				'	if(current.<lvalueName> == <lvalueName>){
				'		if( handle == current ){
				'			handle = current.<connectionName>;
				'			current.<connectionName>.<connectionName>b = null;
				'		}else{
				'			current.<connectionName>b.<connectionName> = current.<connectionName>;
				'			current.<connectionName>.<connectionName>b = current.<connectionName>b;
				'		}
				'	}<}>
				'}";
	};
	throw "Invalid Rule description remove";
}

//head: indicates what node is the "root" of the structure,
//	ideally this would be implemented differently but time constraints mean this will work
str getMethod( rule(str name, "head", [str lnodeName ]), list[LNODE] lnodes ){
	return  "public <lnodeName> handle = null;
			'public <lnodeName> <name>(){
			'	return handle;
			'}";
}

