#!/usr/bin/perl

# Z88DK Z80 Macro Assembler
#
# Copyright (C) Paulo Custodio, 2011-2020
# License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
# Repository: https://github.com/z88dk/z88dk
#
# Test assembly directives

use Modern::Perl;
use File::Slurp;
use File::Path qw( make_path remove_tree );
BEGIN {
	use lib '.';
	use t::TestZ80asm;
};

#------------------------------------------------------------------------------
# DEFINE / UNDEFINE
#------------------------------------------------------------------------------
z80asm(asm => "DEFINE 			;; error: syntax error");
z80asm(asm => "DEFINE aa, 		;; error: syntax error");
z80asm(asm => "UNDEFINE 		;; error: syntax error");
z80asm(asm => "UNDEFINE aa, 	;; error: syntax error");

z80asm(asm => "DEFINE aa    \n DEFB aa 		;; 01 ");
z80asm(asm => "DEFINE aa,bb \n DEFB aa,bb 	;; 01 01 ");
z80asm(asm => "DEFINE aa,bb \n UNDEFINE aa 		\n DEFB bb 	;; 01 ");
z80asm(asm => "DEFINE aa,bb \n UNDEFINE aa 		\n DEFB aa 	;; error: symbol 'aa' not defined");
z80asm(asm => "DEFINE aa,bb \n UNDEFINE aa,bb 	\n DEFB aa 	;; error: symbol 'aa' not defined");
z80asm(asm => "DEFINE aa,bb \n UNDEFINE aa,bb 	\n DEFB bb 	;; error: symbol 'bb' not defined");

#------------------------------------------------------------------------------
# MODULE
#------------------------------------------------------------------------------

# no module directive
z80asm(
	asm 	=> <<'END',
		main: ret	;; C9
END
);
z80nm("test.o", <<'END');
Object  file test.o at $0000: Z80RMF16
  Name: test
  Section "": 1 bytes
    C $0000: C9
  Symbols:
    L A $0000 main (section "") (file test.asm:1)
END

# one module directive
z80asm(
	asm 	=> <<'END',
		module lib
		main: ret	;; C9
END
);
z80nm("test.o", <<'END');
Object  file test.o at $0000: Z80RMF16
  Name: lib
  Section "": 1 bytes
    C $0000: C9
  Symbols:
    L A $0000 main (section "") (file test.asm:2)
END

# two module directive
z80asm(
	asm 	=> <<'END',
		module lib1
		module lib2
		main: ret	;; C9
END
);
z80nm("test.o", <<'END');
Object  file test.o at $0000: Z80RMF16
  Name: lib2
  Section "": 1 bytes
    C $0000: C9
  Symbols:
    L A $0000 main (section "") (file test.asm:3)
END


#------------------------------------------------------------------------------
# EXTERN / PUBLIC
#------------------------------------------------------------------------------
z80asm(
	asm		=> <<'END',
		extern 				;; error: syntax error
		public 				;; error: syntax error
		global 				;; error: syntax error
		xdef 				;; error: syntax error
		xref 				;; error: syntax error
		xlib 				;; error: syntax error
		lib 				;; error: syntax error
END
);

z80asm(
	asm		=> <<'END',
		public	p1,p2
		xdef p3
		xlib p4
		global  g1, g2
		defc g1 = 16, g3 = 48
		global g3, g4

	p1:	defb ASMPC			;; 00
	p2:	defb ASMPC			;; 01
	p3:	defb ASMPC			;; 02
	p4:	defb ASMPC			;; 03
		defb g1, g2, g3, g4	;; 10 20 30 40

END
	asm1	=> <<'END',
		extern 	p1,p2
		xref p3
		lib p4
		global  g1, g2
		defc g2 = 32, g4 = 64
		global g3, g4

		defb p1,p2,p3,p4	;; 00 01 02 03
		defb g1, g2, g3, g4	;; 10 20 30 40

END
);

#------------------------------------------------------------------------------
# LSTON / LSTOFF
#------------------------------------------------------------------------------
z80asm(
	asm		=> <<'END',
		lstoff				;;
		ld bc,1				;; 01 01 00
		lston				;;
		ld hl,1				;; 21 01 00
END
	options => "-b -l",
);
ok -f "test.lis", "test.lis exists";
ok my @lines = read_file("test.lis");
ok $lines[0] =~ /^ 1 \s+ 0000                      \s+ lstoff          /x;
ok $lines[1] =~ /^ 4 \s+ 0003 \s+ 21 \s+ 01 \s+ 00 \s+ ld     \s+ hl,1 /x;
ok $lines[2] =~ /^ 5 \s+ 0006 \s* $/x;

z80asm(
	asm		=> <<'END',
		lstoff				;;
		ld bc,1				;; 01 01 00
		lston				;;
		ld hl,1				;; 21 01 00
END
	options => "-b",
);
ok ! -f "test.lis", "test.lis does not exist";

#------------------------------------------------------------------------------
# IF ELSE ENDIF - simple use tested in opcodes.t
# test error messages here
#------------------------------------------------------------------------------


