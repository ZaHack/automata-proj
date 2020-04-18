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
	if (struct(str structName,list[LNODEFEATURE] feats, list[RULE] rules) := s) {
		return  "public class <structName>{
				'	<for ( lvalue(str fname, LTYPE ltype) <- feats) {>
				'	public <getLType(ltype)> <fname>;<}>
				'	<for ( connect(str fname, LINKOPERATOR linkop, str target) <- feats) {>
				'	public <target> <fname>;
				'	<if(linkop := twoway()){>public <target> <fname>b;<}><}>	
				'	<for (r <- rules) {>
				'	<getMethod( r, feats )><}>
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
str getMethod( rule(str name, "append", [str connectionName]), list[LNODEFEATURE] features){
	if( connect(connectionName, LINKOPERATOR linkop, lnodeName) <- features ){
		return 	"public <lnodeName> <name>( <lnodeName> handle, <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- features ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_) <- features) {>
				'	newNode.<pname> = <pname>;<}>
				'	<lnodeName> current = handle;
				'	if(current == null ){
				'		handle = newNode;
				'	} else {
				'		while(current.<connectionName> != null) current = current.<connectionName>;	
				'		<if (linkop := oneway()) {>
				'		current.<connectionName> = newNode;<}>
				'		<if (linkop := twoway()) {>
				'		current.<connectionName> = newNode;
				'		newNode.<connectionName>b = current;<}>
				'	}
				'};";
	};
	throw "Invalid Rule description append";
}

//prepend: similar as above, adds new list elements to the front of the list
str getMethod( rule(str name, "prepend", [str lnodeName, str connectionName]), list[LNODEFEATURE] feats){
	if( connect(connectionName, LINKOPERATOR linkop, lnodeName) <- feats ){
		return 	"public <lnodeName> <name>( <lnodeName> handle, <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- feats ])>){
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
str getMethod( rule(str name, "addbin", [str lnodeName, str connectNameLeft, str connectNameRight, str lvalueName]), list[LNODEFEATURE] feats){
	if( connect( connectNameLeft, LINKOPERATOR linkopl, lnodeName) <- feats, 
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
str getMethod( rule(str name, "remove", [str lnodeName, str connectionName, str lvalueName]), list[LNODEFEATURE] feats){
	if( connect(connectionName, LINKOPERATOR linkop, lnodeName) <- feats,
		lvalue(lvalueName, LTYPE ltype) <- feats ){
		return  "public <lnodeName> <name>( <lnodeName> handle, <getLType(ltype)> <lvalueName>){
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

//removebin:
str getMethod( rule(str name, "removebin", [str lnodeName, str connectNameLeft, str connectNameRight, str lvalueName]), list[LNODEFEATURE] feats){
	if( connect(connectNameLeft, LINKOPERATOR linkopl, lnodeName) <- feats,
		connect(connectNameRight,LINKOPERATOR linkopr, lnodeName) <- feats,
		lvalue(lvalueName, LTYPE ltype) <- feats ){
		return  "public void <name>(<getLType(ltype)> <lvalueName>){
				'	<lnodeName> current = handle;
				'	if(handle == null) return;
				'	while((current.<connectNameLeft> != null && current.<lvalueName> \> <lvalueName>)||(current.<connectNameRight> != null && current.<lvalueName> \< <lvalueName>)){
				'		if(current.<lvalueName> \> <lvalueName>){
				'			if(current.<connectNameLeft>.<lvalueName> != <lvalueName>)
				'				current = current.<connectNameLeft>;
				'			else break;
				'		} else {
				'			if(current.<connectNameRight>.<lvalueName> != <lvalueName>)
				'				current = current.<connectNameRight>;
				'			else break;
				'		}
				'	}
				'	if(current.<lvalueName> == <lvalueName>){
				'		if(current.<connectNameLeft> == null){
				'			handle = current.<connectNameRight>;
				'			<if(linkopr := twoway()){>handle.<connectNameRight>b = null;<}>
				'		} else if (current.<connectNameRight> == null){
				'			handle = current.<connectNameLeft>;
				'			<if(linkopl := twoway()){>handle.<connectNameLeft>b = null;<}>
				'		} else {
				'			<lnodeName> minRight = current.<connectNameRight>;
				'			<lnodeName> prev = minRight;
				'			while(minRight.<connectNameLeft> != null){
				'				prev = minRight;
				'				minRight = minRight.<connectNameLeft>;
				'			}
				'			if (minRight.<connectNameRight> != null){
				'				prev.<connectNameLeft> = minRight.<connectNameRight>;
				'				<if(linkopr := twoway()){>minRight.<connectNameRight>.<connectNameRight>b = null;<}>
				'				<if(linkopl := twoway()){>minRight.<connectNameLeft>b = null;
				'				prev.<connectNameLeft>.<connectNameLeft>b = prev;<}>
				'			}
				'			minRight.<connectNameLeft> = current.<connectNameLeft>;
				'			<if(linkopl := twoway()){>minRight.<connectNameLeft>.<connectNameLeft>b = minRight;<}>
				'			minRight.<connectNameRight> = current.<connectNameRight>;
				'			<if(linkopr := twoway()){>minRight.<connectNameRight>.<connectNameRight>b = minRight;<}>
				'			handle = minRight;
				'		}
				'	} else if(current.<connectNameLeft> != null && current.<connectNameLeft>.<lvalueName> == <lvalueName>){
				'		if(current.<connectNameLeft>.<connectNameLeft> == null && current.<connectNameLeft>.<connectNameRight> == null){
				'			current.<connectNameLeft> == null;
				'		} else if(current.<connectNameLeft>.<connectNameLeft> == null){
				'			current.<connectNameLeft> = current.<connectNameLeft>.<connectNameRight>;
				'			<if(linkopr := twoway()){>current.<connectNameLeft>.<connectNameRight>b = null;<}>
				'			<if(linkopl := twoway()){>current.<connectNameLeft>.<connectNameLeft>b = current;<}>
				'		} else if(current.<connectNameLeft>.<connectNameRight> == null){
				'			current.<connectNameLeft> = current.<connectNameLeft>.<connectNameLeft>;
				'			<if(linkopl := twoway()){>current.<connectNameLeft>.<connectNameLeft>b = current;<}>
				'		} else {
				'			<lnodeName> minRight = current.<connectNameLeft>.<connectNameRight>;
				'			<lnodeName> prev = minRight;
				'			while(minRight.<connectNameLeft> != null){
				'				prev = minRight;
				'				minRight = minRight.<connectNameLeft>;
				'			}
				'			if (minRight.<connectNameRight> != null){
				'				prev.<connectNameLeft> = minRight.<connectNameRight>;
				'				<if(linkopr := twoway()){>minRight.<connectNameRight>.<connectNameRight>b = null;<}>
				'				<if(linkopl := twoway()){>minRight.<connectNameLeft>b = null;
				'				prev.<connectNameLeft>.<connectNameLeft>b = prev;<}>
				'			}
				'			minRight.<connectNameLeft> = current.<connectNameLeft>.<connectNameLeft>;
				'			<if(linkopl := twoway()){>minRight.<connectNameLeft>.<connectNameLeft>b = minRight;
				'			minRight.<connectNameLeft>b = current;<}>
				'			minRight.<connectNameRight> = current.<connectNameLeft>.<connectNameRight>;
				'			<if(linkopr := twoway()){>minRight.<connectNameRight>.<connectNameRight>b = minRight;<}>
				'			current.<connectNameLeft> = minRight;
				'		}
				'	} else if ( current.<connectNameRight> != null && current.<connectNameRight>.<lvalueName> == <lvalueName>) {
				'		if(current.<connectNameRight>.<connectNameLeft> == null && current.<connectNameRight>.<connectNameRight> == null){
				'			current.<connectNameRight> == null;
				'		} else if(current.<connectNameRight>.<connectNameLeft> == null){
				'			current.<connectNameRight> = current.<connectNameRight>.<connectNameRight>;
				'			<if(linkopr := twoway()){>current.<connectNameRight>.<connectNameRight>b = current;<}>			
				'		} else if(current.<connectNameRight>.<connectNameRight> == null){
				'			current.<connectNameRight> = current.<connectNameRight>.<connectNameLeft>;
				'			<if(linkopl := twoway()){>current.<connectNameRight>.<connectNameLeft>b = null;<}>
				'			<if(linkopr := twoway()){>current.<connectNameRight>.<connectNameRight>b = current;<}>
				'		} else {
				'			<lnodeName> minRight = current.<connectNameRight>.<connectNameRight>;
				'			<lnodeName> prev = minRight;
				'			while(minRight.<connectNameLeft> != null){
				'				prev = minRight;
				'				minRight = minRight.<connectNameLeft>;
				'			}
				'			if (minRight.<connectNameRight> != null){
				'				prev.<connectNameLeft> = minRight.<connectNameRight>;
				'				<if(linkopr := twoway()){>minRight.<connectNameRight>.<connectNameRight>b = null;<}>
				'				<if(linkopl := twoway()){>minRight.<connectNameLeft>b = null;
				'				prev.<connectNameLeft>.<connectNameLeft>b = prev;<}>
				'			}
				'			minRight.<connectNameLeft> = current.<connectNameRight>.<connectNameLeft>;
				'			<if(linkopl := twoway()){>minRight.<connectNameLeft>.<connectNameLeft>b = minRight;<}>
				'			minRight.<connectNameRight> = current.<connectNameRight>.<connectNameRight>;
				'			<if(linkopr := twoway()){>minRight.<connectNameRight>.<connectNameRight>b = minRight;
				'			minRight.<connectNameRight>b = current;<}>
				'			current.<connectNameRight> = minRight;
				'		}
				'	}
				'};";
	};
	throw "Invalid Rule description remove";
}



//head: indicates what node is the "root" of the structure,
//	ideally this would be implemented differently but time constraints mean this will work
str getMethod( rule(str name, "head", [str lnodeName ]), list[LNODEFEATURE] feats ){
	return  "public <lnodeName> handle = null;
			'public <lnodeName> <name>(){
			'	return handle;
			'}";
}

