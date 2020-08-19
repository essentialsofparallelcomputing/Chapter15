default: test AutomaticRestarts Prestart Fortran_Restarts
.PHONY: test AutomaticRestarts Prestart Fortran_Restarts

test:
	# create a sample batch script
	echo '#!/bin/sh' > submit.sh
	echo 'sleep 15' >> submit.sh
	echo 'printenv' >> submit.sh
	chmod +x submit.sh
	# submit the script
	sbatch submit.sh
	sinfo
	# check output
	sleep 20
	cat slurm-*.out

AutomaticRestarts:
	cd AutomaticRestarts && make && sbatch batch_restart.sh

Prestart:
	cd Prestart && make && sbatch batch_restart.sh

Fortran_Restarts:
	cd Fortran_Restarts && make && sbatch batch_restart.sh

clean:
	rm slurm-*.out submit.sh
	cd AutomaticRestarts; make clean
	cd Prestart; make clean
	cd Fortran_Restarts; make clean
