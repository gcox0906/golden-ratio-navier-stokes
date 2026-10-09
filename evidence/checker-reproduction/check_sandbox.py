import os,socket,subprocess,tempfile,pathlib
root=pathlib.Path('/workspace/comparator')
assert os.geteuid()!=0
print('Unprivileged UID:',os.geteuid())
print('Capabilities:',next(l.strip() for l in pathlib.Path('/proc/self/status').read_text().splitlines() if l.startswith('CapEff:')))
try: socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
except PermissionError: print('AF_UNIX socket creation denied by inherited seccomp filter')
else: raise RuntimeError('AF_UNIX was not blocked')
target=root/'userhome'/'landrun-denial-test.txt'
p=subprocess.run([str(root/'bin/landrun'),'--best-effort','--ro','/','--rox','/usr','--rox','/lib','--rox','/lib64','--','/usr/bin/python3','-c',f'from pathlib import Path; Path({str(target)!r}).write_text("denied")'],capture_output=True,text=True)
print('Landrun filesystem denial exit:',p.returncode)
print(p.stderr)
assert p.returncode!=0 and not target.exists()
print('Filesystem sandbox denial confirmed')
