# stream_read

stream_read is a modified version of stream from Dr. McCalpin
You can get the original from:
wget -O ./stream.c https://www.cs.virginia.edu/stream/FTP/Code/stream.c

This version adds a 'pure read' bandwidth subtest.
The output looks like:

Function    Best Rate MB/s  Avg time     Min time     Max time
Copy:           85113.7     0.100978     0.100923     0.101038
Scale:          84766.9     0.101441     0.101336     0.101823
Add:            96043.5     0.134286     0.134157     0.134463
Triad:          96079.9     0.134173     0.134106     0.134390
Read:          134521.1     0.031982     0.031928     0.032070

The read subtest casts the double array as an integer array and
sums the array. In openmp this is a reduction operation.

You need to make sure the array size is big enough so that it
doesn't reside mostly in L3. Usually this means multigigabyte
array sizes. Stream reports the array size per array and the
total memory used for the arrays. This is not a 'per cpu'
memory size. The arrays are shared.

There is also a rn_strea_read.sh script showing how to compile
and run stream on a (linux) server and macbook.

There is a discussion of with Dr. McCalpin regarding adding a
stream_read component below.
https://community.intel.com/t5/Software-Tuning-Performance/Modifying-stream-benchmark-to-report-read-bandwidth/td-p/1261261

