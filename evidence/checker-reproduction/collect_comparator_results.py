from pathlib import Path
import datetime,hashlib,json,subprocess
r=Path('/workspace/comparator')
repo=r/'repo'
def git(path,*args):
    return subprocess.check_output(['git','-c','safe.directory='+str(path),'-C',str(path),*args],text=True).strip()
config=json.loads((repo/'ComparatorChallenges/NavierStokes.json').read_text())
log=(r/'logs/comparator.log').read_text()
code=int((r/'comparator-exit-code').read_text())
unchanged=int((r/'challenge-unchanged-exit-code').read_text())
signals={s:s in log for s in ['nanoda kernel accepts the solution','Lean default kernel accepts the solution','Your solution is okay!']}
commits={name:git(path,'rev-parse','HEAD') for name,path in {
    'upstream':repo,'Mathlib':repo/'.lake/packages/mathlib',
    'Comparator':repo/'.lake/packages/Comparator','lean4export':repo/'.lake/packages/lean4export',
    'landrun':r/'landrun','nanoda':r/'nanoda'}.items()}
inputs=[]
for p in sorted((repo/'NavierStokes').rglob('*.lean')):
    inputs.append({'source':str(p.relative_to(repo)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
expected=json.loads((r/'comparator-input-sha256.json').read_text())
input_match=all(hashlib.sha256((repo/p).read_bytes()).hexdigest()==h for p,h in expected.items())
bins={'landrun':r/'bin/landrun','nanoda_bin':r/'bin/nanoda_bin',
    'deny-unix':r/'bin/deny-unix','lake-thread-wrapper':r/'bin/lake',
    'comparator':repo/'.lake/packages/Comparator/.lake/build/bin/comparator',
    'lean4export':repo/'.lake/packages/lean4export/.lake/build/bin/lean4export'}
binary_hashes={name:hashlib.sha256(p.read_bytes()).hexdigest() for name,p in bins.items()}
result={'checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'exit_code':code,'challenge_unchanged_exit_code':unchanged,
    'accepted':code==0 and unchanged==0 and input_match and all(signals.values()),
    'success_signals':signals,'configuration':config,'commits':commits,
    'branch':git(repo,'branch','--show-current'),'binary_sha256':binary_hashes,
    'golden_source_hashes':inputs,'verified_golden_inputs_match':input_match,
    'expected_golden_input_sha256':expected,'sandbox':(r/'logs/sandbox-tests.log').read_text(),
    'landlock':(r/'logs/landlock-abi.txt').read_text()}
(r/'logs/comparator-manifest.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['accepted','exit_code','challenge_unchanged_exit_code','success_signals','commits']}))
