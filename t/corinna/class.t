#!/usr/bin/perl

use v5.36;
use warnings;
use Test::More;

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

    is $p->to_string, "(10,20)",
      'We should be able to see a string representation of a point';

    is $p->total, 1, 'We should have one point created';
    $p->set( 4, 5 );
    is $p->to_string, "(4,5)", 'We should be able to set a new point value';

    ok my $p2 = Point->new, 'We should be able to create a second point';
    is $p2->total, 2, '... and see that we now have two points total';
    is $p2->total, $p->total,
      '... and both point objects should agree on the total';

    is $p2->to_string, "(10,20)",
      'Our new point object should have the correct defaults';
    is $p->to_string, "(4,5)",
      '... but our previous object should maintain its own state';

    undef $p;
    is $p2->total, 1,
'After an object is destroyed, our DESTRUCT method should reduce the total again';
};

done_testing;
