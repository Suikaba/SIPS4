//8bit fibonacci
//init
nop(add r0,r0,0)
add r2,r2,1
loop:
out [0],r0
out [1],r1
add r4,r2,r0
jnc skip
add r1,r1,1
skip:
add r5,r3,r1
add r0,r2,0
add r1,r3,0
add r2,r4,0
add r3,r5,0
in r6,[1]
add r6,r6,0
jnz this//halt
jmp loop
