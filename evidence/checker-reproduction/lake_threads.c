#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
int main(int argc,char **argv) {
  (void)argc;
  if (setenv("LEAN_NUM_THREADS","4",1)) { perror("setenv"); return 2; }
  execv("/workspace/comparator/lean-4.34.0-rc2-linux/bin/lake",argv);
  perror("execv"); return 3;
}
