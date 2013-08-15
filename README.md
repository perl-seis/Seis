# NAME

Rokugo - Perl6 on Perl5

# SYNOPSIS

    for 1..100 { .say }

# DESCRIPTION

Rokugo is transpiler for Perl6's syntax to Perl5.

It's only emulate perl6's syntax. Not semantics.

But it's useful because perl6's syntax is sane.

# TODO

    Support 'has' and attributes.
    Implement builtin methods

# KNOWN ISSUES

There is some known issues. Rokugo do in the forcible way.
And Rokugo placed great importance on performance.
Then, rokugo giving ups some features on Perl 6.

If you have any ideas to support these things without performance issue, patches welcome(I guess most of features can fix if you are XS hacker).

## Compilation speed is optimizable

You can rewrite code generator to generate B tree directly.

I know it's the best way, but I don't have enough knowledge to do.
Please help us.

## Automatic literal conversion is not available

Perl6 has some more string litrals perl5 does not have.

For example, I can't generate fast code from following code:

    say 'ok ', '0b1010' + 1;
    say 'ok ', '0o6' * '0b10';

Note. THere is a idea... You can support this feature in fast code with XS magic. You can replace pp code in XS world...

Another option, you can send a patch for support perl6 style literals to p5p.

## No stringification available about refs

Following code does not works well. I need overloading stuff in autobox.pm.

    ~<a b>

This issue can solve with PP\_check hack.

## \`eqv\` operator is not compatible.

Not yet implemented.

# LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokuhirom <tokuhirom@gmail.com>
