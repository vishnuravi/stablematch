-- Program to solve arbitrary instances of the hospitals residents problem

-- Author: Rob Irving, University of Glasgow
-- Modified by Vishnu Ravi, February 2015

-- Input is as follows:
   -- Line 1: N, M, positive integers, numbers of residents and hospitals respectively
   -- Lines 2..N+1: the resident preference lists, each has form X : A B C ...
   -- where X is the owner and A, B, C, ... are entries in order;
   -- Lines N+2..M+N+1: the hospital preference lists, each has form X : P : A B C ...
   -- where X is the owner, P is the number of posts, and A, B, C, ... are entries in order;
   -- identifiers are arbitrary strings of up to 20 chars
   
-- Assumptions
   -- each preference list is on a single line, with no trailing blanks
   -- number of lists corresponds to input values of n and m
   -- lists need not be complete, nor need they be consistent

with Ada.Text_Io;  use Ada.Text_Io;
with Ada.Integer_Text_Io;  use Ada.Integer_Text_Io;

with HR_Pref_Info;

procedure Solve_HR is 
   N, M : Natural;  
begin
   Get(N);  -- the number of residents in the instance
   Get(M);  -- the number of hospitals in the instance
   Skip_Line;
   
   declare  -- block to allow instantiation of appropriate packages
      package P is new HR_Pref_Info(N, M); 
      -- N and M give appropriate sizes for the preference structure 
      use P;

      P_I         : Pref_Info_Type;      -- the preference structure

   begin
      -- Get the preference lists
      Get_Pref_Info(P_I);
      
      -- Apply Gale-Shapley from the residents' side
      Apply_GS_R(P_I);
      Put_Line("Reduced Lists after Residents' Proposals:");
      New_Line;
      Put_Current_Pref_Lists(P_I);
      New_Line(3);
      
      -- Apply Gale-Shapley from the hospitals' side
      Apply_GS_H(P_I);
      Put_Line("Final Gale-Shapley Lists:");
      New_Line;
      Put_Current_Pref_Lists(P_I);
      New_Line(3);

      -- Print resident-optimal solution
      Put("List of matched pairs (Resident-optimal)");
      New_Line(2);
      List_R_Opt_Matching(P_I);
      New_Line(3);
      
      -- Print hospital-optimal solution
      Put("List of matched pairs (Hospital-optimal):");
      New_Line(2);
      List_H_Opt_Matching(P_I);
      New_Line(3);          
      
   exception
      when Table_Overflow =>
         Put_Line("The number of preference lists does not match the given number of residents or hospitals in the instance. Please check data.");
   end;
end Solve_HR;
