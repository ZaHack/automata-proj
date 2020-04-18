public class MyList{
	
	public int data;
	
	public MyList next;
		
	
	public static MyList add( MyList handle, int data){
		MyList newNode = new MyList();
		
		newNode.data = data;
		MyList current = handle;
		if(current == null ){
			handle = newNode;
		} else {
			while(current.next != null) current = current.next;	
			
			current.next = newNode;
			
		}
		return handle;
	};
	public static MyList pushFront( MyList handle, int data){
		MyList newNode = new MyList();
		
		newNode.data = data;
		
		newNode.next = handle;
		return newNode;
		
	};
	public static MyList delete( MyList handle, int data){
		if(handle == null) return null;
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
		return handle;
	}
   public static void main(String[] args){
      MyList list = new MyList();
      list = MyList.add(list, 1);
      list = MyList.pushFront(list, 10);
      list = MyList.delete(list,1);
      System.out.println(list.data);
   }
}