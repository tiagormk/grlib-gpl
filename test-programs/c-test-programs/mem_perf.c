#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LOCALSPM (volatile unsigned int*)0x8f000000u //Scratch pad start address
#define DDRMEM (volatile unsigned int*) 0x50000000u 
#define AHBRAM (volatile unsigned int*) 0xA0000000u 

#define N 2048


void main() {

	int t0, t1;
	float ct_rw_spm, ct_rw_ahbram, ct_rw_ddrmem;
	int i;
	
	int r_char;

	//---Scratchpad---//
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		*(LOCALSPM + i) = 2;
		r_char = *(LOCALSPM + i);
	}
	t1 = (int) clock();
	ct_rw_spm = ((float)(t1 - t0))/(float)N;

	printf("Scratchpad:\n\tAccess medium latency: %.4f\n\tread: %d\n\ttimestamp0: %d\ttimestamp1: %d\n\n", ct_rw_spm, r_char, t0, t1);

	///---AHBRAM write---//
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		*(AHBRAM + i) = 2;
		r_char = *(AHBRAM + i);
	}
	t1 = (int) clock();
	ct_rw_ahbram = ((float)(t1 - t0))/(float)N;

	printf("AHBRAM:\n\tAccess medium latency: %.4f\n\tread: %d\n\ttimestamp0: %d\ttimestamp1: %d\n\n", ct_rw_ahbram, r_char, t0, t1);

	//---DDR write---//
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		*(DDRMEM + i) = 2;
		r_char = *(DDRMEM + i);
	}
	t1 = (int) clock();
	ct_rw_ddrmem = ((float)(t1 - t0))/(float)N;

	printf("RAM:\n\tAccess medium latency: %.4f\n\tread: %d\n\ttimestamp0: %d\ttimestamp1: %d\n\n", ct_rw_ddrmem, r_char, t0, t1);
}