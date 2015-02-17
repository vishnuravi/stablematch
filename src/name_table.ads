-- generic package to facilitate correspondence between names
-- and numbers. Names can be arbitrary strings of up to 20
-- characters. The corresponding numbers are 1..Size, where
-- Size is the package parameter. The names are ordered

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 Aug 2000

with Names; use Names;

generic
Size : Natural;
package Name_Table is
   
   procedure Add (Name : in Name_Type);
   -- adds Name to the table

   function Look_Up (Name : in Name_Type) return Natural;
   -- returns the integer associated with Name
     
   function Look_Up (X : Natural) return Name_Type;
   -- returns the name associated with integer X
   
   function Table_Size return Natural;
   -- returns the number of names in the table
   
   procedure Get_Max_Name_Length(L : out Natural);
   -- returns the length of the longest name in the table
     
   procedure Set_Required_Posn(I, J : in Natural);
   -- sets the required position of entry I to be J
   
   procedure Set_All_Required_Posns;
   -- sets all the required positions in the table
   
   function Get_True_Entry(I : Natural) return Natural;
   -- gets the true entry for position I
   
private

   type Details_Type is 
   record 
      Name  : Name_Type;  
      Index, Orig_Posn : Natural;  
   end record; 

   type Item_Type is array (Natural range 1..Size) of Details_Type; 
   type Rev_Type is array (Natural range 1..Size) of Natural; 
   type Table_Type is 
   record 
      Item      : Item_Type;  
      Rev, Orig : Rev_Type;  
      Num_Names : Natural   := 0;  
   end record; 
   Table : Table_Type;
   
end Name_Table;