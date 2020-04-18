public class MyList{
	
	public int data;
	
	public MyList next;
	public MyList nextb;	
	
	public static MyList add( MyList handle, int data){
		MyList newNode = new MyList();
		newNode.data = data;
		MyList current = handle;
		if(current == null ){
			handle = newNode;
		} else {
			while(current.next != null) current = current.next;	
			current.next = newNode;
			newNode.nextb = current;
			
		}
		return handle;
	};
	public static MyList pushFront( MyList handle, int data){
		MyList newNode = new MyList();
		newNode.data = data;
		newNode.next = handle;
		if(handle != null) handle.nextb = newNode;
		return newNode;
	};
	public static MyList delete( MyList handle, int data){
		if(handle == null) return null;
		MyList current = handle;
		
		while(current.next != null && current.data != data){
			current = current.next;
		}
		if(current.data == data){
			if( handle == current ){
				handle = current.next;
				if(current.next != null) current.next.nextb = null;
			}else{
				current.nextb.next = current.next;
				if(current.next != null) current.next.nextb = null;
			}
		}
		return handle;
	}
}