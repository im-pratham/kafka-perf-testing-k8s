# -*- coding: utf-8 -*-
"""
@author: im-pratham
"""
import re
import pandas as pd
from pandas import ExcelWriter
import subprocess
import time 

def save_xls(dfs_dict, xls_path):
    with ExcelWriter(xls_path) as writer:
        for n, (name, df) in enumerate(dfs_dict.items()):
            df.to_excel(writer,'%s' % name)
        writer.save()

jobList = ['kafka-single-producer-client', 'kafka-multiple-producer-client']
fileName = 'logs-summary' + int(time.time()) + '.xlsx'

final = {}
for jobName in jobList:
    print("Fetching pods for job: " + jobName)
    jobLabel = "job-name=" + jobName
    
    pods = subprocess.run(["oc", "get", "po", "-o", "custom-columns=POD:.metadata.name", "--no-headers", "-l", jobLabel], stdout=subprocess.PIPE).stdout.decode('utf-8')
    rx = '^(?P<records_sent>\d+) records sent, (?P<records_per_sec>\d+\.\d+) records\/sec \((?P<mb_per_sec>\d+.\d+) MB\/sec\), (?P<ms_avg_lat>\d+.\d+) ms avg latency, (?P<ms_max_lat>\d+.\d+) ms max latency, (?P<ms_50th>\d+) ms 50th, (?P<ms_95th>\d+) ms 95th, (?P<ms_99th>\d+) ms 99th, (?P<ms_99_9th>\d+) ms 99\.9th\.$'
    
    jobResult = []
    for pod in pods.splitlines():
        print("Reading logs of POD: " + pod)
        log = subprocess.run(["oc", "logs", "-f", pod], stdout=subprocess.PIPE).stdout.decode('utf-8')
        for txt in log.splitlines():
            search = re.search(rx, txt)
            if (search): 
                perf = {'pod': pod}
                perf.update(search.groupdict())
                jobResult.append(perf)
        
    result = pd.DataFrame(jobResult)
    final[jobName] = result

print("Writing result to: " + fileName)
save_xls(final, fileName)
