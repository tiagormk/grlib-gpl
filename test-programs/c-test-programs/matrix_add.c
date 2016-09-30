#include <stdio.h>
#include <stdlib.h>

char msg[40] = "Hello from scratchpad!";

int matrix_1[2][2] = {{1, 0}, {0,1}};

void main() {
		
	int matrix_2[2][2] = {{5, 5}, {5,5 }};
	int** matrix_3;
	int i, j;

	printf("%s\n", msg);

	matrix_3 = (int**) malloc(2*sizeof(int*));
	matrix_3[0] = (int*) malloc(2*sizeof(int));
	matrix_3[1] = (int*) malloc(2*sizeof(int));

	for(i = 0; i < 2; i++) {
		for(j = 0; j < 2; j++) {
			matrix_3[i][j] = matrix_1[i][j] + matrix_2[i][j];

			printf("%d    ", matrix_3[i][j]);
		}
		printf("\n");
	}	
	
}
