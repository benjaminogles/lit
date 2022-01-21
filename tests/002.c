
// lit text
// lit author      Author
// lit title       Hello C
// lit description A Hello World Program in C
//
// It is common to introduce people to a new programming language
// by showing them how to print the words "Hello World" to standard
// output. This program achieves that goal using the C programming
// language.
//
// First we need to include a header.
#include <stdio.h>

// lit text
//
// Then we define the main function which will be executed when the
// program starts. It doesn't need to accept any arguments in this
// case so we just write 'void'.
int main(void)
{
    // print to standard output in two ways
    fprintf(stdout, "Hello World\n");
    printf("Hello World\n");
}

// lit text
//
// Running the Program
// -------------------
//
// C programs must be compiled to instructions specific to your processor.
//
// lit run
