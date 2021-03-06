module linklang::AbstractSyntax

//alias, LinkLangId is a identifier of some str value
public alias LinkLangId = str;

//abstract data type for compile structure STRUCT
public data STRUCT = struct( LinkLangId name, list[FEATURE] features, list[RULE] rules);

// as above, notice each kind of feature has a seperate abstract type either connect of lvalue
public data FEATURE
	= connect(LinkLangId name, LINKOPERATOR linkkind, LinkLangId target)
	| lvalue(LinkLangId name, LTYPE ltype);

//link operator is a dummy type representing the previous operator
public data LINKOPERATOR
	= oneway()
	| twoway();

//ltype represents the type symbol in the language, as above each option is a dummy type representing that type in the java lang
public data LTYPE
	= string()
	| lint()
	| double();

//as above in node for rules
public data RULE = rule(LinkLangId name, LinkLangId rulekind, list[LinkLangId] parameters);

// debug and analysis utility
anno loc STRUCT@location;
anno loc FEATURE@location;
anno loc LINKOPERATOR@location;
anno loc LTYPE@location;
anno loc RULE@location;
