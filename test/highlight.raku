#!/usr/bin/env raku
# Raku highlighting smoke test for Zed.
#
# Open this file in Zed and check the colours. It exercises the Raku
# constructs the grammar understands; see .plans/zed-raku-extension.plan for
# remaining caveats.

=begin pod

=head1 Highlighting smoke test

Exercises keywords, variables, twigils, strings, numbers, operators, control
flow, subs, regexes, classes/roles, phasers, POD, and a little OO.

=end pod

use v6;

# --- literals & variables ---------------------------------------------------
my $scalar = 42;
my @array  = (1, 2, 3);
my %hash   = (alpha => 1, beta => 2);
my $float  = 3.14159;
my $string = 'single quoted';
my $interp = "value is $scalar";
my @words  = <one two three>;

# --- operators --------------------------------------------------------------
my $sum    = $scalar + $float;
my $diff   = $scalar - 1;
my $prod   = $scalar * 2;
my $quot   = $scalar / 2;
my $same   = $scalar == 42;
my $str-eq = $string eq 'single quoted';
my $concat = $string ~ '!';
my $range  = 1..10;
my $junc   = $scalar == 42 | 43;

# --- compound assignment ----------------------------------------------------
my $counter = 0;
$counter += 1;
$counter max= 10;
my $text = 'a';
$text ~= 'b';

# --- method calls -----------------------------------------------------------
my $upper  = $string.uc;
my $slice  = $string.substr(0, 6);
my @shout  = @words.map(*.uc);
my @big    = (1..10).map(-> $n { $n ** 2 }).grep(* > 50);
my @names  = @words.map: -> $w { $w.tc };
say %hash<alpha>.uc;
say $scalar.base(2);
say $string.?chars;
say $scalar.^name;
say $scalar.&add;

# --- named arguments & sigilless variables ----------------------------------
sub greet(:$name, :$shout = False) {
    say $shout ?? $name.uc !! $name;
}

greet(:name('Raku'));
greet(:name<world>, :!shout);

my \answer = 42;
say answer;

# --- control flow -----------------------------------------------------------
if $scalar > 10 {
    say 'big';
} elsif $scalar > 5 {
    say 'medium';
} else {
    say 'small';
}

unless $scalar == 0 {
    say 'non-zero';
}

while $scalar > 0 {
    $scalar--;
}

for @words {
    say $_;
}

# pointy block
for @words -> $word {
    say $word;
}

given $scalar {
    when 0     { say 'zero' }
    when 1..10 { say 'small' }
    default    { say 'other' }
}

# parenthesised conditions also work
if ($scalar > 0) {
    say 'positive';
}

# --- subs, typed signatures & calls -----------------------------------------
sub add(Int $a, Int $b --> Int) {
    return $a + $b;
}

sub describe($x) of Str { "value: $x" }
sub label($x) returns Str { "$x" }

say add(1, 2);

multi sub identify(Int $n) { "integer $n" }
multi sub identify(Str $s) { "string $s" }
say identify(42);

# signature parameter modifiers
sub optional($a?) { }
sub required(:$b!) { }
sub constrained(Int $c where * > 0) { }
sub mutable($d is rw) { }

my $code = sub { return 42; };
say $code();

# --- regexes ----------------------------------------------------------------
my $digits = rx/ \d+ /;
'abc123' ~~ /(\d+)/;
my $subbed = $string ~~ s/single/double/;

# --- grammars ---------------------------------------------------------------
grammar Calculator {
    token TOP { <number>+ % <op> }
    rule number { \d+ }
    regex op { <[+*]> }
}

# --- classes, roles & packages ---------------------------------------------
class Point {
    method new { return self.bless; }
    method origin { return (0, 0); }
}

# `has` attributes and twigils: $.public, $!private, @.list, %!map
class Vector {
    has $.x;
    has $.y = 0;
    has @.history;
    has %!meta;
    has Int $.count is rw;

    method length(--> Num) {
        sqrt($!x ** 2 + $!y ** 2)
    }
}

role Greeter {
    method greet { return "Hello, world!"; }
}

# parameterised role
role Wrapper[::T] {
    has $.value;
    method get(--> ::T) { $!value }
}

class Robot does Greeter is export {
    method new { return self.bless; }
    method !secret { return 42; }
    method ^meta { return 1; }
    submethod DESTROY { }
}

sub shout() is export { say 'HEY'; }

say Point.new.origin;

# `but` mixes in a role/value
my $greeting = $string but role { method shout { self.uc } };
my $flag     = $scalar but True;

# --- angle subscripts -------------------------------------------------------
my %config = (debug => 1, verbose => 0);
say %config<debug>;
say %hash<alpha beta>;

# --- declarators ------------------------------------------------------------
subset Positive of Int where * > 0;
constant $PI = 3.14159;
my constant Answer = 42;

# --- user-defined operators -------------------------------------------------
sub infix:<plus>(Int $a, Int $b) { $a + $b }
sub prefix:<±>(Int $x) { -$x }
sub postfix:<bang>(Int $n) { $n }
sub term:<now> { time }

# --- reduction metaoperators ------------------------------------------------
my $total  = [+] @array;
my $joined = [~] @words;
my $biggest = [max] @array;

# --- zip, cross & hyper metaoperators ---------------------------------------
my @zipped  = @array Z @words;
my @paired  = @array Z=> @words;
my @summed  = @array Z+ @array;
my @crossed = @array X @words;
my @ewadd   = @array >>+<< @array;
my @ewmul   = @array »*« @array;
my @shouty  = @words>>.uc;

# --- phasers ----------------------------------------------------------------
BEGIN { say 'compile time'; }
INIT  { say 'runtime init'; }
END   { say 'at exit'; }
ENTER { say 'entering'; }
LEAVE { say 'leaving'; }

for 1..3 {
    FIRST { say 'first'; }
    NEXT  { say 'next'; }
    LAST  { say 'last'; }
}
