#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

int N_THREADS ;
int N ;
#define MAPPED_SIZE 131072
#define DDR_RAM_PHYS  0xA0000000u

pthread_mutex_t mutex;
/* This is our thread function.  It is like main(), but for a thread */
void *threadFunc(void *arg)
{
	printf("%d\n", sizeof(unsigned long long));
	unsigned long long access_mean_cycles;
	unsigned long long  t0, t1;
	int i;
	int aux;
	int _fdmem;
	int *map = NULL;
	int total_time;
	const char memDevice[] = "/dev/mem";

	/* open /dev/mem and error checking */
	_fdmem = open( memDevice, O_RDWR | O_SYNC );

	if (_fdmem < 0){
		printf("Failed to open the /dev/mem !\n");
		return 0;
	}

	/* mmap() the opened /dev/mem */
	map = (int *)(mmap(0,MAPPED_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,_fdmem,DDR_RAM_PHYS));



	
    for (i = 0, total_time; i < N; ++i) {
    	pthread_mutex_lock(&mutex);
    	t0 = (unsigned long long) clock();
		map[0] = 2; 
		aux = map[0];
		t1 = (unsigned long long) clock();
		pthread_mutex_unlock(&mutex);
		total_time += t1 - t0;
    }
	

    
	access_mean_cycles = ((total_time)*1000)/N;

	printf("\n%s\n\tAccess medium latency: %lld\n\n", (char*) arg,access_mean_cycles);


	/* unmap the area & error checking */
	if (munmap(map,MAPPED_SIZE)==-1){
		perror("Error un-mmapping the file");
	}

	/* close the character device */
	close(_fdmem);
}

int main(int argc, char* argv[])
{
	int i;

	char buf[2][50];
	N_THREADS = atol(argv[1]);
	N = atol(argv[2]);

	pthread_t pth[2];	// this is our thread identifier
	pthread_mutex_init(&mutex, NULL);


	for (i = 0; i < N_THREADS; ++i)
	{
		sprintf(buf[i], "Processing thread %d", i);
		pthread_create(&pth[i], NULL,threadFunc,buf[i]);
	}
	/* Create worker thread */


	/* wait for our thread to finish before continuing */
	for (i = 0; i < N_THREADS; ++i)
	{
		pthread_join(pth[i], NULL /* void ** return value could go here */);
	}


	pthread_mutex_destroy(&mutex);

	return 0;
}