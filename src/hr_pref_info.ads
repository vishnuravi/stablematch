-- Generic package to represent preference information for an
-- instance of the hospitals / residents problem

-- Preferences are assumed to be strict, but there is no
-- restriction on the number of participants involved, and
-- preference lists can be incomplete and inconsistent

-- Author: Rob Irving, University of Glasgow
-- Last modified: 31 August 2000

generic

   Num_Residents : Natural;  -- the number of residents
   Num_Hospitals : Natural;  -- the number of hospitals
   
package HR_Pref_Info is

   type Pref_Info_Type is private;
   
   procedure Get_Pref_Info(P : out Pref_Info_Type);
   -- reads in preference information from standard input
   -- assumes first n lines contain the preference list of
   -- resident i (i = 1,..,n) in the form i : a b c . . .
   -- next m lines contain the preference list of
   -- hospital j (j = 1,..,m) in the form j : p : a b c . .
   -- where p is the number of posts;
   -- here, n = Num_Residents, m = Num_Hospitals
   
   procedure Put_Complete_Pref_Lists(P : in Pref_Info_Type);
   -- writes the complete preference lists to standard output
   -- residents lists, one per line, a blank line, then
   -- hospitals lists one per line, in same format as input
   
   procedure List_R_Opt_Matching(P : in Pref_Info_Type);
   -- writes to standard output the resident optimal stable matching
   -- for the hospitals / residents instance specified by P;
   -- the matching is listed by resident, and then separately by hospital
   
   procedure List_H_Opt_Matching(P : in Pref_Info_Type);
   -- writes to standard output the hospital optimal stable matching
   -- for the hospitals / residents instance specified by P;
   -- the matching is listed by hospital, and then separately by resident

   procedure Display_R_Opt_Matching(P : in Pref_Info_Type);
   -- displays to standard output, in the form of annotated
   -- preference lists, the resident optimal stable matching
   -- for the hospitals residents instance specified by P

  procedure Display_H_Opt_Matching(P : in Pref_Info_Type);
   -- displays to standard output, in the form of annotated
   -- preference lists, the hospital optimal stable matching
   -- for the hospitals residents instance specified by P
   
   procedure Put_Current_Pref_Lists(P : in Pref_Info_Type);
   -- displays to standard output the current preference lists;
   -- for example, when called after the G-S algorithm has been
   -- executed, will display the appropriate GS-lists
   
   procedure Apply_GS_R(P : in out Pref_Info_Type);
   -- applies the GS-algorithm from the residents' side; leaves the
   -- GS-lists represented in P
   
   procedure Apply_GS_H(P : in out Pref_Info_Type);
   -- applies the GS-algorithm from the hospitals' side; leaves the
   -- GS-lists represented in P

   Table_Overflow : exception;
   -- raised if the number of resident or hospital identifiers
   -- exceeds the number as specified in the input
   

private

   subtype Resident_Index is Integer range 0 .. Num_Residents;
   subtype Hospital_Index is Integer range 0 .. Num_Hospitals;
   subtype Res_Rank_Index is Integer range 0 .. Num_Residents+1;
   subtype Hos_Rank_Index is Integer range 0 .. Num_Hospitals+1;

   type Resident_Node is
      record
         Resident : Resident_Index := 0;
         Predecessor, Successor : Res_Rank_Index;
      end record;
      
   type Hospital_Node is
      record
         Hospital : Hospital_Index := 0;
         Predecessor, Successor : Hos_Rank_Index;
      end record;
      
   type Res_Pref_List_Type is array(Hos_Rank_Index) of Hospital_Node;
   type Hos_Pref_List_Type is array(Res_Rank_Index) of Resident_Node;
   type Res_Rank_Type is array(Hospital_Index) of Hos_Rank_Index;
   type Hos_Rank_Type is array(Resident_Index) of Res_Rank_Index;
   
   type Resident_Type is
      record
         Pref_List : Res_Pref_List_Type;
         Rank : Res_Rank_Type := (others => Num_Hospitals+1);
         List_Length : Natural := 0;
         Assigned : Boolean := False;
      end record;
      
   type Hospital_Type is
      record
         Num_Posts : Natural;
         Pref_List : Hos_Pref_List_Type;
         Rank : Hos_Rank_Type := (others => Num_Residents+1);
         List_Length : Natural := 0;
         Posts_Filled : Natural := 0;
         Last_Assignee : Resident_Index := 0;
      end record;
      
   type Res_Pref_Info_Type is array(Resident_Index) of Resident_Type;
   type Hos_Pref_Info_Type is array(Hospital_Index) of Hospital_Type;
   
   type Pref_Info_Type is
      record
        Res : Res_Pref_Info_Type;
        Hos : Hos_Pref_Info_Type;
      end record;
      
end HR_Pref_Info;