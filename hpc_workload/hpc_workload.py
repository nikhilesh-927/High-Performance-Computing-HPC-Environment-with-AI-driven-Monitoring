# hpc_workload.py
import time
import math
import sys

def is_prime(n):
    """A simple function to check if a number is prime."""
    if n <= 1:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python hpc_workload.py <start_num> <end_num>")
        sys.exit(1)

    start_num = int(sys.argv[1])
    end_num = int(sys.argv[2])
    
    print(f"Worker starting: Finding primes between {start_num} and {end_num}.")
    
    prime_count = 0
    start_time = time.time()
    
    for number in range(start_num, end_num + 1):
        if is_prime(number):
            prime_count += 1
            # Add a small delay to make the CPU usage noticeable but not 100% all the time
            time.sleep(0.0001)

    end_time = time.time()
    
    print(f"Worker finished. Found {prime_count} primes in {end_time - start_time:.2f} seconds.")