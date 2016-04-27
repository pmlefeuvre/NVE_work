-----------------------------------------------------------------
---------------------     README.txt    -------------------------
-----------------------------------------------------------------

Author:  PiM Lefeuvre
Date: 	 2013.07.05 
Updated: 2016.04.26
Work: 	 Reorganising Raw data for the period 1992-2013


-----------------------------------------------------------------

This text file gathers all the manual edits made to the Raw files 
collected before 2013. A summary of all data exists in:
Data_list_compiled_20160411.xls
for data before 1999.
The names of the files (I got compared to the summary) differ by not 
having capital letters and are written "data" insead of "DATA".

-----------------------------------------------------------------

In "Raw_copy", The files are original and not modified. They come from
NVE's Archive ("diverse gammel/trykkdata"). 
I have reorganised them:
- placing Raw data with extension ".dat" or ".DAT" in the folder "Raw"
- placing Raw data with extension ".txt" in the folder "Raw txt"
- placing Raw data that had ambiguities according to NVE's DataLists, 
  that I obtained, in the folder "Raw_{YEAR}"

-----------------------------------------------------------------
Modifications:

In each folder "Raw", I only kept data from the year of the folder. 
=> Removal of previous and next year data in the raw files, because 
a problem arises if the files are merged and sorted. It is going to
mix different years.

-----------------------------------------------------------------

