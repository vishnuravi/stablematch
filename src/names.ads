-- package to represent names of up to 20 characters

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 Aug 2000

package Names is

   Max_Name_Length : constant Integer := 20;
   type Name_Type is private;
   
   function Blank_Name return Name_Type;
   -- returns a blank name
   
   procedure Get_Name (
         Name     :    out Name_Type; 
         Overflow : in out Boolean;   
         Success  :    out Boolean    );
   -- reads a name from standard input; assumes a name is terminated
   -- by a blank or end of line; truncates the name and returns 
   -- Overflow true if name was too long; returns Success false
   -- if the end of the line was reached before a name was read
         
   procedure Put_Name(Name : in Name_Type);
   -- Writes Name to standard output
   
   function Name_To_String(Name : Name_Type) return String;
   -- returns Name as a String

   function Length(Name : Name_Type) return Natural;
   -- returns the length of Name
   
   function ">" (N1, N2 : Name_Type) return Boolean;
   -- lexicographic comparison


   
private

   subtype Fixed_String_Type is String(1..Max_Name_Length);
   type Name_Type is 
   record 
      Letters : Fixed_String_Type;  
      Len     : Natural           := 0;  
   end record;

end Names;
