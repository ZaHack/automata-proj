module samples::ex1

public str ex1 =
"Define MyList
Node list 
 * next -\> list
 ^ data \<- int
end
Rule add append( list, next )
Rule getHead head( list )
Rule delete remove( list, next, data)";