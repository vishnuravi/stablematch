-- body of generic package to facilitate
-- correspondence between names and numbers. 

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 Aug 2000

package body Name_Table is
   
   --------------------------------------------------------
   procedure Add (Name : in Name_Type) is
      I : Natural;  
   begin
      I := Table.Num_Names;
      while I > 0 and then Table.Item(I).Name > Name loop
         Table.Item(I+1) := Table.Item(I);
         Table.Rev(Table.Item(I+1).Index) := I+1;
         I := I-1;
      end loop;
      Table.Num_Names := Table.Num_Names+1;
      Table.Item(I+1).Name := Name;
      Table.Item(I+1).Index := Table.Num_Names;
      Table.Rev(Table.Num_Names) := I+1;
   end Add;
   --------------------------------------------------------
   
   --------------------------------------------------------
   function Look_Up (Name : in Name_Type) return Natural is 
      Low,  
      Mid,  
      High : Natural;  
   begin
      Low := 1;
      High := Table.Num_Names;
      while Low <= High loop
         Mid := (Low + High) / 2;
         if Name = Table.Item(Mid).Name then
            return Table.Item(Mid).Index;
         elsif Table.Item(Mid).Name > Name then
            High := Mid - 1;
         else
            Low := Mid + 1;
         end if;
      end loop;
      return 0;
   end Look_Up;
   --------------------------------------------------------

   --------------------------------------------------------     
   function Look_Up (X : Natural) return Name_Type  is 
   begin
      return Table.Item(Table.Rev(X)).Name;
   end Look_Up;
   --------------------------------------------------------

   --------------------------------------------------------
   function Table_Size return Natural is
   begin
      return Table.Num_Names;
   end Table_Size;
   
   procedure Get_Max_Name_Length(L : out Natural) is
      Next : Natural;
   begin
      L := 0;
      for I in 1..Size loop
         Next := Length(Look_Up(I));
         if Next > L then
            L := Next;
         end if;
      end loop;
   end Get_Max_Name_Length;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Set_Required_Posn(I, J : in Natural) is
   begin
      Table.Item(Table.Rev(I)).Orig_Posn := J;
   end Set_Required_Posn;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Set_All_Required_Posns is
   begin
      for I in 1..Size loop
         Table.Orig(Table.Item(I).Orig_Posn) := I;
      end loop;
   end Set_All_Required_Posns;
   --------------------------------------------------------

   --------------------------------------------------------
   function Get_True_Entry(I : Natural) return Natural is
   begin
      return Table.Item(Table.Orig(I)).Index;
   end Get_True_Entry;
   --------------------------------------------------------

end Name_Table;
