#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <mpi.h>

static int batch_terminate_signal = 0;
static void batch_timeout(int signum){
   batch_terminate_signal = 1;
}

void exit_with_status(int mype, int ival, char *status_string);

int main(int argc, char *argv[])
{
   MPI_Init(&argc, &argv);
   int mype, istart = 0;
   MPI_Comm_rank(MPI_COMM_WORLD, &mype);

   if (argc >=3) istart = atoi(argv[2]);
   // if (istart > 0) read_restart;

   struct sigaction sighdlr;
   sighdlr.sa_handler = batch_timeout;
   if (mype ==0) sigaction(23, &sighdlr, NULL);

   for (int i=istart; i < 10000000; i++){
      sleep(100);

      int terminate_sig = batch_terminate_signal;
      MPI_Bcast(&terminate_sig, 1, MPI_INT, 0, MPI_COMM_WORLD);
      if ( terminate_sig ) {
         // write out restart file
         exit_with_status(mype, i, "RESTART");
      }

      if (i > 10000) exit_with_status(mype, i, "DONE");
   }
}

void exit_with_status(int mype, int ival, char *status_string){
   if (mype == 0){
      time_t tval = time(NULL);
      printf("%d %s: %s", ival, status_string, ctime(&tval));
      FILE *fp = fopen(status_string, "w+");
      fprintf(fp,"%d %s: %s", ival, status_string, ctime(&tval));
      fclose(fp);
   }
   MPI_Finalize();
   exit(0);
}
