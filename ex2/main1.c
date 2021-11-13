#include <stdio.h>
#include "ex2.h"

int main()
{
    printf("%d\n", multi(10, 5));
    printf("%d\n", multi(-10, -5));
    printf("%d\n", multi(-10, 5));
    printf("%d\n", multi(10, -5));
    printf("%d\n", multi(0, 0));
    printf("%d\n", multi(0, 5));
    printf("%d\n", multi(10, 0));
    printf("%d\n", multi(9999999999999999, 99999999999999999));

    printf("%d\n", add(-1, 4));
    printf("%d\n", sub(8, -3));
    printf("%d\n", equal(4, 4));
    printf("%d\n", greater(4, 4));
    printf("%d\n", multi(1, add(3, 5)));

    /*
    printf("%d\n", multi(10, 5));
    printf("%d\n", add(-1, 4));
    printf("%d\n", sub(8, -3));
    printf("%d\n", equal(4, 4));
    printf("%d\n", greater(4, 4));
    printf("%d\n", multi(1, add(3, 5)));
    */
}
