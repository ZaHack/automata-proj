public class MyList{
	
	public int data;
	
	public MyList next;
		
	
	public MyList add( MyList handle, int data){
		MyList newNode = new MyList();
		
		newNode.data = data;
		MyList current = handle;
		if(current == null ){
			handle = newNode;
		} else {
			while(current.next != null) current = current.next;	
			
			current.next = newNode;
			
		}
	};
	public MyList delete( MyList handle, int data){
		MyList current = handle;
		
		MyList previous = current;
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