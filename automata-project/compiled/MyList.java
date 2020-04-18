public class MyList{
	
	private class list {
		
		public int data;
		
		public list next;
		
		
	}
		
	
	public void add( int data){
		list newNode = new list();
		
		newNode.data = data;
		list current = handle;
		if(current == null ){
			handle = newNode;
		} else {
			while(current.next != null) current = current.next;	
			
			current.next = newNode;
			
		}
	};
	public list handle = null;
	public list getHead(){
		return handle;
	}
	public void delete(int data){
		list current = handle;
		
		list previous = current;
		while(current.next != null && current.data != data){
			previous = current;
			current = current.next;
		}
		if(current.data == data){
			if(previous == current){
				handle = current.next;
			}else{
				previous.next = current.next;
			}
		}
	}

}