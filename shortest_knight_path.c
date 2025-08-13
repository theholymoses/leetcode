#include <limits.h>

// Given two different positions on a chess board,
// find the least number of moves it would take a knight to get from one to the other.
// The positions will be passed as two arguments in algebraic notation.
// For example, knight("a3", "b5") should return 1.

enum
{
  X0 = 'a',
  X1,
  X2,
  X3,
  X4,
  X5,
  X6,
  X7
};

enum
{
  Y0 = '1',
  Y1,
  Y2,
  Y3,
  Y4,
  Y5,
  Y6,
  Y7
};

typedef struct
{
  char x;
  char y;
} pos;

short
search (const pos * const dst, pos src, short mv, int d)
{
  short rv;
  short dir[8];
  pos tmp;
  int i;

  rv = SHRT_MAX;

  if (d == 8 || !(X0 <= src.x && src.x <= X7) || !(Y0 <= src.y && src.y <= Y7))
    return (rv);

  if (src.x == dst->x && src.y == dst->y)
    return (mv);
  
  ++mv;
  ++d;

  tmp.x = src.x - 2;
  tmp.y = src.y - 1;
  dir[0] = search (dst, tmp, mv, d);
  tmp.y = src.y + 1;
  dir[1] = search (dst, tmp, mv, d);

  tmp.x = src.x + 2;
  tmp.y = src.y - 1;
  dir[2] = search (dst, tmp, mv, d);
  tmp.y = src.y + 1;
  dir[3] = search (dst, tmp, mv, d);

  tmp.x = src.x - 1;
  tmp.y = src.y - 2;
  dir[4] = search (dst, tmp, mv, d);
  tmp.y = src.y + 2;
  dir[5] = search (dst, tmp, mv, d);
  
  tmp.x = src.x + 1;
  tmp.y = src.y - 2;
  dir[6] = search (dst, tmp, mv, d);
  tmp.y = src.y + 2;
  dir[7] = search (dst, tmp, mv, d);

  rv = dir[0];
  i = 1;
loop:
  if (i == 8)
    return (rv);
  if (rv > dir[i])
    rv = dir[i];
  ++i;
  goto loop;
}

short
knight (const char *s1, const char *s2)
{
  short rv;
  pos p1;
  pos p2;

  rv = 0;

  if (!s1 || !s1[0] || !s1[1] || !s2 || !s2[0] || !s2[1])
    goto end;
  
  p1.x = s1[0] * (X0 <= s1[0] && s1[0] <= X7);
  p1.y = s1[1] * (Y0 <= s1[1] && s1[1] <= Y7);
  p2.x = s2[0] * (X0 <= s2[0] && s2[0] <= X7);
  p2.y = s2[1] * (Y0 <= s2[1] && s2[1] <= Y7);
  
  if (!p1.x || !p1.y || !p2.x || !p2.y)
    goto end;

  rv = search (&p2, p1, 0, 0);

end:
  return (rv);
}

