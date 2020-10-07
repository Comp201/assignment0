# Comments in makefiles follow the same form as comments in bash.
# Makefiles need to be named "Makefile" or "makefile".

# In makefiles, variables are declared in the following manner (the entire
# string after the equals and up to but excluding the newline is the
# content of the variable)
#
# Note: there are other ways to declare variables that are not explored in this
# tutorial.
TARGET = $(shell basename $(CURDIR))
TARGET = assignment0

# To access a make variable, do
# 	$(FOO)
# Make sure to use parentheses (they are necessary in most cases).

# It is traditional in make to have whitespace separated lists. In make, a \
# at the end of a line removes the following newline.
SOURCES = $(shell find . -name '*.c')
TESTS = $(addsuffix .test, $(basename $(shell find . -name '*.test-in')))


# The syntax below is a special way to access a variable that also does a
# pattern replacement : in this case, it replaces all .c extensions with a .o
#
# Another common alternative is:
# 	OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
OBJECTS := $(SOURCES:.c=.o)

# These are default variables in make, but it is traditional to overwrite them.
CC=gcc
CFLAGS= -O2 -g -Wall
LD=ld
LDFLAGS= -lSystem

# Make rules are of the form (target) : (pre-requisite). The first make
# rule in the file the default one executed when you call "make" with no
# arguments. It is possible to run a different rule by running "make test",
# for example. Consequently, it is traditional for an "all" or "default" rule
# to be the first one in a file.
all : $(TARGET)

# All lines following the make rule that are indented by a tab are known as
# the recipe for a rule and are executed by a shell if the rule needs to be
# evaluated.  In addition, make specifies some special variables that are
# valid in the context of a make rule:
# 	$@ expands to the target in question
# 	$^ expands to the space separated list of all the pre-requisites
# 	$< expands to the name of the first pre-requisite
# 	(There are many more, but these three are the most common)
#
# In this case, the recipe (after expansion of make variables) is
# 	ld -o my_cc lexicalanalyzer.o parser.o pmachine.o driver.o
$(TARGET) : $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

# Note that more than one target can be on the left hand side for a given make
# rule. This is equivalent to making a unique rule for each target of the make
# rule.
#
# In this case, this is a special form of a make rule where make attempts to do
# pattern matching. If no explicit rule is found for a pre-requisite, implicit
# rules such as the one below are checked until one is found that matches the
# pre-requisite.
#
# In this case, since none of the object files in $(OBJECTS) have an explict rule,
# they are each matched by the following implicit make rule. One such expansion
# of this implicit rule is:
# 	a.o : a.c
#		gcc -O1 -g -Wall -o a.o -c a.c
#
# Note that this rule and the equivalent rules for .cpp, .s, and other files are
# provided by default with make.
%.o : %.c
	$(CC) $(CFLAGS) -o $@ -c $<

# The .PHONY target is a fake target. All targets that are a pre-requisite of
# the .PHONY target are updated regardless of the status of their pre-requisites.
#
# Rules that specify commands to be run rather than files to be created (such
# as clean, install, test, or default) ought to be declared .PHONY.
.PHONY : clean all test %.test
clean :
	rm -f $(OBJECTS)
	rm -f $(TARGET)
# For more information, see http://www.gnu.org/software/make/manual/make.html

test : $(TESTS)
	@echo "All tests passed."

%.test : %.test-in %.test-cmp $(TARGET)
	@./$(TARGET) <$< 2>/dev/null | \
	diff $(word 2, $?) - || \
	(echo "Test $@ failed" && exit 1)

# 	diff -q $(word 2, $?) - >/dev/null || \