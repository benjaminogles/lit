
Hello World in C
----------------

This program prints the words "Hello World" to standard output and exits.

First we need to include a header.

```c
#include <stdio.h>
```

Next we define the main function that will be called when the program starts.

```c
int main(void)
{
    // printf always prints to standard output
    printf("Hello World\n");
    return 0;
}
```

C programs must be compiled to machine instructions specific to your processor.

```sh
gcc -o hello_world hello_world.c
```

Now we can run the program and see the output.

```sh
./hello_world
```
```plaintext
Hello World
```
