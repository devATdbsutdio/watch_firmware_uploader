import sys
from subprocess import Popen, PIPE, STDOUT

def execute(_cmd):
    output = [] # outputs are going to append to this list
    with Popen(_cmd, stdout=PIPE, stderr=STDOUT, bufsize=1, universal_newlines=True) as p:
        for out in p.stdout:
            output.append(out)
        try:
            for err in p.stderr:
              output.append(err)
        except Exception as e:
            output.append("OK!")
            pass
    return output

