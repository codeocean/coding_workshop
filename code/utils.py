import base64
import random
import subprocess
from pathlib import Path

# local imports
from co_tools.get_logger import LOGGER


def base64_encode(input_str: str):
    input_bytes = input_str.encode("ascii")
    input_base64_bytes = base64.b64encode(input_bytes)
    return input_base64_bytes.decode("ascii")


def get_random_error_rate():
    return round(random.randrange(1, 125, 1) / 8500, 5)


def get_random_mutation_rate():
    return round(random.randrange(1, 100, 1) / 10000, 5)


def get_genome_fasta(fasta_dir="../data"):
    if (
        fasta := subprocess.check_output(["find", "-L", fasta_dir, "-name", "*.fna"])
        .decode("utf-8")
        .strip()
    ):
        LOGGER.info(f"genome fasta found: {fasta}")
        return fasta
    else:
        return None


def gen_sim_reads(
    num_read_pairs=4000000,
    mutation_rate=get_random_mutation_rate(),
    base_error_rate=get_random_error_rate(),
    fasta=get_genome_fasta(),
    prefix="sim_reads",
):
    subprocess.run(
        [
            "wgsim",
            f"-N{num_read_pairs}",
            f"-r{mutation_rate}",
            f"-e{base_error_rate}",
            fasta,
            f"/scratch/{prefix}_R1.fastq",
            f"/scratch/{prefix}_R2.fastq",
        ]
    )
    LOGGER.info(
        "Simulated reads files generated with the following parameters\n"
        + f"num_read_pairs: {num_read_pairs}\nmutation_rate: {mutation_rate}\n"
        + f"base_error_rate: {base_error_rate}\nfasta: {fasta}\nprefix: {prefix}"
    )
    return None
