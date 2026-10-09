#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/prctl.h>
#include <seccomp.h>
int main(int argc, char **argv) {
  if (argc < 2 || geteuid() == 0) { fprintf(stderr,"Run unprivileged and supply a command.\n"); return 2; }
  if (prctl(PR_SET_NO_NEW_PRIVS,1,0,0,0)) { perror("no_new_privs"); return 3; }
  scmp_filter_ctx ctx=seccomp_init(SCMP_ACT_ALLOW);
  if (!ctx) return 4;
  int err=seccomp_rule_add(ctx,SCMP_ACT_ERRNO(EPERM),SCMP_SYS(socket),1,SCMP_A0(SCMP_CMP_EQ,AF_UNIX));
  if (!err) err=seccomp_rule_add(ctx,SCMP_ACT_ERRNO(EPERM),SCMP_SYS(socketpair),1,SCMP_A0(SCMP_CMP_EQ,AF_UNIX));
  if (!err) err=seccomp_load(ctx);
  seccomp_release(ctx);
  if (err) { fprintf(stderr,"seccomp failed: %d\n",err); return 5; }
  execvp(argv[1],argv+1); perror("execvp"); return 6;
}
