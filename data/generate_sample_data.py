#!/usr/bin/env python

'''
Generates set of sample resident and hospital preference lists for Irving hospital-resident matching algorithm
Author: Vishnu Ravi

Output file is generated as follows:
- Line 1: N, M, positive integers, numbers of residents and hospitals respectively
- Lines 2..N+1: the resident preference lists, each has form X : A B C ...
- Lines N+2..M+N+1: the hospital preference lists, each has form X : P : A B C ...
- Residents and hospitals are represented as [resident_prefix]1...[resident_prefix]N, [hospital_prefix]1...[hospital_prefix]M

'''

import random, time, sys, math

def main():

	#edit the values below to configure the data set
	total_residents = 100
	total_hospitals = 100
	resident_rol_len = 10 #average resident preference list length (number of hospitals ranked by residents)
	resident_rol_sd = 3 #standard deviation of resident preference list length
	hospital_num_positions = 6 #average number of positions per hospital
	hospital_num_positions_sd = 2 #standard deviation of positions per hospital
	hospital_prefix = 'Hospital-' #prefix added to hospital ID number in sample data set
	resident_prefix = 'Resident-' #prefix added to resident ID number in sample data set
	output_file = 'data.txt'
	#stop editing here


	output = '' 
	residentListOutput = ''
	hospitalListOutput = ''

	#pref lists
	resident_prefs = [[] for _ in range(total_residents)]
	hospital_prefs = [[] for _ in range(total_hospitals)]



	print("\nGenerating Resident Rank Order Lists...");

	#residents 'apply' to hospitals
	for this_resident in range(total_residents):
			update_progress((this_resident+1)/float(total_residents))
			hospitals_randomized = list(range(total_hospitals))
			random.shuffle(hospitals_randomized)
			this_resident_rol_len = int(random.normalvariate(resident_rol_len, resident_rol_sd))
			for n in range(this_resident_rol_len):
				resident_prefs[this_resident].append(hospitals_randomized.pop())

			residentListOutput += resident_prefix + str(this_resident) + " :"
			for rank in range(len(resident_prefs[this_resident])):
				residentListOutput += " " + hospital_prefix  + str(resident_prefs[this_resident][rank])
			residentListOutput += '\n'

	print("\nGenerating Hospital Rank Order Lists...");

	#hospitals rank residents that have 'applied'
	for this_hospital in range(total_hospitals):
			update_progress((this_hospital+1)/float(total_hospitals))
			for resident in resident_prefs:
				if this_hospital in resident:
					hospital_prefs[this_hospital].append(resident_prefs.index(resident))


			this_hospital_num_positions = int(random.normalvariate(hospital_num_positions, hospital_num_positions_sd))
			hospitalListOutput += hospital_prefix + str(this_hospital) + " : " + str(this_hospital_num_positions) + " :"
			this_hospital_num_ranks = len(hospital_prefs[this_hospital])
			for rank in range(this_hospital_num_ranks):
				hospitalListOutput += " " + resident_prefix + str(hospital_prefs[this_hospital][rank])
			hospitalListOutput += '\n'



	output += str(total_residents) + " " + str(total_hospitals) + "\n" + residentListOutput + hospitalListOutput


	#write output to output_file
	datafile = open(output_file, "w")
	datafile.write(output)
	datafile.close()

	print("\nDataset generation complete.\n");

def update_progress(progress):
	'''Generates a progress bar'''
	barLength = 30 # length of the progress bar
	status = ""
	if isinstance(progress, int):
		progress = float(progress)
	if progress < 0:
		progress = 0
		status = "Halt...\r\n"
	if progress >= 1:
		progress = 1
		status = "Done...\r\n"
	block = int(round(barLength*progress))
	text = "\r[{0}] {1}% {2}".format( "#"*block + "-"*(barLength-block), round(progress*100, 2), status)
	sys.stdout.write(text)
	sys.stdout.flush()

if __name__ == "__main__" : main()
