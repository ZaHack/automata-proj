module linklang::Parse

import linklang::ConcreteSyntax;
import ParseTree;

public Struct parse(loc l) = parse(#Struct, l);
public Struct parse(str s) = parse(#Struct, s);