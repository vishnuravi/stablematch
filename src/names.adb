-- body of package to represent names of up to 20 characters

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 Aug 2000

with Ada.Text_IO; use Ada.Text_IO;

package body Names is

   ---------------------------------------------------------
   function Blank_Name return Name_Type is
   begin
      return ("--------------------",1);
   end Blank_Name;
   ---------------------------------------------------------

   ---------------------------------------------------------
   procedure Get_Name (
         Name     :    out Name_Type; 
         Overflow : in out Boolean;   
         Success  :    out Boolean    ) is
      Blank : constant Character := ' ';  
      Ch    :          Character := Blank;  
      More  :          Boolean   := True;  
   begin
      Name.Letters := (others => Blank);
      Name.Len := 0;
      Success := True;
      while (not End_Of_Line) and (Ch = Blank) loop
         Get(Ch);
      end loop;
      if Ch = Blank then
         Success := False;
         return;
      end if;
      while More loop
         if Name.Len < Max_Name_Length then
            Name.Len := Name.Len + 1;
            Name.Letters(Name.Len) := Ch;
         else
            Overflow := True;
         end if;
         if End_Of_Line then
            More := False;
         else
            Get(Ch);
            More := Ch /= Blank;
         end if;
      end loop;
   end Get_Name;
   ---------------------------------------------------------

   ---------------------------------------------------------
   procedure Put_Name(Name : in Name_Type) is
   begin
      Put(Name.Letters(1..Name.Len));
   end Put_Name;
   ---------------------------------------------------------

   ---------------------------------------------------------
   function Name_to_String(Name : in Name_Type) return String is
   begin
      return Name.Letters(1..Name.Len);
   end Name_to_String;

   ---------------------------------------------------------   
   function Length(Name : Name_Type) return Natural is
   begin
      return Name.Len;
   end Length;
   ---------------------------------------------------------

   ---------------------------------------------------------   
   function ">" (N1, N2 : Name_Type) return Boolean is
   begin
      return N1.Letters > N2.Letters;
   end ">";
   ---------------------------------------------------------

end Names;