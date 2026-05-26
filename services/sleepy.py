import sys
import time

sleeptime = float(sys.argv[1])
print(f"Time to go to sleep for {sleeptime} seconds...")
time.sleep(sleeptime)
print("Hello, I'm back from my nap.")
