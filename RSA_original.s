    .data
msg:        .string "Jiten"  # start from 0x10000000
msg_len:    .word 8          # length of "Jitendra" is 8
p_val:      .word 5          # p = 5
q_val:      .word 17         # q = 17
n_val:      .word 0          # n = p * q 
phi_val:    .word 0          # φ(n) = (p-1)*(q-1) 
e_val:      .word 0          # Chosen public key exponent 
d_val:      .word 0          #  private key exponent 
temp_res:   .zero 32         # temporary result storage for encrypted message
decrypt_res:.zero 32         # storage for decrypted message

    .text
    .globl main

main:
    # Load the necessary constants into registers
    la a0, msg               # a0 points to the message "Jitendra"
    call strlen              # a0 store the len of string
    
    # count n = p * q 
    lw t0, p_val             # t0 = p
    lw t1, q_val             # t1 = q
    mul t2, t0, t1           # t2 = n = p * q 
    la t3, n_val
    sw t2, 0(t3)          
    
    # count φ(n) = (p - 1) * (q - 1)
    addi t0, t0, -1           # t0 = p - 1
    addi t1, t1, -1           # t1 = q - 1
    mul t4, t0, t1            # t4 = (p - 1) * (q - 1)
    la t3, phi_val            # t3 = address of phi_val
    sw t4, 0(t3)              # store phi_val 
    
    
    # call ce to calculate e and d
    addi t0, t0, 1           # t0 = p
    addi t1, t1, 1           # t1 = q
    lw t2, phi_val           # t0 = phi_val
    call ce
    
    ########################### correct
    
    lw t1, e_val             # t1 = e (public key exponent)
    lw t2, d_val             # t2 = d (private key exponent)
    lw t3, msg_len           # t3 = message length (8 characters)

    # Encrypt the message "Jitendra"
    la a0, msg
    lw a1, n_val
    lw a2, e_val
    lw a3, msg_len
    #la a1, temp_res          # a1 points to the encrypted result storage
    call encrypt_msg         # Call the encryption function

    # End of program
    la t5, temp_res
    li a7, 10                # ecall for exit
    ecall

    # Decrypt the encrypted message
    la a1, decrypt_res       # a1 points to the decryption result storage
    call decrypt_msg         # Call the decryption function

    # End of program
    la t5, temp_res
    lw t6, decrypt_res
    li a7, 10                # ecall for exit
    ecall
    
#############################################################
# Function: strlen
# Description: 計算 null 終止字串的長度
# Parameters:
#   a0 - 字串的起始地址
# Returns:
#   a0 - 字串的長度
#############################################################
strlen:
    li t0, 0                 # t0 為計數器，初始化為 0

strlen_loop:
    lb t1, 0(a0)             # 從地址 a0 加載一個字元到 t1
    beqz t1, strlen_done     # 如果 t1 == 0 (null terminator), 跳轉到 strlen_done
    addi t0, t0, 1           # 計數器 t0 += 1
    addi a0, a0, 1           # 移動到下一個字元
    j strlen_loop            # 跳回 strlen_loop

strlen_done:
    mv a0, t0                # 將結果 (長度) 返回到 a0
    ret                      # 返回到主程序
    

#############################################################
# Function: ce
# Description: calculate the e and d value
# Parameters:
#   t0 - p
#   t1 - q
#   t2 - phi(n)
# Returns:
#   s1 - e 的值
#   s2 - d 的值
#############################################################
ce:
    addi sp, sp, -4         # 將堆疊指針減小，為 ra 騰出空間
    sw ra, 0(sp)            # 將 ra 存入堆疊
    li t3, 2               # t3 = i = 2 (start from i=2)

find_e:
    bge t3, t2, ce_done    # if i >= t, jump to end

    # check if t % i == 0 (t has to be coprime to e)
    rem t4, t2, t3         # t4 = t % i
    beqz t4, next_i        # if t % i == 0，pass current round

    # check if i is prime
    mv a0, t3              # a0 = i ##############################
    call prime             # call prime(i) , a0 will store the result => 1:prime , 0:not prime
    beqz a0, next_i        # if prime(i) == 0，then i is not prime, then pass

    # check if i != p and i != q
    beq t3, t0, next_i     # 如果 i == p, 跳過
    beq t3, t1, next_i     # 如果 i == q, 跳過

    # e = i
    mv s1, t3              # s1 = e = i

    # 計算 d = cd(e)
    mv a0, s1              # a0 = e
    call cd                # 呼叫 cd(e) 函數, a0 will store the result d
    mv s2, a0              # s2 = d (保存私鑰 d)
    j ce_done              # 跳轉到結束

next_i:
    addi t3, t3, 1         # i = i + 1
    j find_e               # 繼續迴圈

cd_found:
    mv s2, a0              # s2 = d (保存私鑰 d)
    j ce_done              # 跳轉到結束

ce_done:
    lw ra, 0(sp)            # 從堆疊中恢復 ra 的值
    addi sp, sp, 4          # 恢復堆疊指針
    ret                    # 返回主程序

#############################################################
# Function: prime
# Description: check if a number is prime
# Parameters:
#   a0 - the number need to be checked
# Returns:
#   a0 - 1:represents the number is prime, 0: not a prime
#############################################################
prime:
    li t0, 2               # t0 = 2
