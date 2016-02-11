#include <algorithm>
#include <cctype>
#include <cuda_runtime.h>
#include <inttypes.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/**************************************************************************
 * Calculate time elapsed
 **************************************************************************/
unsigned long get_elapsed(struct timespec *start, struct timespec *end)
{
    uint64_t dur;
    dur = ((uint64_t)end->tv_sec * 1000000000 + end->tv_nsec) - 
        ((uint64_t)start->tv_sec * 1000000000 + start->tv_nsec);
    return (unsigned long)dur;
}//end get_elapsed

/**************************************************************************
 * Encode/Decode Input
 **************************************************************************/
std::string processCipher( std::string input, std::string key, bool encode )
{
    struct timespec tstart, tend;

    clock_gettime(CLOCK_REALTIME, &tstart);

    //take out spaces and change all letters to lowercase
    input.erase( remove_if(input.begin(), input.end(), isspace), input.end() );
    std::transform(input.begin(), input.end(), input.begin(), ::tolower);
    std::transform(key.begin(), key.end(), key.begin(), ::tolower);

    std::string output = input;

    for(int i=0; i<input.length(); i++)
    {
        int keyValue = (int)key[i%key.length()] - 97;
        int textValue = (int)input[i] - 97;

        if(encode)
            output[i] = (char)( ( ( textValue + keyValue ) % 26 ) + 97 );
        else
            output[i] = (char)( ( ( textValue + ( 26 - keyValue ) ) % 26 ) + 97 );//I add so I don't have to deal with absolute values
    }

    clock_gettime(CLOCK_REALTIME, &tend);

    printf("Cipher Processing: %ld usec\n", get_elapsed(&tstart, &tend)/1000);

    return output;
}//end processCipher

/**************************************************************************
 * Run cipher with manual input and key values
 **************************************************************************/
void runCipher(bool encode)
{
    std::string input, output;
    std::string key;

    if(encode)
        std::cout << "Please input the text you wish to encode:" << std::endl;
    else
        std::cout << "Please input the text you wish to decode:" << std::endl;

    std::getline( std::cin, input );

    std::cout << "Please input the key:" << std::endl;
    std::getline( std::cin, key );

    std::cout << "Your cipher text is:" << std::endl;

    output = processCipher(input, key, encode);

    std::cout << output << std::endl;
}//end runCipher

int main(int argc, char **argv)
{
    std::string choice = "encode";
    bool loop = true;

    std::cout<<"Would you like to encode or decode?"<<std::endl;
    std::getline( std::cin, choice );

    while(loop)
    {
        if( choice == "encode")
        {
            runCipher(true);
            loop = false;
        }
        else if( choice == "decode")
        {
            runCipher(false);
            loop = false;
        }
        else
        {
            std::cout << "That is not a valid input, please input either 'encode' or 'decode'" << std::endl;
            std::getline( std::cin, choice );
        }
    }

    return 0;
}//end main