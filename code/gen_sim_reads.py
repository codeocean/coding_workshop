import subprocess
import sys
from pathlib import Path

# local imports
import utils
from co_tools import co_fasta, co_utils
from co_tools.get_logger import LOGGER

if fasta := utils.get_genome_fasta():
    utils.gen_sim_reads(fasta=fasta)
    LOGGER.debug(co_utils.get_dir_contents("/scratch"))
else:
    LOGGER.error("Genome fasta not found.")
    sys.exit(1)


# Run the QC, Trimming and repeat QC script
subprocess.run(["bash", "./qc_trim_qc.sh"])
