-- body of generic stack package

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 Aug 2000

package body Stack is

   -------------------------------------------------------- 
   function Is_Empty(S : Stack_Type) return Boolean is
   begin
      return S.Top = 0;
   end Is_Empty;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure Push(S : in out Stack_Type; E : in Element) is
   begin
      if S.Top = Size then
         raise Stack_Overflow;
      else
         S.Top := S.Top + 1;
         S.Items(S.Top) := E;
      end if;
   end Push;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure Pop(S : in out Stack_Type; E : out Element) is
   begin
      if Is_Empty(S) then
         raise Stack_Underflow;
      else
         E := S.Items(S.Top);
         S.Top := S.Top - 1;
      end if;
   end Pop;
   --------------------------------------------------------
   
end Stack;
