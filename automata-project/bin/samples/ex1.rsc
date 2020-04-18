module samples::ex1

public str ex1 =
"Node MyList 
 * next \<\> MyList
 ^ data \<- int
end
Rule add append( next )
Rule pushFront prepend( next )
Rule delete remove( next, data)";