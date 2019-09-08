// g++ -O9 --std=c++11 

#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cstdint>

const int smallprime = 1024;
const uint64_t maxprime = 1ULL<<33;
const uint64_t BAD_PARSE = 0x1111111111111111;

char hextab[256];

void make_hextab(void)
{
  for (int i=0; i<256; i++) hextab[i]=0;
  for (int i=0; i<=9; i++) hextab[i+'0']=i;
  for (int i=0; i<=5; i++) hextab[i+'A']=i+10;
  for (int i=0; i<=5; i++) hextab[i+'a']=i+10;
}

char hex(char A)
{
  return hextab[A];
  //  if (A>='0' && A<='9') return A-'0';
  //  if (A>='A' && A<='F') return 10+A-'A';
  //  if (A>='a' && A<='f') return 10+A-'a';
}

inline void inc3(uint64_t* block, uint64_t index)
{
  //  printf("%p %ld\n",block,index);
  uint64_t which_subct = index&31;
  uint64_t dat = block[index>>5];
  uint64_t mask = 3ULL<<(which_subct*2);
  if ((dat&mask)==mask) return;
  block[index>>5] += 1ULL<<(which_subct*2);
}

inline char get3(uint64_t* block, uint64_t index)
{
  uint64_t which_subct = index&31;
  return (block[index>>5]>>(which_subct*2))&3;
}

uint64_t parse_part(const char* start, uint64_t* store)
{
  const char* ix = start; uint64_t ct = 0;
  while (true)
    {
      uint64_t accum = 0;  
      while (*ix != ',' && *ix != ':' && *ix != 0 && *ix != 10)
        {
          //      printf("saw %d with accum=  %ld\n", *ix, accum);
          accum=16*accum+hex(*ix);
          ix++;
        }
      // we have reached the end of the number
      if (accum > maxprime) return BAD_PARSE;
      //      printf("Filing away %ld at %ld\n", accum, ct);
      if (accum > smallprime)
        {
          store[ct]=accum; ct++;
        }
      if (*ix != ',') break;
      // skip over the separator
      ix++;
    }
  return ct;
}

bool parse_line(const char* line, uint64_t* left, uint64_t* right, uint64_t& nleft, uint64_t& nright)
{
  uint32_t len = strlen(line);
  const char* first_colon = strchr(line, ':');
  const char* last_colon = strrchr(line, ':');
  if (!first_colon || !last_colon) return false;

  nleft=parse_part(1+first_colon, left);
  nright=parse_part(1+last_colon, right);
  if (nleft == BAD_PARSE || nright == BAD_PARSE) return false;
  return true;
}


int main(int argc, char** argv)
{
  if (argc!=3) { printf("Syntax: %s {input relations} {output relations}\n", argv[0]); exit(1); }
  make_hextab();
  
  FILE* f = fopen(argv[1],"r");
  FILE* g = fopen(argv[2],"w");

  char line[8192]; memset(line,0,8192);
  uint64_t left_primes[128], right_primes[128];
  uint64_t nleft, nright;

  uint64_t* left = new uint64_t[maxprime/2/8];
  uint64_t* right = new uint64_t[maxprime/2/8];

  uint64_t rct=0, okct=0;
  
  while (!feof(f))
    {
      char* wibble = fgets(line, 4096, f);
      if (feof(f)) break;
      rct++;
      //      printf("%s %p %p\n",line,line,wibble);
      bool ok = parse_line(line, left_primes, right_primes, nleft, nright);
      if (ok)
        {
          //      for (int i=0; i<nleft; i++) printf("%d",get3(left, left_primes[i]/2));
          //      for (int i=0; i<nright; i++) printf("%d",get3(right, right_primes[i]/2));
          //      printf("\t");
          for (int i=0; i<nleft; i++) inc3(left, left_primes[i]/2);
          for (int i=0; i<nright; i++) inc3(right, right_primes[i]/2);
          //      for (int i=0; i<nleft; i++) printf("%d",get3(left, left_primes[i]/2));
          //      for (int i=0; i<nright; i++) printf("%d",get3(right, right_primes[i]/2));
          //      printf("\n");
          okct++;
        }
      if (rct%10000 == 0) { fprintf(stderr,"%ld read  %ld bad  \r", rct, rct-okct); fflush(stderr); }
    }
  fclose(f);
  printf("\n");
  f = fopen(argv[1],"r");
  // OK, now we have initialised the table
  uint64_t happy_ct=0, sad_ct=0;
  while (!feof(f))
    {
      if ((happy_ct+sad_ct)%10000==0) { fprintf(stderr,"ACCEPT %11ld: REJECT %11ld    %9.6f \r", happy_ct, sad_ct, 100.0*(double)sad_ct/(double)(sad_ct+happy_ct)); fflush(stderr); }
      char* wibble = fgets(line, 4096, f);
      if (feof(f)) break;
      bool ok = parse_line(line, left_primes, right_primes, nleft, nright);
      if (ok)
        {
          bool happy = true;
          for (int i=0; i<nleft; i++)
            {
              //              printf("%d %ld %d\n", i, left_primes[i], get3(left,left_primes[i]/2));
              if (get3(left, left_primes[i]/2) == 1) happy=false;
            }
          for (int i=0; i<nright; i++)
            {
              //              printf("%d %ld %d\n", i, right_primes[i], get3(right,right_primes[i]/2));
              if (get3(right, right_primes[i]/2) == 1) happy=false;
            }
          if (happy)
            {
              //              printf("Happy with %s\n", line);
              fprintf(g,"%s",line);
              happy_ct++;
            }
          else
            {
              /*              uint64_t sing=0; char badside='Z';
              for (int i=0; i<nleft; i++)
                if (get3(left, left_primes[i]/2)==1) { sing=left_primes[i]; badside='L'; break; }
              if (badside == 'Z')
                for (int i=0; i<nright; i++)
                  if (get3(right, right_primes[i]/2)==1) { sing=right_primes[i]; badside='R'; break; }
              printf("Sad with %s : singleton %c%lx\n", line, badside, sing); */
        sad_ct++;
      }
  }
    }
}

