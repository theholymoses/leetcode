#include <stdio.h>
#include <assert.h>

#define LL_DEC_DIGITS 20

static unsigned long long pows[LL_DEC_DIGITS] =
{
  1ULL,
  10ULL,
  100ULL,
  1000ULL,
  10000ULL,
  100000ULL,
  1000000ULL,
  10000000ULL,
  100000000ULL,
  1000000000ULL,
  10000000000ULL,
  100000000000ULL,
  1000000000000ULL,
  10000000000000ULL,
  100000000000000ULL,
  1000000000000000ULL,
  10000000000000000ULL,
  100000000000000000ULL,
  1000000000000000000ULL,
  10000000000000000000ULL
};

static inline int
ith_digit (unsigned long long v, int i)
{
  int rv;

  if (!(0 <= i && i <= LL_DEC_DIGITS - 1))
    rv = -1;
  else
    rv = v % pows[i+1] / pows[i];

  assert (rv != -1);
  return (rv);
}

static inline long long
digit_to_ith_power_of_ten (int d, int i)
{
  long long rv;

  if (!(0 <= i && i <= LL_DEC_DIGITS - 1))
    rv = -1;
  else
    rv = d * pows[i];

  assert (rv != -1);
  return (rv);
}

static inline void
swap_digits (unsigned long long *v, int d1, int d2, int i1, int i2)
{
  *v -= digit_to_ith_power_of_ten (d1, i1);
  *v -= digit_to_ith_power_of_ten (d2, i2);

  *v += digit_to_ith_power_of_ten (d1, i2);
  *v += digit_to_ith_power_of_ten (d2, i1);
}

long long
next_bigger_number (long long n)
{
  unsigned long long rv = n;

  int idx_1   = 0;
  int digit_1 = ith_digit (rv, 0);
  int idx_2   = 0;
  int digit_2;

  // seek first digit that is lesser than the preceeding one
  for (int i = 1; i < LL_DEC_DIGITS && rv >= pows[i]; ++i)
  {
    digit_2 = ith_digit (rv, i);
    if (digit_2 < digit_1)
    {
      idx_2 = i;
      idx_1 = i - 1;
      break;
    }
    digit_1 = digit_2;
  }
  if (!idx_2)
  {
    return (-1);
  }

  // seek a better candidate for swapping
  for (int i = idx_1 - 1; i >= 0; --i)
  {
    int tmp_digit = ith_digit (rv, i);

    if (digit_2 < tmp_digit && tmp_digit < digit_1)
    {
      digit_1 = tmp_digit;
      idx_1   = i;
    }
  }
  swap_digits (&rv, digit_1, digit_2, idx_1, idx_2);

  // sort digits from idx_2 - 1 to 0 in ascending order
  for (int i = idx_2 - 1; i >= 1; --i)
  {
    digit_1 = ith_digit (rv, i);
    int min_digit     = digit_1;
    int min_digit_idx = i;

    for (int j = i - 1; j >= 0; --j)
    {
      digit_2 = ith_digit (rv, j);
      if (digit_2 < min_digit)
      {
        min_digit     = digit_2;
        min_digit_idx = j;
      }
    }
    if (min_digit_idx != i)
    {
      swap_digits (&rv, digit_1, min_digit, i, min_digit_idx);
    }
  }

  return (rv);
}

