
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #      
                                                                #
                .data   0x10000000                              #       data starts at address 0x10000000                                               
                                                                #
global_x:       .space  4                                       #       uint32_t x
global_y:       .space  4                                       #       uint32_t y
global_z:       .space  4                                       #       uint32_t z
global_w:       .space  4                                       #       uint32_t w
                                                                #
                .text                                           #
                                                                #       void xorshift_init(a0, a1, a2, a3):
xorshift_init:  sw      $a0,            global_x                #               x = a0
                sw      $a1,            global_y                #               y = a1
                sw      $a2,            global_z                #               z = a2
                sw      $a3,            global_w                #               w = a3
                jr      $ra                                     #               return to ra
                                                                #
                                                                #       uint32_t xorshift():
xorshift:       lw      $t0,            global_x                #               t0 = x1
                sll     $t1,            $t0,            11      #               t1 = t0 << 11
                xor     $t0,            $t0,            $t1     #               t0 = t0 ^ t1
                srl     $t1,            $t1,            8       #               t1 = t1 >> 8
                xor     $t0,            $t0,            $t1     #               t0 = t0 ^ t1
                lw      $t1,            global_y                #               t1 = y
                sw      $t1,            global_x                #               x = t1
                lw      $t1,            global_z                #               t1 = z
                sw      $t1,            global_y                #               y = t1
                lw      $t1,            global_w                #               t1 = w
                sw      $t1,            global_z                #               z = t1
                srl     $t2,            $t1,            19      #               t2 = t1 >> 19
                xor     $t1,            $t1,            $t2     #               t1 = t1 ^ t2
                xor     $t1,            $t1,            $t0     #               t1 = t1 ^ t0
                sw      $t1,            global_w                #               w = t1
                addi    $v0,            $t1,            0       #               v0 = t1
                jr      $ra                                     #               return to ra
                                                                #
                                                                #       void main():
main:           addi    $a0,            $0,             1231    #               a0 = 1231
                addi    $a1,            $0,             6456    #               a1 = 6456
                addi    $a2,            $0,             3453    #               a2 = 3453
                addi    $a3,            $0,             8567    #               a3 = 8567       
                jal     xorshift_init                           #               call xorshift_init
                                                                #
                jal     xorshift                                #               call xorshift
                jal     xorshift                                #               call xorshift
                jal     xorshift                                #               call xorshift
                                                                #                
                addi    $v0,            $0,             10      #               v0 = 10
                syscall                                         #               system call (exit)              
                                                                #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #      
