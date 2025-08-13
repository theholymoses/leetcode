#include <stddef.h>
#include <stdlib.h>

// Takes two numbers represented as strings
// Returns sum of those numbers as a string
char *
add (const char *a, const char *b)
{
  char *rv;
  size_t lrv;
  char *prv;
  char *pa;
  char *pb;
  int carry;
  int sum;
  char tmp;

  lrv = 10;
  if (!(rv = malloc (lrv)))
    goto end;

  pa = (char *)a;
loop_a:
  if (*pa)
    {
    ++pa;
    goto loop_a;
    }
  --pa;

  pb = (char *)b;
loop_b:
  if (*pb)
    {
    ++pb;
    goto loop_b;
    }
  --pb;

  carry = 0;
  prv = rv;
calculate:
  if (lrv <= prv - rv)
    {
    if (!(rv = realloc (rv, lrv + lrv)))
      goto end;

    prv = rv + lrv;
    lrv += lrv;
    }

  if (pa >= a && pb >= b)
    sum = (*pa-- - '0') + (*pb-- - '0');

  else if (pa >= a)
    sum = (*pa-- - '0');

  else if (pb >= b)
    sum = (*pb-- - '0');

  else if (carry)
    sum = 0;

  else
    goto end;

  sum += carry;
  *prv++ = (sum % 10) + '0';
  carry = sum / 10;
  goto calculate;

end:
  *prv-- = 0;
  pa = rv;
  pb = prv;
reverse:
  if (pb > pa)
    {
    tmp = *pb;
    *pb = *pa;
    *pa = tmp;
    --pb;
    ++pa;
    goto reverse;
    }
  return (rv);
}

