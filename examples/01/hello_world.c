
// lit author      Author
// lit title       Hello C
// lit description A Hello World Program in C
//
// lit section Writing Hello World in C
//
// It is common to introduce people to a new programming language
// by showing them how to print the words "Hello World" to standard
// output. This program achieves that goal using the C programming
// language.
//
// First we need to include a header.
#include <stdio.h>

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

// lit section Running the Program
//
// C programs must be compiled to instructions specific to your processor.
// We can do that with the commonly available GCC compiler.
//
// lit run gcc -o hello hello_world.c
//
// This will create an executable called hello in the current directory.
// Running the executable will show the expected output.
//
// lit run ./hello