prime_loop:
    mul t1, t0, t0         # t1 = t0 * t0
    bge t1, a0, prime_done # if t0 * t0 >= a0, end check
    rem t1, a0, t0         # t1 = a0 % t0
    beqz t1, not_prime     # if a0 % t0 == 0，the number is not a prime
    addi t0, t0, 1         # t0 += 1
    j prime_loop           # continue next round
prime_done:
    li a0, 1               # prime, return 1
    ret
not_prime:
    li a0, 0               # not a prime, return 0
    ret

#############################################################
# Function: cd
# Description: 計算模逆，返回 d (私鑰)
# Parameters:
#   a0 - e
#   t2 - phi(n)
# Returns:
#   a0 - d (如果存在)，否則返回 0
#############################################################
cd:
    li t0, 1               # t0 = k = 1
cd_loop:
    add t0, t0, t2         # k += t
    rem t1, t0, a0         # t1 = k % e
    beqz t1, cd_done       # 如果 k % e == 0, 則找到 d
    j cd_loop              # 否則繼續迴圈
cd_done:
    div a0, t0, a0         # d = k / e
    ret
    

#############################################################
# Function: encrypt_msg
# Description: Encrypts the message using RSA algorithm
# Parameters:
#   a0 - points to the message (input)
#   t0 - n (modulus)
#   t1 - e (public key exponent)
#   t3 - length of the message
#   a1 - points to the encrypted result (output)
#############################################################
encrypt_msg:
    addi sp, sp, -4         # 將堆疊指針減小，為 ra 騰出空間
    sw ra, 0(sp)            # 將 ra 存入堆疊
    li t4, 0                 # t4: i = 0 (counter)
encrypt_loop:
    bge t4, a3, encrypt_done # if t4 >= message length, exit loop

    lb t5, 0(a0)             # load a character from the message into t5
    addi t5, t5, -40         # convert 'a' to 'z' into 1 to 26 range

    # Calculate ciphertext: C = P^e % n
    mv a2, t5                # Move plaintext character (P) to a2
    mv a3, t1                # Move exponent (e) to a3
    mv a4, t0                # Move modulus (n) to a4
    call mod_exp             # Call modular exponentiation
    mv t6, a0                # Result (C) in a0, move to t6

    sb t6, 0(a1)             # store the encrypted character
    addi a0, a0, 1           # move to the next character in message
    addi a1, a1, 1           # move to the next result storage
    addi t4, t4, 1           # increment counter
    j encrypt_loop

encrypt_done:
    lw ra, 0(sp)            # 從堆疊中恢復 ra 的值
    addi sp, sp, 4          # 恢復堆疊指針
    ret

#############################################################
# Function: decrypt_msg
# Description: Decrypts the encrypted message using RSA algorithm
# Parameters:
#   a1 - points to the encrypted message (input)
#   t0 - n (modulus)
#   t2 - d (private key exponent)
#   t3 - length of the message
#   a1 - points to the decrypted result (output)
#############################################################
decrypt_msg:
    addi sp, sp, -4         # 將堆疊指針減小，為 ra 騰出空間
    sw ra, 0(sp)            # 將 ra 存入堆疊
    li t4, 0                 # t4 = 0 (counter)
decrypt_loop:
    bge t4, t3, decrypt_done # if t4 >= message length, exit loop

    lb t5, 0(a0)             # load an encrypted character into t5

    # Calculate plaintext: P = C^d % n
    mv a2, t5                # Move ciphertext character (C) to a2
    mv a3, t2                # Move exponent (d) to a3
    mv a4, t0                # Move modulus (n) to a4
    call mod_exp             # Call modular exponentiation
    mv t6, a0                # Result (P) in a0, move to t6

    addi t6, t6, 96          # Convert result back to ASCII
    sb t6, 0(a1)             # store the decrypted character
    addi a0, a0, 1           # move to the next encrypted character
    addi a1, a1, 1           # move to the next result storage
    addi t4, t4, 1           # increment counter
    j decrypt_loop

decrypt_done:
    lw ra, 0(sp)            # 從堆疊中恢復 ra 的值
    addi sp, sp, 4          # 恢復堆疊指針
    ret

#############################################################
# Function: mod_exp
# Description: Performs modular exponentiation: a0 = a2^a3 % a4
# Parameters:
#   a2 - base
#   a3 - exponent
#   a4 - modulus
# Returns:
#   a0 - result of (a2^a3) % a4
#############################################################
mod_exp:
    li a0, 1                 # result = 1
mod_exp_loop:
    beqz a3, mod_exp_done    # if exponent == 0, done
    andi t0, a3, 1           # check if the exponent is odd
    beqz t0, mod_exp_square  # if exponent is even, skip multiplication
    mul a0, a0, a2           # result *= base
    rem a0, a0, a4           # result %= modulus
mod_exp_square:
    mul a2, a2, a2           # base = base^2
    rem a2, a2, a4           # base %= modulus
    srai a3, a3, 1           # exponent >>= 1
    j mod_exp_loop           # repeat the loop
mod_exp_done:
    ret
