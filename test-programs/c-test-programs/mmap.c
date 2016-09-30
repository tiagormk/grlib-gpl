#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define MAPPED_SIZE 1024
#define DDR_RAM_PHYS  0xA0000000u

int main(int argc, char const *argv[])
{
	int i;
	int _fdmem;
	int *map = NULL;
	const char memDevice[] = "/dev/mem";

	/* open /dev/mem and error checking */
	_fdmem = open( memDevice, O_RDWR | O_SYNC );

	if (_fdmem < 0){
		printf("Failed to open the /dev/mem !\n");
		return 0;
	}
	else{
	printf("open /dev/mem successfully !\n");
	}

	/* mmap() the opened /dev/mem */
	map= (int *)(mmap(0,MAPPED_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,_fdmem,DDR_RAM_PHYS));

	/* use 'map' pointer to access the mapped area! */
    for (i = 0; i < 100; ++i) {
		map[i] = 2 * i; 
    }


	/* unmap the area & error checking */
	if (munmap(map,MAPPED_SIZE)==-1){
	perror("Error un-mmapping the file");
	}

	/* close the character device */
	close(_fdmem);

	return 0;
}
