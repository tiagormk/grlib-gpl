#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LOCALSPM (char*)0x8f000000u //Scratch pad start address
#define DDRMEM (char*) 0x50000000u 
#define AHBRAM (char*) 0xA0000000u 

#define N 16384


void main() {

	int t0, t1;
	float ct_r_spm, ct_r_ahbram, ct_r_ddrmem;
	float ct_w_spm, ct_w_ahbram, ct_w_ddrmem;
	char r_char;
	int i;


	//---Scratchpad write---//
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		*(LOCALSPM + i) = 'A';
	}
	t1 = (int) clock();
	ct_w_spm = ((float)(t1 - t0))/(float)N;

	//---Scratchpad read---//
	
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		r_char = *(LOCALSPM + i) ;
	}
	t1 = (int) clock();
	ct_r_spm = ((float)(t1 - t0))/(float)N;

	printf("Scratchpad:\n\tRead medium latency: %.4f\n\tWrite medium latency: %.4f\n", ct_r_spm, ct_w_spm);

	///---AHBRAM write---//
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		*(AHBRAM+ i) = 'A';
	}
	t1 = (int) clock();
	ct_w_ahbram = ((float)(t1 - t0))/(float)N;

	//---AHBRAM read---//
	
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		r_char = *(AHBRAM+ i);
	}
	t1 = (int) clock();
	ct_r_ahbram = ((float)(t1 - t0))/(float)N;

	printf("AHBRAM:\n\tRead medium latency:: %.4f\n\tWrite medium latency:: %.4f\n", ct_r_ahbram, ct_w_ahbram);

	//---DDR write---//
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		*(DDRMEM+ i) = 'A';
	}
	t1 = (int) clock();
	ct_w_ddrmem = ((float)(t1 - t0))/(float)N;

	//---DDR read---//
	
	t0 = (int) clock();
	for(i = 0; i < N; i++) {
		r_char = *(DDRMEM+ i);
	}
	t1 = (int) clock();
	ct_r_ddrmem = ((float)(t1 - t0))/(float)N;

	printf("RAM:\n\tRead medium latency:: %.4f\n\tWrite medium latency:: %.4f\n", ct_r_ddrmem, ct_w_ddrmem);
}