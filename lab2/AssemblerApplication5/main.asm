.CSEG               ; 定义代码段（程序存储器）
SENTENCE: 
    .DB 'H', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '.', 0  ; 定义句子

; 主程序段
START:
    LDI R18, 0           ; 初始化单词计数为0
    LDI R17, ' '         ; 初始化前一个字符为空格
    LDI ZH, HIGH(SENTENCE)  ; 设置 Z 寄存器高位为 SENTENCE 地址高位
    LDI ZL, LOW(SENTENCE)   ; 设置 Z 寄存器低位为 SENTENCE 地址低位

LOOP:
    LPM R16, Z+          ; 从程序存储器加载下一个字符 (LPM 从程序存储器中加载)
    
    CPI R16, '.'         ; 检查当前字符是否为句号
    BREQ END             ; 如果是句号，跳出循环
    
    CPI R16, ' '         ; 检查当前字符是否为空格
    BREQ CHECK_WORD      ; 如果是空格，检查前一个字符是否为单词结尾
    
    ; 如果是单词字符
    MOV R17, R16         ; 将当前字符存为前一个字符
    RJMP LOOP            ; 继续循环

CHECK_WORD:
    CPI R17, ' '         ; 检查前一个字符是否为空格
    BREQ LOOP            ; 如果前一个字符为空格，继续循环，不增加计数
    
    INC R18              ; 递增单词计数器
    LDI R17, ' '         ; 设置前一个字符为空格
    RJMP LOOP            ; 继续循环

END:
    STS WORD_COUNT, R18  ; 将单词计数存储到数据存储器中的 WORD_COUNT 位置

WORD_COUNT: .BYTE 1       ; 定义 1 字节的内存用于存储单词数量
