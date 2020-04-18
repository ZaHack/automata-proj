public class MyBSTree{
	
	private class branch {
		
		public int data;
		
		public branch right;
		
		public branch left;
		
		public branch leftb;
		
	}
		
	
	public branch handle = null;
	public branch root(){
		return handle;
	}
	public void insert(int data){
		branch newNode = new branch();
		
		newNode.data = data;
		branch current = handle;
		while((current.left != null && current.data > data)||(current.right != null && current.data < data)){
			if(current.data > data){
				current = current.left;
			} else {
				current = current.right;
			}
		}
		if(current.data > data){
			
			
			current.left = newNode;
			newNode.leftb = current;
		} else if (current.data < data) {
			
			current.right = newNode;
			
		} else {
			
			current.data = data;
		}
	};

}