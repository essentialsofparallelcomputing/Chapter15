default:
	supervisorctl status
	service --status-all
	sinfo
	scontrol show partition

#	# create a sample batch script
#	echo '#!/bin/sh' > submit.sh
#	echo 'sleep 30' >> submit.sh
#	echo 'printenv' >> submit.sh
#	chmod +x submit.sh
#	# submit the script
#	sbatch submit.sh
#	sinfo
#	squeue
#	# check output
#	sleep 60
#	cat slurm-*.out
