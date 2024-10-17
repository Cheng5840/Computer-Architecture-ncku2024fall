#include<stdio.h>  
#include<stdlib.h>  
#include<math.h>  
#include<string.h>  
#include <stdint.h>

long int p, q, n, t, flag, e[100], d[100], temp[100], j, m[100], en[100], i;  
char msg[100];  

int prime(long int);  
void ce();  
long int cd(long int);  
void encrypt();  
void decrypt();  
long int mod_exp(long int base, long int exp, long int mod);  


int main()  
{  
    printf("ENTER FIRST PRIME NUMBER: ");  
    scanf("%ld", &p);  
    flag = prime(p);  
    if (flag == 0 || p == 1)  
    {  
        printf("WRONG INPUT\n");  
        exit(1);  
    }  

    printf("ENTER ANOTHER PRIME NUMBER: ");  
    scanf("%ld", &q);  
    flag = prime(q);  
    if (flag == 0 || q == 1 || p == q)  
    {  
        printf("WRONG INPUT\n");  
        exit(1);  
    }  

    printf("ENTER MESSAGE: ");  
    scanf(" %[^\n]s", msg);  
    for (i = 0; i < strlen(msg); i++)  
        m[i] = msg[i];  

    n = p * q;  
    t = (p - 1) * (q - 1);  

    ce();  

    printf("\nPOSSIBLE VALUES OF e AND d ARE:\n");  
    for (i = 0; i < j - 1; i++)  
        printf("%ld\t%ld\n", e[i], d[i]);  

    encrypt();  
    decrypt();  

    return 0;  
} 
int my_clz(uint32_t x) {
    if (x == 0) return 32;  // special case: all zero

    int count = 0;
    if ((x & 0xFFFF0000) == 0) {  // check 16 bit starts from msb then shift left 16 bit
        count += 16;
        x <<= 16;  
    }
    if ((x & 0xFF000000) == 0) {  // check 8 bits starts from msb
        count += 8;
        x <<= 8;
    }
    if ((x & 0xF0000000) == 0) {  // check 4 bit starts from msb
        count += 4;
        x <<= 4;
    }
    if ((x & 0xC0000000) == 0) {  // check 2 bit starts from msb
        count += 2;
        x <<= 2;
    }
    if ((x & 0x80000000) == 0) {  // check msb
        count += 1;
    }
    return count;
}

int prime(long int pr)  
{  
    int i;  
    if (pr == 1)  
        return 0;  

    for (i = 2; i <= sqrt(pr); i++)  
    {  
        if (pr % i == 0)  
            return 0;  
    }  
    return 1;  
}  

void ce()  
{  
    int k;  
    k = 0;  
    for (i = 2; i < t; i++)  
    {  
        if (t % i == 0)  
            continue;  
        flag = prime(i);  
        if (flag == 1 && i != p && i != q)  
        {  
            e[k] = i;  
            flag = cd(e[k]);  
            if (flag > 0)  
            {  
                d[k] = flag;  
                k++;  
            }  
            if (k == 99)  
                break;  
        }  
    }  
}  

long int cd(long int x)  
{  
    long int k = 1;  
    while (1)  
    {  
        k = k + t;  
        if (k % x == 0)  
            return (k / x);  
    }  
}  

// Modular Exponentiation function using Square-and-Multiply and my_clz
long int mod_exp(long int base, long int exp, long int mod) {
    long int result = 1;
    base = base % mod;

    while (exp > 0) {
        if (exp % 2 == 1) {  // If exp is odd, multiply base with result
            result = (result * base) % mod;
        }
        base = (base * base) % mod;  // Square the base
        exp = exp >> 1;  // Right shift exponent by 1
    }
    return result;
}



// Encrypt Function with Modular Exponentiation
void encrypt()  
{  
    long int pt, ct, key = e[0], len;  
    i = 0;  
    len = strlen(msg);  
    while (i < len)  
    {  
        pt = m[i];  
        pt = pt - 96;  // Adjust to 0-based
        ct = mod_exp(pt, key, n);  // Use modular exponentiation
        temp[i] = ct;  
        ct = ct + 96;  // Adjust back to ASCII value
        en[i] = ct;  
        i++;  
    }  
    en[i] = -1;  
    printf("\nTHE ENCRYPTED MESSAGE IS:\n");  
    for (i = 0; en[i] != -1; i++)  
        printf("%c", (char)en[i]);  
}  

// Decrypt Function with Modular Exponentiation
void decrypt()  
{  
    long int pt, ct, key = d[0];  
    i = 0;  
    while (en[i] != -1)  
    {  
        ct = temp[i];  
        pt = mod_exp(ct, key, n);  // Use modular exponentiation
        pt = pt + 96;  // Adjust back to ASCII value
        m[i] = pt;  
        i++;  
    }  
    m[i] = -1;  
    printf("\nTHE DECRYPTED MESSAGE IS:\n");  
    for (i = 0; m[i] != -1; i++)  
        printf("%c", (char)m[i]);  
}  
