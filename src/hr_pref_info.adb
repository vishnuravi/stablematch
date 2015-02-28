-- Body of generic package to represent preference information
-- for an instance of the hospitals / residents problem

-- Author: Rob Irving, University of Glasgow
-- Modified by Vishnu Ravi, February 2015

with Ada.Text_Io; use Ada.Text_Io;
with Ada.Integer_Text_Io; use Ada.Integer_Text_Io;
with Names; use Names;
with Name_Table;
with Stack;
   
package body HR_Pref_Info is

   package Res_Table is new Name_Table(Num_Residents);

   package Hos_Table is new Name_Table(Num_Hospitals);
   
   type Annotation_Type is (Resident, Hospital, None);

   Page_Width : constant Integer := 80;
   Blank : constant Character := ' ';
   Star : constant Character := '*';
   Colon : constant Character := ':';
   Comma : constant Character := ',';
   Left_Par : constant Character := '(';
   Right_Par : constant Character := ')';
   
   --------------------------------------------------------
   function Res_First_Choice (
         P : in     Pref_Info_Type; 
         I :        Resident_Index    ) 
      return Hospital_Index is 
   -- returns first hospital in I's current preference list
      Pos : Hos_Rank_Index;  
   begin
      if I = 0 then
         return 0;
      else
         Pos := P.Res(I).Pref_List(0).Successor;
         return P.Res(I).Pref_List(Pos).Hospital;
      end if;
   end Res_First_Choice;
   --------------------------------------------------------
   
   --------------------------------------------------------
   function Res_Last_Choice (
         P : in     Pref_Info_Type; 
         I :        Resident_Index    ) 
      return Hospital_Index is 
   -- returns last hospital in I's current preference list
      Pos : Hos_Rank_Index;  
   begin
      if I = 0 then
         return 0;
      else
         Pos := P.Res(I).Pref_List(0).Predecessor;
         return P.Res(I).Pref_List(Pos).Hospital;
      end if;
   end Res_Last_Choice;
   --------------------------------------------------------

   --------------------------------------------------------   
   function Hos_First_Choice (
         P : in     Pref_Info_Type; 
         I :        Hospital_Index    ) 
      return Resident_Index is 
   -- returns first resident in I's current preference list
      Pos : Res_Rank_Index;  
   begin
      if I = 0 then
         return 0;
      else
         Pos := P.Hos(I).Pref_List(0).Successor;
         return P.Hos(I).Pref_List(Pos).Resident;
      end if;
   end Hos_First_Choice;
   --------------------------------------------------------

   --------------------------------------------------------   
   function Hos_Last_Choice (
         P : in     Pref_Info_Type; 
         I :        Hospital_Index    ) 
      return Resident_Index is 
   -- returns last resident in I's current preference list
      Pos : Res_Rank_Index;  
   begin
      if I = 0 then
         return 0;
      else
         Pos := P.Hos(I).Pref_List(0).Predecessor;
         return P.Hos(I).Pref_List(Pos).Resident;
      end if;
   end Hos_Last_Choice;
   --------------------------------------------------------

   --------------------------------------------------------
   function Successor_Hospital (
         P :        Pref_Info_Type; 
         I :        Resident_Index;                        
         J :        Hospital_Index    ) 
      return Hospital_Index is 
   -- returns the successor of hospital J in resident 
   -- I's current preference list
      Location : Hos_Rank_Index;  
   begin
      if I = 0 or J = 0 then
         return 0;
      else
         Location := P.Res(I).Rank(J);
         Location := P.Res(I).Pref_List(Location).Successor;
         return P.Res(I).Pref_List(Location).Hospital;
      end if;
   end Successor_Hospital;
   --------------------------------------------------------

   --------------------------------------------------------   
   function Successor_Resident (
         P :        Pref_Info_Type; 
         I :        Hospital_Index;                        
         J :        Resident_Index    ) 
      return Resident_Index is 
   -- returns the successor of resident J in hospital
   -- I's current preference list
      Location : Res_Rank_Index;  
   begin
      if I = 0 or J = 0 then
         return 0;
      else
         Location := P.Hos(I).Rank(J);
         Location := P.Hos(I).Pref_List(Location).Successor;
         return P.Hos(I).Pref_List(Location).Resident;
      end if;
   end Successor_Resident;
   --------------------------------------------------------

   --------------------------------------------------------   
   function Predecessor_Resident (
         P :        Pref_Info_Type; 
         I :        Hospital_Index;                        
         J :        Resident_Index    ) 
      return Resident_Index is 
   -- returns the predecessor of resident J in hospital
   -- I's current preference list
      Location : Res_Rank_Index;  
   begin
      if I = 0 or J = 0 then
         return 0;
      else
         Location := P.Hos(I).Rank(J);
         Location := P.Hos(I).Pref_List(Location).Predecessor;
         return P.Hos(I).Pref_List(Location).Resident;
      end if;
   end Predecessor_Resident;
   --------------------------------------------------------

   --------------------------------------------------------   
   function Hos_Next_Choice (
         P : in     Pref_Info_Type; 
         I :        Hospital_Index    ) 
      return Resident_Index is 
   -- returns the first resident in hospital I's current
   -- preference list who is not currently assigned to I,
   -- or 0 if there is no such resident
   begin
      if I = 0 then
         return 0;
      else
         return Successor_Resident(P, I, P.Hos(I).Last_Assignee);
      end if;
   end Hos_Next_Choice;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Assign(P : in out Pref_Info_Type;
         R : in Resident_Index;
         H : in Hospital_Index) is
   -- assigns resident R to hospital H
      Temp : Resident_Index;
   begin
      P.Res(R).Assigned := True;  
      P.Hos(H).Posts_Filled := P.Hos(H).Posts_Filled + 1;
      Temp := P.Hos(H).Last_Assignee;
      if Temp = 0 or else 
              P.Hos(H).Rank(Temp) < P.Hos(H).Rank(R) then
         P.Hos(H).Last_Assignee := R;
      end if;
   end Assign;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure R_Unassign(P : in out Pref_Info_Type;
         R : in Resident_Index;
         H : in Hospital_Index) is
   -- unassigns resident R from hospital H during
   -- the Resident Oriented algorithm
      Next : Resident_Index;
   begin
      P.Res(R).Assigned := False;  
      P.Hos(H).Posts_Filled := P.Hos(H).Posts_Filled - 1;
      if P.Hos(H).Last_Assignee = R then
         Next := Predecessor_Resident(P, H, R);
         while Next /= 0 and then (not P.Res(Next).Assigned
               or else Res_First_Choice(P, Next) /= H) loop
            Next := Predecessor_Resident(P, H, Next);
         end loop;
         P.Hos(H).Last_Assignee := Next;
      end if;
   end R_Unassign;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure H_Unassign(P : in out Pref_Info_Type;
         R : in Resident_Index;
         H : in Hospital_Index) is
   -- unassigns resident R from hospital H during
   -- the Hospital Oriented algorithm
   begin
      P.Res(R).Assigned := False;  
      P.Hos(H).Posts_Filled := P.Hos(H).Posts_Filled - 1;
      if P.Hos(H).Last_Assignee = R then
         P.Hos(H).Last_Assignee := Predecessor_Resident(P, H, R);
      end if;
   end H_Unassign;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Remove (
         P : in out Pref_Info_Type; 
         I : in     Resident_Index;                        
         J : in     Hospital_Index    ) is
   -- removes the pair (I,J) from the preference structure 
      H_Location,  
      H_Previous,  
      H_Next     : Hos_Rank_Index; 
      R_Location,  
      R_Previous,  
      R_Next     : Res_Rank_Index; 
   begin
      if I /= 0 and J /= 0 then
         H_Location := P.Res(I).Rank(J);
         if H_Location /= Num_Hospitals+1 then
            H_Next := P.Res(I).Pref_List(H_Location).Successor;
            H_Previous := P.Res(I).Pref_List(H_Location).Predecessor;
            P.Res(I).Pref_List(H_Next).Predecessor := H_Previous;
            P.Res(I).Pref_List(H_Previous).Successor := H_Next;
            P.Res(I).List_Length := P.Res(I).List_Length - 1;
         end if;
         R_Location := P.Hos(J).Rank(I);
         if R_Location /= Num_Residents+1 then
            R_Next := P.Hos(J).Pref_List(R_Location).Successor;
            R_Previous := P.Hos(J).Pref_List(R_Location).Predecessor;
            P.Hos(J).Pref_List(R_Next).Predecessor := R_Previous;
            P.Hos(J).Pref_List(R_Previous).Successor := R_Next;
            P.Hos(J).List_Length := P.Hos(J).List_Length - 1;
         end if;
      end if;
   end Remove;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Calculate_Res_Ranks (
         P : in out Pref_Info_Type ) is 
   -- calculates resident ranking arrays from preference lists
      H : Hospital_Index;
   begin
      for I in 1..Num_Residents loop
         for J in 1..Num_Hospitals loop
            H := P.Res(I).Pref_List(J).Hospital;
            if H /= 0 then
               P.Res(I).Rank(H) := J;
            end if;
         end loop;
      end loop;
   end Calculate_Res_Ranks;
   --------------------------------------------------------

   --------------------------------------------------------  
   procedure Calculate_Hos_Ranks (
         P : in out Pref_Info_Type ) is 
   -- calculates  hospital ranking arrays from preference lists
      R : Resident_Index;
   begin
      for I in 1..Num_Hospitals loop
         for J in 1..Num_Residents loop
            R := P.Hos(I).Pref_List(J).Resident;
            if R /= 0 then
               P.Hos(I).Rank(R) := J;
            end if;
         end loop;
      end loop;
   end Calculate_Hos_Ranks;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Make_Lists_Consistent (
         P : in out Pref_Info_Type ) is 
   -- removes I from J's list whenever J is absent from I's
      J, K : Hospital_Index; 
      L, M : Resident_Index; 
   begin
      for I in 1..Num_Residents loop
         J := Res_First_Choice(P, I);
         while J /= 0 loop
            if P.Hos(J).Rank(I) = Num_Residents+1 then
               K := Successor_Hospital(P, I, J);
               Remove(P, I, J);
               J := K;
            else
               J := Successor_Hospital(P, I, J);
            end if;
         end loop;
      end loop;
      for I in 1..Num_Hospitals loop
         L := Hos_First_Choice(P, I);
         while L /= 0 loop
            if P.Res(L).Rank(I) = Num_Hospitals+1 then
               M := Successor_Resident(P, I, L);
               Remove(P, L, I);
               L := M;
            else
               L := Successor_Resident(P, I, L);
            end if;
         end loop;
      end loop;
   end Make_Lists_Consistent;  
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Map_Res_Name (
         N : in     Name_Type;   
         I :    out Resident_Index ) is 
   -- returns in I number of resident whose identifier is N
   -- inserting this pair in the table if not already present
   begin
      I := Res_Table.Look_Up(N);
      if I = 0 then
         if Res_Table.Table_Size < Num_Residents then
            Res_Table.Add(N);
            I := Res_Table.Table_Size;
         else
            raise Table_Overflow;
         end if;
      end if;
   end Map_Res_Name;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Map_Hos_Name (
         N : in     Name_Type;   
         I :    out Hospital_Index ) is 
   -- returns in I number of hospital whose identifier is N
   -- inserting this pair in the table if not already present
   begin
      I := Hos_Table.Look_Up(N);
      if I = 0 then
         if Hos_Table.Table_Size < Num_Hospitals then
            Hos_Table.Add(N);
            I := Hos_Table.Table_Size;
         else
            raise Table_Overflow;
         end if;
      end if;
   end Map_Hos_Name;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure Get_Colon is
   -- discards characters up to the next colon
     Ch : Character;
   begin
     loop
       Get(Ch);
       exit when Ch = Colon;
     end loop;
   end Get_Colon;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure Get_Pref_Info(P : out Pref_Info_Type) is
      Res_Name, Hos_Name  : Name_Type; 
      R_Next      : Resident_Index; 
      H_Next      : Hospital_Index; 
      R_Temp, R_Count     : Resident_Index := 0;
      H_Temp, H_Count     : Hospital_Index := 0;
      Success : Boolean;  
      Ov      : Boolean      := False; 
      Num_Posts : Natural;
   begin
      for I in 1 .. Num_Residents loop
         if End_Of_Line then
            Skip_Line;
         else
            Get_Name(Res_Name, Ov, Success);
            Get_Colon;
            Map_Res_Name(Res_Name, R_Next);
            R_Count := R_Count + 1;
            Res_Table.Set_Required_Posn(R_Next, R_Count);
            P.Res(R_Next).Pref_List(0).Predecessor := 0;
            for Pos in 1..Num_Hospitals+1 loop
               if not End_Of_Line then
                  Get_Name(Hos_Name, Ov, Success);
                  if Success then
                     Map_Hos_Name(Hos_Name, H_Temp);
                     P.Res(R_Next).Pref_List(Pos).Hospital := H_Temp;
                     P.Res(R_Next).Pref_List(Pos-1).Successor 
                                        := Pos mod (Num_Hospitals+1);
                     P.Res(R_Next).Pref_List(Pos).Predecessor := Pos - 1;
                     P.Res(R_Next).List_Length := P.Res(R_Next).List_Length + 1;
                  end if;
               else
                  P.Res(R_Next).Pref_List(Pos-1).Successor := 0;
                  if P.Res(R_Next).Pref_List(0).Predecessor = 0 then
                     P.Res(R_Next).Pref_List(0).Predecessor := Pos - 1;
                  end if;
                  exit;
               end if;
            end loop;
            Skip_Line;
         end if;
      end loop;
      for I in 1 .. Num_Hospitals loop
         if End_Of_Line then
            Skip_Line;
         else
            Get_Name(Hos_Name, Ov, Success);
            Get_Colon;
            Get(Num_Posts);
            Get_Colon;
            Map_Hos_Name(Hos_Name, H_Next);
            H_Count := H_Count + 1;
            Hos_Table.Set_Required_Posn(H_Next, H_Count);
            P.Hos(H_Next).Pref_List(0).Predecessor := 0;
            P.Hos(H_Next).Num_Posts := Num_Posts;
            for Pos in 1..Num_Residents+1 loop
               if not End_Of_Line then
                  Get_Name(Res_Name, Ov, Success);
                  if Success then
                     Map_Res_Name(Res_Name, R_Temp);
                     P.Hos(H_Next).Pref_List(Pos).Resident := R_Temp;
                     P.Hos(H_Next).Pref_List(Pos-1).Successor 
                                        := Pos mod (Num_Residents+1);
                     P.Hos(H_Next).Pref_List(Pos).Predecessor := Pos - 1;
                     P.Hos(H_Next).List_Length := P.Hos(H_Next).List_Length + 1;
                  end if;
               else
                  P.Hos(H_Next).Pref_List(Pos-1).Successor := 0;
                  if P.Hos(H_Next).Pref_List(0).Predecessor = 0 then
                     P.Hos(H_Next).Pref_List(0).Predecessor := Pos - 1;
                  end if;
                  exit;
               end if;
            end loop;
            Skip_Line;
         end if;
      end loop;
      Res_Table.Set_All_Required_Posns;
      Hos_Table.Set_All_Required_Posns;
      Calculate_Res_Ranks(P);
      Calculate_Hos_Ranks(P);
      Make_Lists_Consistent(P);
      if Ov then
         New_Line(3);
         Put("WARNING: one or more names too long. Names more than ");
         Put(Max_Name_Length, Width => 1);
         Put(" characters are truncated");
         New_Line(3);
      end if;
   end Get_Pref_Info;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Check_Line(S : in Natural; C : in out Natural; I : in Natural) is
   -- checks whether a new line is necessary; C is current
   -- column, S is number of columns needed, and I is the indentation
   -- on any new line
   begin
      if C + S > Page_Width then
         C := I;
         New_Line;
         Set_Col(Positive_Count(I));
      end if;
   end Check_Line;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Put_Lists(P : in Pref_Info_Type; A : in Annotation_Type) is
      Name : Name_Type;  
      M, MR, MH, Cols, Indent : Natural;
      R : Natural; --Resident_Index;
      H : Hospital_Index;
   begin
      Res_Table.Get_Max_Name_Length(MR);
      Hos_Table.Get_Max_Name_Length(MH);
      if MH > MR then
         M := MH;
      else
         M := MR;
      end if;
      New_Line;
      Put("Resident Preferences");
      New_Line(2);
      for K in 1 .. Num_Residents loop
         R := Res_Table.Get_True_Entry(K);
         Name := Res_Table.Look_Up(R);
         Put_Name(Name);
         Set_Col(Positive_Count(M+2));
         Put(Colon);
         Cols := M + 2;
         for J in 1 .. Num_Hospitals loop
            if P.Res(R).Pref_List(J).Hospital /= 0 then
               H := P.Res(R).Pref_List(J).Hospital;
               Name := Hos_Table.Look_Up(H);
               Check_Line(M+3, Cols, M+3);
               for L in 1..M+2-Length(Name) loop
                  Put(Blank);
               end loop;
               Put_Name(Name);
               if (A = Resident and H = Res_First_Choice(P, R)) or
                  (A = Hospital and H = Res_Last_Choice(P, R)) then
                  Put(Star);
               else
                  Put(Blank);
               end if;
               Cols := Cols + M + 3;
            end if;
         end loop;
         New_Line;
      end loop;
      New_Line;
      Put("Hospital Preferences");
      New_Line(2);
      if A = None then
         Indent := M + 9;
      else
         Indent := M + 14;
      end if;
      for K in 1 .. Num_Hospitals loop
         H := Hos_Table.Get_True_Entry(K);
         Name := Hos_Table.Look_Up(H);
         Put_Name(Name);
         Set_Col(Positive_Count(M+2));
         Put(Colon);
         Put(Blank);
         Cols := M + 7;
         if A /= None then
            Put(Left_Par);
            Put(P.Hos(H).Num_Posts, width => 2);
            Put(Comma);
            Put(P.Hos(H).Posts_Filled, width => 2);
            Put(Right_Par);
            Cols := Cols + 7;
         else
            Put(P.Hos(H).Num_Posts, width => 2);
         end if;
         Put(Blank);
         Put(Colon);
         Put(Blank);
         for J in 1 .. Num_Residents loop
            R := P.Hos(H).Pref_List(J).Resident;
            if R /= 0 then
               Name := Res_Table.Look_Up(R);
               Check_Line(M+3, Cols, Indent);
               for L in 1..M+2-Length(Name) loop
                  Put(Blank);
               end loop;
               Put_Name(Name);
               if (A = Resident and H = Res_First_Choice(P, R)) or
                  (A = Hospital and H = Res_Last_Choice(P, R)) then
                  Put(Star);
               else
                  Put(Blank);
               end if;
               Cols := Cols + M + 2;
            end if;
         end loop;
         New_Line;
      end loop;
   end Put_Lists;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure Put_Complete_Pref_Lists(P : in Pref_Info_Type) is
   begin
      Put_Lists(P, None);
   end Put_Complete_Pref_Lists;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure List_R_Opt_Matching(P : in Pref_Info_Type) is
      H      : Hospital_Index;  
      Cols, I   : Natural      := 0;  
      Name_I,  
      Name_H : Name_Type;
      File : Ada.Text_IO.File_Type;  
   begin
      Create(File, Name => "output");
      for K in 1..Num_Residents loop
         I := Res_Table.Get_True_Entry(K);
         Name_I := Res_Table.Look_Up(I);
         H := Res_First_Choice(P, I);
         if H /= 0 then
            Name_H := Hos_Table.Look_Up(H);
         else
            Name_H := Blank_Name;
         end if;
         if Cols + Length(Name_I) + Length(Name_H) + 3 > 80 then
            Cols := 0;
            New_Line;
         end if;
         Cols := Cols + Length(Name_I) + Length(Name_H) + 5;
         -- write to console
         Put('(');
         Put_Name(Name_I);
         Put(',');
         Put_Name(Name_H);
         Put(")  ");
         -- write to file
         Put(File, Put_Name(Name_I));
         Put(File, ",");
         Put(File, Put_Name(Name_H));
         New_Line(File);
      end loop;
      Close (File);
      
      -- to be inserted: listing the matching hospital by hospital
   end List_R_Opt_Matching;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure List_H_Opt_Matching(P : in Pref_Info_Type) is
     H      : Hospital_Index;  
      Cols, I   : Natural      := 0;  
      Name_I,  
      Name_H : Name_Type;  
   begin
   
       -- to be inserted: listing the matching hospital by hospital
        
      for K in 1..Num_Residents loop
         I := Res_Table.Get_True_Entry(K);
         Name_I := Res_Table.Look_Up(I);
         H := Res_Last_Choice(P, I);
         if H /= 0 then
            Name_H := Hos_Table.Look_Up(H);
         else
            Name_H := Blank_Name;
         end if;
         if Cols + Length(Name_I) + Length(Name_H) + 3 > 80 then
            Cols := 0;
            New_Line;
         end if;
         Cols := Cols + Length(Name_I) + Length(Name_H) + 5;
         Put('(');
         Put_Name(Name_I);
         Put(',');
         Put_Name(Name_H);
         Put(")  ");
      end loop;
   end List_H_Opt_Matching;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Display_R_Opt_Matching(P : in Pref_Info_Type) is
   begin
      Put_Lists(P, Resident);
   end Display_R_Opt_Matching;
   --------------------------------------------------------

   --------------------------------------------------------
   procedure Display_H_Opt_Matching(P : in Pref_Info_Type) is
   begin
      Put_Lists(P, Hospital);
   end Display_H_Opt_Matching;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Put_Current_Pref_Lists(P : in Pref_Info_Type) is
      Name : Name_Type;  
      H    : Hospital_Index;
      R    : Resident_Index;  
      M, MR, MH, Cols, I : Natural;
   begin
      Res_Table.Get_Max_Name_Length(MR);
      Hos_Table.Get_Max_Name_Length(MH);
      if MH > MR then
         M := MH;
      else
         M := MR;
      end if;
      for K in 1 .. Num_Residents loop
         I := Res_Table.Get_True_Entry(K);
         Name := Res_Table.Look_Up(I);
         Put_Name(Name);
         Set_Col(Positive_Count(M+2));
         Put(Colon);
         Cols := M + 2;
         H := Res_First_Choice(P, I);
         while H /= 0 loop
            Name := Hos_Table.Look_Up(H);
            Check_Line(M+3, Cols, M+3);
            for I in 1..M+2-Length(Name) loop
               Put(Blank);
            end loop;
            Put_Name(Name);
            Cols := Cols + M + 2;
            H := Successor_Hospital(P, I, H);
         end loop;
         New_Line;
      end loop;
      New_Line(2);
      for K in 1 .. Num_Hospitals loop
         I := Hos_Table.Get_True_Entry(K);
         Name := Hos_Table.Look_Up(I);
         Put_Name(Name);
         Set_Col(Positive_Count(M+2));
         Put(Colon);
         Cols := M + 6;
         Put(P.Hos(I).Num_Posts, width => 2);
         Put(Blank);
         Put(Colon);
         Put(Blank);
         R := Hos_First_Choice(P, I);
         while R /= 0 loop
            Name := Res_Table.Look_Up(R);
            Check_Line(M+8, Cols, M+8);
            for I in 1..M+2-Length(Name) loop
               Put(Blank);
            end loop;
            Put_Name(Name);
            Cols := Cols + M + 2;
            R := Successor_Resident(P, I, R);
         end loop;
         New_Line;
      end loop;
   end Put_Current_Pref_Lists;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Init_Pref_Info(P : in out Pref_Info_Type) is
   -- initialise, or re-initialise appropriate preference
   -- information  -  appropriate for use between resident
   -- and hospital oriented versions of the G-S algorithm
   begin
     for I in 1 .. Num_Hospitals loop
        P.Hos(I).Posts_Filled := 0;
        P.Hos(I).Last_Assignee := 0;
     end loop;
     for J in 1 .. Num_Residents loop
     P.Res(J).Assigned := False;
     end loop;
   end Init_Pref_Info;
   --------------------------------------------------------
   
   --------------------------------------------------------
   procedure Apply_GS_R(P : in out Pref_Info_Type) is
      Proposer, Next_Proposer, Next : Resident_Index; 
      Responder     : Hospital_Index;  

   begin
      Init_Pref_Info(P);
      for I in 1 .. Num_Residents loop
         Proposer := I;
         Responder := Res_First_Choice(P, I);
         while Responder /= 0 and Proposer /= 0 loop
            Put_Name(Res_Table.Look_Up(Proposer));
            Put(" proposes to ");
            Put_Name(Hos_Table.Look_Up(Responder));
            New_Line;
            Assign(P, Proposer, Responder);
            if P.Hos(Responder).Posts_Filled > P.Hos(Responder).Num_Posts then
               Next_Proposer := Hos_Last_Choice(P, Responder);
               Put_Name(Res_Table.Look_Up(Next_Proposer));
               Put(" rejected by ");
               Put_Name(Hos_Table.Look_Up(Responder));
               New_Line;
               R_Unassign(P, Next_Proposer, Responder);
            else
               Next_Proposer := 0;
            end if;
            if P.Hos(Responder).Posts_Filled = P.Hos(Responder).Num_Posts then
               Next := Successor_Resident(P, Responder, P.Hos(Responder).Last_Assignee);
               while Next /= 0 loop
                  Remove(P, Next, Responder);
               Put_Name(Res_Table.Look_Up(Next)); Put(' ');
               Put_Name(Hos_Table.Look_Up(Responder));
               Put(" removed");
               New_Line;
                  Next := Successor_Resident(P, Responder, P.Hos(Responder).Last_Assignee);
               end loop;
            end if;
            Proposer := Next_Proposer;
            Responder := Res_First_Choice(P, Proposer);
         end loop;
      end loop;
   end Apply_GS_R;
   --------------------------------------------------------

   --------------------------------------------------------   
   procedure Apply_GS_H(P : in out Pref_Info_Type) is
      Proposer, Next_Proposer, Next : Hospital_Index; 
      Responder     : Resident_Index;  

      -- set up a stack for proposing hospitals
      package Hos_Stack is new Stack(Hospital_Index, Num_Hospitals);
      use Hos_Stack;
      
      Proposer_Stack : Stack_Type;
      
   begin
      Init_Pref_Info(P);
      for I in 1 .. Num_Hospitals loop
         Push(Proposer_Stack, I);
      end loop;
      while not Is_Empty(Proposer_Stack) loop
         Pop(Proposer_Stack, Proposer);
         if P.Hos(Proposer).Posts_Filled = 0 then
            Responder := Hos_First_Choice(P, Proposer);
         else
            Responder := Hos_Next_Choice(P, Proposer);
         end if;
         while Responder /= 0 and then P.Hos(Proposer).Posts_Filled 
                                   < P.Hos(Proposer).Num_Posts loop
            Put_Name(Hos_Table.Look_Up(Proposer));
            Put(" proposes to ");
            Put_Name(Res_Table.Look_Up(Responder));
            New_Line;
            Next := Successor_Hospital(P, Responder, Proposer);
            if P.Res(Responder).Assigned then
               Next_Proposer := Res_Last_Choice(P, Responder);
               Put_Name(Hos_Table.Look_Up(Next_Proposer));
               Put(" rejected by ");
               Put_Name(Res_Table.Look_Up(Responder));
               New_Line;
               H_Unassign(P, Responder, Next_Proposer);
               if P.Hos(Next_Proposer).Posts_Filled 
                        = P.Hos(Next_Proposer).Num_Posts - 1 then
                  Push(Proposer_Stack, Next_Proposer);
               end if;
            end if;
            Assign(P, Responder, Proposer);
            while Next /= 0 loop
               Remove(P, Responder, Next);
               Next := Successor_Hospital(P, Responder, Proposer);
            end loop;
            Responder := Hos_Next_Choice(P, Proposer);
         end loop;
      end loop;
   end Apply_GS_H;
   --------------------------------------------------------   

end HR_Pref_Info;