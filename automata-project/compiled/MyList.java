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
				current.next.nextb = null;
			}else{
				current.nextb.next = current.next;
				current.next.nextb = current.nextb;
			}
		}
		return handle;
	}
   
   public static void main(String[] args){
      MyList list = null;
      for(int i = 0; i < 10; i++){
         list = MyList.add(list,i);
      }
      for(MyList j = list; j != null; j = j.next){
         System.out.println(j.data);
      }
   }
}