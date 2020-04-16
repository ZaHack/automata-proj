public class MyList{
	
	private class list {
		
		public int data;
		
		public list next;
		
		
	}
		
	
	public void append( int data){
		list newNode = new list();
		
		newNode.data = data;
		list current = handle;
		
		while(current.next != null) current = current.next;
		current.next = newNode;
		
	};
	public list handle = null;
	public list getHead(){
		return handle;
	}

}