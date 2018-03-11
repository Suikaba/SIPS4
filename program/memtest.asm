nop
loop:
ld r2,[r1]
out [0],r2
st [r1],r0
ld r2,[r1]
out [1],r1
add r1,r1,1
jnz loop:
add r0,r0,1
jmp loop: