david@edge:~$ export MASTER_KEY=$(openssl rand -hex 32)
david@edge:~$ echo ${MASTER_KEY}
e08906e8935bf2ed1cbad3c923da0fb57622020036ef4de035fb93945b612903
david@edge:~$ export JOIN_KEY=$(openssl rand -hex 32)
david@edge:~$ echo ${JOIN_KEY}
4e763d2563cb2dba0de7220c5f8ed194ae5770b5035a741c36f688b539326900