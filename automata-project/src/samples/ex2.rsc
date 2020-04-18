module samples::ex2

public str ex2 =
"Define MyBSTree
Node branch
 * right -\> branch
 * left \<\> branch
 ^ data \<- int
end
Rule root head( branch )
Rule insert addbin( branch, left, right, data )
Rule delete removebin( branch, left, right, data )";