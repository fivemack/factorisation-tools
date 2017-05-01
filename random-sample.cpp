// Produce a random sample of lines from a file

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <stdio.h>
#include <stdlib.h>

#include <vector>
#include <set>
using std::vector;
using std::set;

void println(unsigned char* start, unsigned char* end)
{
  for (unsigned char* ptr = start; ptr <= end; ptr ++)
    fputc(*ptr, stdout);
}

int main(int argc, char** argv)
{
  if (argc != 3)
    {
      printf("Syntax: %s <number of lines to sample> <filename>\n\n",argv[0]);
      return 1;
    }
  
  int fd = open(argv[2], O_RDONLY);
  struct stat sobj;
  fstat(fd, &sobj);
  long len = sobj.st_size;
  unsigned char* dat = (unsigned char*)mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd, 0);
  fprintf(stderr,"Mapping %ld bytes at %p\n", len, dat);

  long num = atoi(argv[1]);

  vector<long> line_starts;
  line_starts.push_back(0);
  for (long k=0; k<len; k++)
    if (dat[k]==10)
      line_starts.push_back(k+1);
  line_starts.push_back(len);
  
  long nl = line_starts.size();

  fprintf(stderr,"Found %ld lines\n",nl);
  if (nl < num)
    {
      fprintf(stderr,"Asked for more samples than there are lines!\n");
      return 2;
    }

  set<long> used;
  for (int k=0; k<num; k++)
    {
      unsigned long posn;
      do
	{
	  posn = rand();
	  posn = RAND_MAX*posn+rand();
	  posn = RAND_MAX*posn+rand();
	  posn %= nl;
	} while (used.find(posn)!=used.end());
      used.insert(posn);
      println(dat+line_starts[posn], dat+line_starts[1+posn]-1);
    }
}
