// Ze'ev Binnes 205866163

#include "ex2.h"

/*
In this exercise, we work with a int representation named "magnitude".
The magnitude number is 4 bytes long, the MSB represents the sign,
and the rest of the bytes represent ths value of the number.
(when I say "value", I mean the absolute value).
To seperate the sign and the value, I'll create tow bit masks:
MSB_MASK will give the MSB, and VAL_MASK will give the value.
Using the MSB mask With a & operator will give back the numbers sign,
and using it with a | operator will give the number with a negative sign.
Using thr VAL mask with a & operator will give the absolute value of the number.
*/

#define MSB_MASK 0x80000000     // the MSB is 1, and all the rest are 0.
#define VAL_MASK 0x7fffffff     // the MSB is 0, and all the rest are 1.

int isNegative(magnitude x) {
    return (x & MSB_MASK);
}

// a + b
magnitude add(magnitude a, magnitude b) {
    // av, bv are the absolute values of a, b.
    magnitude av = a & VAL_MASK;
    magnitude bv = b & VAL_MASK;
    // if one number is positive and the other is negative, use the "sub" function.
    if (isNegative(a) && !isNegative(b)) {
        return sub(bv, av);
    } else if (isNegative(b) && !isNegative(a)) {
        return sub(av, bv);
    } else {
        // both have the same sign: sum their values, and keep their sign.
        magnitude x = av + bv;    // x is the value
        if (x == 0) {
            return 0;   // I dont like having any -0.
        }
        if (isNegative(a)) {
            return (x | MSB_MASK);    // return the value and a negative sign.
        } else {
            return (x & VAL_MASK);    // return the value and a positive sign.
        }
        
    }
}

// a - b
magnitude sub(magnitude a, magnitude b) {
    // av, bv are the absolute values of a, b.
    magnitude av = a & VAL_MASK;
    magnitude bv = b & VAL_MASK;
    // if only b is negative, so (a-b)=(a+|b|):
    if (isNegative(b) && !isNegative(a)) {
        return add(a, bv);
    // if only a is negativ, so (a-b)=(-(|a|+b)).
    } else if (isNegative(a) && !isNegative(b)) {
        return (MSB_MASK | add(av, b));
    } else {
        if (av == bv) {
            return 0;   // I dont like having any -0.
        } else if (av > bv) {
            // the original sign should stay.
            return ((av - bv) | (a & MSB_MASK));
        } else {
            // we have to change the original sign.
            return ((bv - av) | ((a & MSB_MASK) ^ MSB_MASK));
        }
    }
}

// a * b
magnitude multi(magnitude a, magnitude b) {
    // av, bv are the absolute values of a, b.
    magnitude av = a & VAL_MASK;
    magnitude bv = b & VAL_MASK;
    magnitude x = ((av * bv) & VAL_MASK);   // x is tha absolute value of av * bv.
    if (x == 0) {
        return 0;
    // if the numbers have the same sign, the product is positive.
    } else if ((isNegative(a) && isNegative(b)) ||
            (!isNegative(a) && !isNegative(b))) {
        return x;
    } else {
        // they have different signes, the prodoct is negative.
        return (x | MSB_MASK);
    }
}

// (a == b) : true = 1, false = 0
int equal(magnitude a, magnitude b) {
    if (a == b) {
        return 1;   // the simple case.
    } else if ((a & VAL_MASK == 0) && (b & VAL_MASK == 0)) {
        return 1;   // because -0 equals 0.
    } else {
        return 0;   // the numbers are different.
    }
}

// (a > b) : true = 1, false = 0
int greater(magnitude a, magnitude b) {
    if (equal(a, b)) {
        return 0;   // if a==b (including 0 and -0) then a>b is false.
    } else if (!(a & MSB_MASK) && (b & MSB_MASK)) {
        return 1;   // a is positive and b is negative, so a>b.
    } else if ((a & MSB_MASK) && !(b & MSB_MASK)) {
        return 0;   // a is negative and b is positive, so b>a
    } else {
        // a and b have the same sign.
        // av, bv are the absolute values of a, b.
        int av = a & VAL_MASK;
        int bv = b & VAL_MASK;
        if (a & MSB_MASK) {
            // they are negative, so the number with the smaller absolute value is actually bigger.
            return (bv > av);   // if (and only if) (bv > av) so (a > b).
        } else {
            // they are positive, so the number with the bigger absolute value is really bigger.
            return (av > bv);   // if (and only if) (av > bv) so (a > b).
        }
    }
}