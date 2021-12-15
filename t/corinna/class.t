#!/usr/bin/perl

use v5.36;
use warnings;

use Test::More;
use B qw( svref_2object );

use feature 'class';

subtest 'A simple class' => sub {
    class Point {
        my $total = 0;
        field $x {10};
        field $y {20};

        ADJUST   { $total++ }
        DESTRUCT { $total-- }

        method to_string() { sprintf "($x,$y)" }

        method total() { $total }

        method set( $new_x, $new_y ) {
            $x = $new_x;
            $y = $new_y;
        }
    }

    my $p = Point->new;
    is svref_2object($p)->REFCNT, 1, '$p has refcount 1 initially';

    is $p->to_string, "(10,20)",
      'We should be able to see a string representation of a point';
    is svref_2object($p)->REFCNT, 1, '$p has refcount 1 after method';

    is $p->total, 1, 'We should have one point created';
    $p->set( 4, 5 );
    is $p->to_string, "(4,5)", 'We should be able to set a new point value';
    is svref_2object($p)->REFCNT, 1, '$p has refcount 1 after method';

    ok my $p2 = Point->new, 'We should be able to create a second point';
    is $p2->total, 2, '... and see that we now have two points total';
    is $p2->total, $p->total,
      '... and both point objects should agree on the total';

    is $p2->to_string, "(10,20)",
      'Our new point object should have the correct defaults';
    is $p->to_string, "(4,5)",
      '... but our previous object should maintain its own state';

    is svref_2object($p)->REFCNT, 1,  '$p has refcount 1 after method';
    is svref_2object($p2)->REFCNT, 1, '$p2 has refcount 1 after method';

    undef $p;
    is $p2->total, 1,
'After an object is destroyed, our DESTRUCT method should reduce the total again';
};

done_testing;
