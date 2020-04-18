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
	
	//map[str,str] connect;
	
	//verify the resulting struct is of the proper form
	if (struct(str structName,list[FEATURE] feats, list[RULE] rules) := s) {
		return  "public class <structName>{
				'	<for ( lvalue(str fname, LTYPE ltype) <- feats) {>
				'	public <getLType(ltype)> <fname>;<}>
				'	<for ( connect(str fname, LINKOPERATOR linkop, str target) <- feats) {>
				'	public <target> <fname>;
				'	<if(linkop := twoway()){>public <target> <fname>b;<}><}>	
				'	<for (r <- rules) {>
				'	<getMethod( structName, r, feats )><}>
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
str getMethod( str lnodeName, rule(str name, "append", [str connectionName]), list[FEATURE] features){
	if( connect(connectionName, LINKOPERATOR linkop,_) <- features ){
		return 	"public static <lnodeName> <name>( <lnodeName> handle, <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- features ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_) <- features){>newNode.<pname> = <pname>;
				'	<}><lnodeName> current = handle;
				'	if(current == null ){
				'		handle = newNode;
				'	} else {
				'		while(current.<connectionName> != null) current = current.<connectionName>;	
				'		<if (linkop := oneway()) {>current.<connectionName> = newNode;
				'		<}><if (linkop := twoway()) {>current.<connectionName> = newNode;
				'		newNode.<connectionName>b = current;
				'		<}>
				'	}
				'	return handle;
				'};";
	};
	throw "Invalid Rule description append";
}

//prepend: similar as above, adds new list elements to the front of the list
str getMethod( str lnodeName, rule(str name, "prepend", [str connectionName]), list[FEATURE] feats){
	if( connect(connectionName, LINKOPERATOR linkop, lnodeName) <- feats ){
		return 	"public static <lnodeName> <name>( <lnodeName> handle, <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- feats ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_)<-feats){>newNode.<pname> = <pname>;<}>
				'	newNode.<connectionName> = handle;
				'	<if (linkop := twoway()) {>if(handle != null) handle.<connectionName>b = newNode;
				'	<}>return newNode;
				'};";
	};
	throw "Invalid Rule description prepend";
}

//addbin: add function for binary search tree like structures, twoway() is not supported for binary search trees
str getMethod( str lnodeName, rule(str name, "addbin", [str connectNameLeft, str connectNameRight, str lvalueName]), list[FEATURE] feats){
	if( connect( connectNameLeft,_,_) <- feats, 
		connect( connectNameRight,_,_) <- feats,
		lvalue( lvalueName,_) <- feats){
		return  "public static <lnodeName> <name>( <lnodeName> root, <intercalate(",",[ "<getLType(ltype)> <pname>"| lvalue(str pname, LTYPE ltype) <- feats ])>){
				'	<lnodeName> newNode = new <lnodeName>();
				'	<for (lvalue(str pname,_) <- feats) {>
				'	newNode.<pname> = <pname>;<}>
				'	if(root==null) return newNode;
				'	<lnodeName> current = root;
				'	while((current.<connectNameLeft> != null && current.<lvalueName> \> <lvalueName>)||(current.<connectNameRight> != null && current.<lvalueName> \< <lvalueName>)){
				'		if(current.<lvalueName> \> <lvalueName>)
				'			current = current.<connectNameLeft>;
				'		else
				'			current = current.<connectNameRight>;
				'	}
				'	if(current.<lvalueName> \> <lvalueName>){
				'		current.<connectNameLeft> = newNode;
				'	} else if (current.<lvalueName> \< <lvalueName>) {
				'		current.<connectNameRight> = newNode;
				'	} else {
				'		<for (lvalue(str pname,_) <- feats) {>
				'		current.<pname> = <pname>;<}>
				'	}
				'	return root;
				'};";
	};
	throw "Invalid Rule description addbin";
}

//remove: delete function for link list like structures
str getMethod( str lnodeName, rule(str name, "remove", [str connectionName, str lvalueName]), list[FEATURE] feats){
	if( connect(connectionName, LINKOPERATOR linkop, _) <- feats,
		lvalue(lvalueName, LTYPE ltype) <- feats ){
		return  "public static <lnodeName> <name>( <lnodeName> handle, <getLType(ltype)> <lvalueName>){
				'	if(handle == null) return null;
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
				'			if(current.<connectionName> != null) current.<connectionName>.<connectionName>b = null;
				'		}else{
				'			current.<connectionName>b.<connectionName> = current.<connectionName>;
				'			if(current.<connectionName> != null) current.<connectionName>.<connectionName>b = null;
				'		}
				'	}<}>
				'	return handle;
				'}";
	};
	throw "Invalid Rule description remove";
}

//removebin:
str getMethod( str lnodeName, rule(str name, "removebin", [str connectNameLeft, str connectNameRight, str lvalueName]), list[FEATURE] feats){
	if( connect(connectNameLeft, _,_) <- feats,
		connect(connectNameRight,_,_) <- feats,
		lvalue(lvalueName, LTYPE ltype) <- feats ){
		return  "public static <lnodeName> <name>( <lnodeName> root, <getLType(ltype)> <lvalueName>){
				'	if(root == null) return null;
				'	<lnodeName> current = root, previous = root;
				'	while(current.<lvalueName> != <lvalueName>){
				'		previous = current;
				'		if(current.<lvalueName> \> <lvalueName>)
				'			current = current.<connectNameLeft>;
				'		else
				'			current = current.<connectNameRight>;
				'	}
				'	if(current.<lvalueName> == <lvalueName>){
				'		if(current == previous){
				'			if(current.<connectNameLeft> == null){
				'				root = current.<connectNameRight>;
				'			} else if (current.<connectNameRight> == null){
				'				root = current.<connectNameLeft>;
				'			} else {
				'				<lnodeName> minRight = current.<connectNameRight>;
				'				<lnodeName> prev2 = minRight;
				'				while(minRight.<connectNameLeft> != null){
				'					prev2 = minRight;
				'					minRight = minRight.<connectNameLeft>;
				'				}
				'				if (minRight.<connectNameRight> != null){
				'					prev2.<connectNameLeft> = minRight.<connectNameRight>;
				'				}
				'				minRight.<connectNameLeft> = current.<connectNameLeft>;
				'				minRight.<connectNameRight> = current.<connectNameRight>;
				'				root = minRight;
				'			}
				'		} else if(previous.<connectNameLeft> == current){
				'			if(current.<connectNameLeft> == null){
				'				previous.<connectNameLeft> = current.<connectNameRight>;
				'			} else if (current.<connectNameRight> == null){
				'				previous.<connectNameLeft> = current.<connectNameLeft>;
				'			} else {
				'				<lnodeName> minRight = current.<connectNameRight>;
				'				<lnodeName> prev2 = minRight;
				'				while(minRight.<connectNameLeft> != null){
				'					prev2 = minRight;
				'					minRight = minRight.<connectNameLeft>;
				'				}
				'				if (minRight.<connectNameRight> != null){
				'					prev2.<connectNameLeft> = minRight.<connectNameRight>;
				'				}
				'				minRight.<connectNameLeft> = current.<connectNameLeft>;
				'				minRight.<connectNameRight> = current.<connectNameRight>;
				'				previous.<connectNameLeft> = minRight;
				'			}
				'		} else if(previous.<connectNameRight> == current){
				'			if(current.<connectNameLeft> == null){
				'				previous.<connectNameRight> = current.<connectNameRight>;
				'			} else if (current.<connectNameRight> == null){
				'				previous.<connectNameRight> = current.<connectNameLeft>;
				'			} else {
				'				<lnodeName> minRight = current.<connectNameRight>;
				'				<lnodeName> prev2 = minRight;
				'				while(minRight.<connectNameLeft> != null){
				'					prev2 = minRight;
				'					minRight = minRight.<connectNameLeft>;
				'				}
				'				if (minRight.<connectNameRight> != null){
				'					prev2.<connectNameLeft> = minRight.<connectNameRight>;
				'				}
				'				minRight.<connectNameLeft> = current.<connectNameLeft>;
				'				minRight.<connectNameRight> = current.<connectNameRight>;
				'				previous.<connectNameRight> = minRight;
				'			}
				'		}
				'	}
				'	return root;
				'};";
	};
	throw "Invalid Rule description remove";
}
