default: status AutomaticRestarts
.PHONY: status AutomaticRestarts

status:
	supervisorctl status
	service --status-all
	sinfo
	scontrol show partition
	# create a sample batch script
	echo '#!/bin/sh' > submit.sh
	echo 'sleep 15' >> submit.sh
	echo 'printenv' >> submit.sh
	chmod +x submit.sh
	# submit the script
	sbatch submit.sh
	sinfo
	squeue
	# check output
	sleep 20
	cat slurm-*.out

AutomaticRestarts:
	cd AutomaticRestarts && make && sbatch batch_restart.sh
