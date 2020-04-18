module samples::ex2

public str ex2 =
"Node MyBSTree
 * right -\> MyBSTree
 * left -\> MyBSTree
 ^ data \<- int
end
Rule insert addbin( left, right, data )
Rule delete removebin( left, right, data )";