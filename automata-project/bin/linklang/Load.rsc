module linklang::Load

import Prelude;
import linklang::ConcreteSyntax;
import linklang::AbstractSyntax;

public STRUCT load(str txt) = implode(#STRUCT, parse(#Struct, txt));