import schedule
import time

def schedule_run():
    while True:
        schedule.run_pending()
        time.sleep(10)