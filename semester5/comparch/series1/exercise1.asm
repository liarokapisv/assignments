
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
                                                        #   
                .data                                   #
                                                        #
array:          .word   5, 9, 8, 7, 6, 10, 4, 3, 2, 1   #       uint32_t array[10] = {5, 9, 8, 7, 6, 10, 4, 3, 2, 1}
                                                        #
                .text                                   #
                                                        #
                                                        #       void main():
main:           la      $s1,    array                   #               s1 = &array                
                addi    $s3,    $0,     10              #               s3 = 10 // n = 10
                add     $t0,    $zero,  $zero           #               t0 = 0
I_LOOP:         beq     $t0,    $s3,    END             #  I_LOOP:      if t0 == s3 goto END // if (t0 == n) ..
                add     $t1,    $zero,  $zero           #               t1 = 0  
J_LOOP:         sub     $t2,    $s3,    $t0             #               t2 = s3 - t0    
                addi    $t2,    $t2,    -1              #               t2 = t2 - 1
                beq     $t1,    $t2,    NEXT_I          #  J_LOOP:      if t1 == t2 goto NEXT_I // if (t1 == n - t0 - 1) ..
                sll     $t2,    $t1,    2               #               t2 = t1 << 2
                add     $t2,    $t2,    $s1             #               t2 = s1 + t2 
                lw      $t3,    0($t2)                  #               t3 = *((uint32_t*)(t2))   // t3 = array[t1]
                lw      $t4,    4($t2)                  #               t4 = *((uint32_t*)(t2+4)) // t4 = array[t1+1]
                slt     $t5,    $t4,    $t3             #               t5 = t4 < t3
                beq     $t5,    $zero,  NEXT_J          #               if (t5 == 0) goto NEXT_J // if !(t4 < t3) ..
                sw      $t4,    0($t2)                  #               *((uint32_t*)t2) = t4 // array[t1] = array[t1+1]
                sw      $t3,    4($t2)                  #               *((uint32_t*)(t2+1)) = t3 // array[t1+1] = array[t1]
NEXT_J:         addi    $t1,    $t1,    1               #  NEXT_J:      ++t1    
                j       J_LOOP                          #               goto J_LOOP
NEXT_I:         addi    $t0,    $t0,    1               #  NEXT_I:      ++t0
                j       I_LOOP                          #               goto I_LOOP
END:            addi    $v0,    $0,     10              #  END:         v0 = 10
                syscall                                 #               system call (exit)
                                                        #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
