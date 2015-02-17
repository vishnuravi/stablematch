# stablematch
Stable Matching Algorithm for the Hospital-Residents Problem

The Hospital-Resident problem involves finding stable matches between residents (doctors) and hospitals. This program uses an extended version of the Gale-Shapley algorithm, originally developed by Rob Irving.

#To build
```
gnatmake solve_hr.adb
```

#To run 
```
./solve_hr < data
```

#Input
Input is given as text on standard input as follows:
- Line 1: N, M, positive integers, numbers of residents and hospitals respectively
- Lines 2..N+1: the resident preference lists, each has form X : A B C ...
- Lines N+2..M+N+1: the hospital preference lists, each has form X : P : A B C ..., where P is the number of positions available

Sample data can be generated using the included script 'data/generate_preflists.py'.