- Folder "1992"
=> data001.dat: Removed unknown data and kept LC data within the first 14 lines (Before 344 10:00). To get continuity in the data, I added two lasts empty columns between 344 05:00 and 344 13:00 as well as one last empty column between 344 14:00 and 346 12:00. Then I added one column to the rest of the data with$ cat data001.dat | sed 's/^M/,^M/' > /tmp/data001.dat; mv /tmp/data001.dat data001.dat
I had to remove ^M:
$ for i in Ordered/*.dat; do cat $i | sed 's/^M//' > /tmp/${i##*/}; mv /tmp/${i##*/} $i; done
=> Data from 1993 were deleted from data001.dat

- Folder "1993"
=> Data from 1992 were deleted from data001.dat
=> data0[09-18].dat: Removed unknown data and kept LC data in the whole file. Quite a volume of none LC data. I also deleted file data014.dat because there was no LC data.
=> data0[29-31].dat, data0[33-39].dat, data041.dat and data043.dat were deleted (Niel's data)
=> data040.dat I added two empty columns (i.e. ",,") to keep coherence in the file despite the rewiring (see RAWDATA_SUM.xls)
=> Extracted LC data (from Niel Iversons') from files (data0[48,49,51,53,54,55,57,58,60-62].dat) with this code: 
$ for i in 48 49 51 53 54 55 57 58 60 61 62;
$ do awk -F, -v OFS=, '{if ($1==211) print $0}' ../Raw_Backup/data0$i.dat  > data0$i.dat
$ done
=> data0[50,52,56,59,63-69,72-75].dat were deleted because no LC data

- Folder "1994"
=> data0[76-79,82,84].dat were deleted because no LC data
=> Extracted LC data from files (data0[80,81].dat) with this code: 
$ for i in 81 82;do awk -F, -v OFS=, '{if ($1==211) print $0}' ../Raw_Backup/data0$i.dat  > data0$i.dat; done
=> Data from 1995 were deleted from data096.dat and the file data097.dat was removed (only 1995).
	
- Folder "1995"
=> Data from 1994 were deleted from data096.dat
=> In data098.dat, the message "[Datalogger] replaced all -99999 with 0 it seems!!" was deleted. 0s were replaced by -99999 and "^M" (press CTRL-V CTRL-M) were deleted using:
$ cat ../Raw_BackUp/data098.dat | awk -F, -v OFS=, '{if($4==0) $4=-99999; if($5==0) $5=-99999; if($6==0) $6=-99999; if($7==0) $7=-99999;if ($8==0) $8=-99999; if($9~0) $9=-99999;}{ print $0}' | sed -e "s/^M//" > data098.dat

- Folder "1996"
=> Data from 1997 were deleted from data096.dat and 0s were replaced by -99999 using:
$ cat ../Raw_BackUp/DAT97_01.DAT | awk -F, -v OFS=, '{if($4==0) $4=-99999; if($5==0) $5=-99999; if($6==0) $6=-99999; if($7==0) $7=-99999;if ($8==0) $8=-99999; if($9~0) $9=-99999;}{ print $0}' > DAT97_01.DAT 

- Folder "1997"
=> In DAT97_01.DAT, Data from 1996 were deleted. 0s were replaced by -99999 and "^M" (press CTRL-V CTRL-M) were deleted with:
$ cat ../Raw_BackUp/DAT97_01.DAT | awk -F, -v OFS=, '{if($4==0) $4=-99999; if($5==0) $5=-99999; if($6==0) $6=-99999; if($7==0) $7=-99999;if ($8==0) $8=-99999; if($9~0) $9=-99999;}{ print $0}' |  sed -e "s/^M//" > DAT97_01.DAT  
=> In the files DAT97_[02-11].DAT, 0s were replaced by -99999 and "^M" (press manually CTRL-V CTRL-M) were deleted with:
$ for i in 02 03 04 05 06 07 08 09 10 11; do cat ../Raw_BackUp/DAT97_$i.DAT | awk -F, -v OFS=, '{if($4==0) $4=-99999; if($5==0) $5=-99999; if($6==0) $6=-99999; if($7==0) $7=-99999;if ($8==0) $8=-99999; if($9~0) $9=-99999;}{ print $0}' |  sed -e "s/^M//" > DAT97_$i.DAT; done
=> In DAT98001.dat, Data from 1998 were deleted.

- Folder "1998"
=> In DAT98001.dat, Data from 1997 were deleted.
=> In Data99_01.dat, Data from 1999 were deleted.

- Folder "1999"
=> I have added to "1999/Raw" Gaute's compiled file "1999.dat" and renamed
it "FromGaute'sBackup_1999.dat"

- Folder "2000"
=> I have added to "2000/Raw" Gaute's compiled file "Compiled_2000.csv" and
converted it into"FromGaute'sBackupCompiled_2000.dat"

- Folder "2001"
=> I have added to "2001/Raw" 2 text files "MAR20001.txt" &
"MAR30001.txt" (79 - 89) and converted them into ".dat".
=> Because the file "2001_sep-des_15.dat" was missing, I have added 
to "2001/Raw" the Excel file "DEC3101.xls" and converted it in ".dat".
This file has the same time span according to the DataList.
cmd: xls2csv -x DEC3101.xls | sed "s/\"//g" > Raw/DEC3101.dat | chmod u+x

- Folder "2002"
=> I have added to "2002/Raw" 12 text files: 
Data02_0227.txt  Data02_0417.txt  Data02_0705a.txt Data02_0706b.txt
Data02_0228.txt  Data02_0419.txt  Data02_0705b.txt Data02_0707.txt
Data02_0406.txt  Data02_0420.txt  Data02_0706a.txt Data02_0731.txt 
and converted into ".dat". (1-59)
=> The file Data02_0705b contains weird data (maybe pump test) which have
a sampling rate < 1min. (103 11:45 - 103 14:05) I removed them and saved
the data in a new file: Data02_0705b_edited.dat

=> Some Raw files were found in Gaute's Backup for the year 2002 in:
JULY0501.dat
The first part of the data seems to be a pump test up and I had to correct:
First line was removed (date missing) ",92.786,42.348,110.73,44.379"

Original data:
"103,1405,55,85.028,93.445,46.21,401,1.7947,1.5603,1.8981,1.6798,1.5253,1.5113,-99999
 113,121,416,1.7949,1.5603,1.8979,1.6795,1.5251,1.5113,-99999"
became
"103,1405,55,85.028,93.445,46.21,
 113,121,401,1.7947,1.5603,1.8981,1.6798,1.5253,1.5113,-99999
 113,121,416,1.7949,1.5603,1.8979,1.6795,1.5251,1.5113,-99999"


- Folder "2003"
=> I removed data from 2004 in the file "Copy of MAR24001.dat"


- Folder "2004"
=> I removed data from 2005 in the file "Data 329-73.dat"
=> I removed messed up data at the end of "OCT16001.dat"
=> I removed the first line (missing dates) of "NOV24ALL.dat"
=> I removed the first line (missing dates) of "Data 309-326.dat"

- Folder "2005"
=> I removed data from 2004 in the file "Data 329-73.dat"
=> I removed data from 2006 in the file "APR19001.dat"

- Folder "2006"
=> I removed data from 2005 in the file "APR19001.dat"
=> I removed data from 2007 in the file "07MAR03.dat"

- Folder "2007"
=> I removed data from 2006 in the file "07MAR03.dat" & "CR10_to_jan15.dat"
(They seem identical)
=> I removed data from 2008 in the file "mars2008_026.dat"
=> I removed the first line (missing dates) of "CR10_to_dec04.dat"

- Folder "2008"
=> I removed data from 2007 in the file "mars2008_026.dat"

- Folder "2009"
=> I removed data from 2010 in the file "trykk_13mar002.dat"
=> Manual correction of files: "trykk_mars0XXX.dat" & "trykk_oct023.dat"
Creation of a directory "Correction_trykk_marsXXX" & a bash code that apply
date correction, compile results and copy them to the directory "Raw".
"trykk_oct023.dat" was also converted from tab-separated to comma-separated.

- Folder "2010"
=> I removed data from 2009 in the file "trykk_13mar002.dat" 
=> I added "trykk_31mar001.dat" (2009-2010) to "Raw" & "Raw_copy"
=> I removed data from 2011 in the file "trykk_31mar001.dat" 
=> Replaced on the correct line in "Engabreen_apr06_2010.dat"
"113,85,2315,1.7907,-99999,1.7741,1.7142,1.6094,-99999,-99999"
(data missing between 85,1039 and 85,2315 also seen in "Engabreen_mars29_2010.dat")
"113,93,2247,1.7806,-99999,1.7597,1.7365,1.5984,1.6609,-99999"
(data missing between 90,1413 and 93,2247)
=> Replaced on the correct line in "Engabreen_apr14_2010.dat"
"113,99,2353,1.8033,-99999,1.776,1.7428,1.5597,1.6525,-99999"
(data missing between 99,1403 and 99,2353 also seen in "Engabreen_apr12_2010.dat")
=> I added to Raw: 
Engabreen_apr06_2010.dat            Engabreen_mars25_2010.dat
Engabreen_apr12_2010.dat            Engabreen_mars26_2010.dat
Engabreen_apr14_2010.dat            Engabreen_mars29_2010.dat
Engabreen_apr9_2010.dat             Engabreen_mars31_2010.dat
Engabreen_mars24_2010_corrected.dat 
=> Old data (15min interval) in "Engabreen_mars24_2010.dat" were removed and 
Correct data (2min interval) were saved in "Engabreen_mars24_2010_corrected.dat"

- Folder "2011"
=> I removed data from 2010 in the file "trykk_31mar001.dat" 
=> I removed the first line (missing dates) of "trykk_okt07.dat",
"trykk_okt12.dat", "trykk_okt20.dat", "trykk_09nov001.dat" & "trykk_23nov001.dat"

- Folder "2012"
=> I removed data from 2013 in the file "trykk2_19apr001.dat"
=> 2 Date Corrections were applied to some data (see Folders called "Correction_…")

- Folder "2013"
=> I removed data from 2012 in the file "trykk2_19apr001.dat"
!! New Data were collected and integrated to produce a new easy to use dataset (less files):
=> I removed data from 2012 in the file "trykk2_06jun001.dat"
=> I removed data from 164 (04:19) to 204 (19:35) in "Kopi_av_trykk_29nov002.dat" as there are duplicates of "trykk_17sep001.dat". The last line of the original was also corrupted. I deleted the last 4 numbers.
=> First line of "trykk2_06jun001.dat", was corrupted and I deleted the first non coherent data
