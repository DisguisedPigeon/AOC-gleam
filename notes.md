# Intersection perpendicular vector, square
given 2 opposite edges and the start and end points of the vector.

#(s, e)
#(p, q)

#(
    p.0, p.1;
    p.0, q.1;
    q.0, q.1;
    q.0, p.1
)

#(
    #(
        p.0, p.1;
        p.0, q.1;
    ),
    #(
        p.0, q.1;
        q.0, q.1;
    ),
    #(
        q.0, q.1;
        q.0, p.1
    ),
    #(
        q.0, p.1
        p.0, p.1;
    )
)

s1, e1
s2, e2

s1.x < s2.x
e1.x > e2.x

s1.x != e1.x => s1.x < s2.x && e1.x > s2.x // == e2x.
                && s1.x > s2.x && e1.x < s2.x // == e2x.
                && s2.y < s1.y && e2.y > s1.y // == e1y.
                && s2.y > s1.y && e2.y < s1.y // == e1y.

s1.y != e1.y => s1.x < s2.y && e1.y > s2.y // == e2x.
                && s1.x > s2.y && e1.y < s2.y // == e2x.
                && s2.x < s1.x && e2.x > s1.x // == e1y.
                && s2.x > s1.x && e2.x < s1.x // == e1y.


