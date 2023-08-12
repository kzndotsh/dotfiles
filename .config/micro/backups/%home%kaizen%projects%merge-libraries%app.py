import asyncio
import re
import logging
import subprocess

# Configure logging
logging.basicConfig(level=logging.WARNING)
logger = logging.getLogger(__name__)
logging.getLogger().setLevel(logging.INFO)

delay = 10
concurrency_limit = 10  # Adjust this value as needed

# Define the rclone remotes
main_remote = "teamdrive-Movies:/Media/Movies/"
new_remote = "doxie-Movies:/Clone/Doxie-Movies-Staging/M/"
dupes_remote = "kaizen-Dupes:/Doxie-Movies-Dupes/"

# Define additional flags for the rclone command
rclone_flags = [
    "-vP",
    "--fast-list",
    "--drive-server-side-across-configs",
    "--no-update-modtime",
    "--max-backlog=0",
    "--stats=10s",
    "--order-by=modtime,ascending"
]

# Retrieve the list of movies from the main and new remotes
main_movies = subprocess.check_output(
    ["rclone", "lsf", main_remote]).decode("utf-8").splitlines()
new_movies = subprocess.check_output(
    ["rclone", "lsf", new_remote]).decode("utf-8").splitlines()

# Function to extract movie ID from the file name


def extract_movie_id(filename):
    match = re.search(r"\[(tmdb|imdb)-(\w+)\]", filename)
    if match:
        return match.group(2)
    return None


# Create dictionaries to store movie IDs and file paths
main_movie_ids = {}
new_movie_ids = {}

# Populate main movie IDs dictionary
for movie in main_movies:
    movie_id = extract_movie_id(movie)
    if movie_id:
        main_movie_ids[movie_id] = movie

# Semaphore to limit concurrency
semaphore = asyncio.Semaphore(concurrency_limit)

# Function to compare and move duplicate movies


async def compare_and_move(movie):
    async with semaphore:
        movie_id = extract_movie_id(movie)
        if movie_id:
            if movie_id in main_movie_ids:
                # Move duplicate movie to the dupes remote
                await asyncio.create_subprocess_exec(
                    "rclone",
                    "moveto",
                    *rclone_flags,
                    f"{new_remote}{movie}",
                    f"{dupes_remote}{movie}"
                )
                logger.info(f"Moved duplicate movie: {movie}")

                # Remove empty directories from the new remote
                await asyncio.create_subprocess_exec(
                    "rclone",
                    "rmdirs",
                    "--leave-root",
                    f"{new_remote}"
                )
                logger.info("Removed empty directories from new remote.")
            else:
                # Add unique movie to the new movie IDs dictionary
                new_movie_ids[movie_id] = movie

        await asyncio.sleep(delay)


async def main():
    # Create an asyncio task for each movie comparison
    tasks = [compare_and_move(movie) for movie in new_movies]

    # Execute the tasks concurrently
    await asyncio.gather(*tasks)

# Run the main function
asyncio.run(main())
q