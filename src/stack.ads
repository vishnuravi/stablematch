-- generic stack package

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 Aug 2000

generic
type Element is private;  -- the type of the stack items
Size : Natural;           -- the maximum number of items
package Stack is

   type Stack_Type is private;

   function Is_Empty(S : Stack_Type) return Boolean;
   -- returns true if S is empty, false otherwise
   
   procedure Push(S : in out Stack_Type; E : in Element);
   -- pushes item E onto stack S
   
   procedure Pop(S : in out Stack_Type; E : out Element);
   -- pops item E from stack S
   
   Stack_Overflow, Stack_Underflow : exception;
   
private

   type Stack_Array_Type is array(1 .. Size) of Element;
   type Stack_Type is
      record
         Items : Stack_Array_Type;
         Top : Natural := 0;
      end record;
      
end Stack;
