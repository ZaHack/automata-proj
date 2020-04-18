public class MyBSTree{
	
	public int data;
	
	public MyBSTree right;
	
	public MyBSTree left;
		
	
	public MyBSTree insert( MyBSTree root, int data){
		MyBSTree newNode = new MyBSTree();
		
		newNode.data = data;
		if(root==null) return newNode;
		MyBSTree current = root;
		while((current.left != null && current.data > data)||(current.right != null && current.data < data)){
			if(current.data > data){
				current = current.left;
			} else {
				current = current.right;
			}
		}
		if(current.data > data){
			
			current.left = newNode;
			
		} else if (current.data < data) {
			
			current.right = newNode;
			
		} else {
			
			current.data = data;
		}
		return root;
	};
	public MyBSTree delete( MyBSTree root, int data){
		if(root == null) return null;
		MyBSTree current = root;
		while((current.left != null && current.data > data)||(current.right != null && current.data < data)){
			if(current.data > data){
				if(current.left.data != data)
					current = current.left;
				else break;
			} else {
				if(current.right.data != data)
					current = current.right;
				else break;
			}
		}
		if(current.data == data){
			if(current.left == null){
				handle = current.right;
				
			} else if (current.right == null){
				handle = current.left;
				
			} else {
				MyBSTree minRight = current.right;
				MyBSTree prev = minRight;
				while(minRight.left != null){
					prev = minRight;
					minRight = minRight.left;
				}
				if (minRight.right != null){
					prev.left = minRight.right;
					
					
				}
				minRight.left = current.left;
				
				minRight.right = current.right;
				
				handle = minRight;
			}
		} else if(current.left != null && current.left.data == data){
			if(current.left.left == null && current.left.right == null){
				current.left = null;
			} else if(current.left.left == null){
				current.left = current.left.right;
				
				
			} else if(current.left.right == null){
				current.left = current.left.left;
				
			} else {
				MyBSTree minRight = current.left.right;
				MyBSTree prev = minRight;
				while(minRight.left != null){
					prev = minRight;
					minRight = minRight.left;
				}
				if (minRight.right != null){
					prev.left = minRight.right;
					
					
				}
				minRight.left = current.left.left;
				
				minRight.right = current.left.right;
				
				current.left = minRight;
			}
		} else if ( current.right != null && current.right.data == data) {
			if(current.right.left == null && current.right.right == null){
				current.right = null;
			} else if(current.right.left == null){
				current.right = current.right.right;
							
			} else if(current.right.right == null){
				current.right = current.right.left;
				
				
			} else {
				MyBSTree minRight = current.right.right;
				MyBSTree prev = minRight;
				while(minRight.left != null){
					prev = minRight;
					minRight = minRight.left;
				}
				if (minRight.right != null){
					prev.left = minRight.right;
					
					
				}
				minRight.left = current.right.left;
				
				minRight.right = current.right.right;
				
				current.right = minRight;
			}
		}
	};
}