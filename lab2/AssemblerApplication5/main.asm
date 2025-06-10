.CSEG               ; �������Σ�����洢����
SENTENCE: 
    .DB 'H', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '.', 0  ; �������

; �������
START:
    LDI R18, 0           ; ��ʼ�����ʼ���Ϊ0
    LDI R17, ' '         ; ��ʼ��ǰһ���ַ�Ϊ�ո�
    LDI ZH, HIGH(SENTENCE)  ; ���� Z �Ĵ�����λΪ SENTENCE ��ַ��λ
    LDI ZL, LOW(SENTENCE)   ; ���� Z �Ĵ�����λΪ SENTENCE ��ַ��λ

LOOP:
    LPM R16, Z+          ; �ӳ���洢��������һ���ַ� (LPM �ӳ���洢���м���)
    
    CPI R16, '.'         ; ��鵱ǰ�ַ��Ƿ�Ϊ���
    BREQ END             ; ����Ǿ�ţ�����ѭ��
    
    CPI R16, ' '         ; ��鵱ǰ�ַ��Ƿ�Ϊ�ո�
    BREQ CHECK_WORD      ; ����ǿո񣬼��ǰһ���ַ��Ƿ�Ϊ���ʽ�β
    
    ; ����ǵ����ַ�
    MOV R17, R16         ; ����ǰ�ַ���Ϊǰһ���ַ�
    RJMP LOOP            ; ����ѭ��

CHECK_WORD:
    CPI R17, ' '         ; ���ǰһ���ַ��Ƿ�Ϊ�ո�
    BREQ LOOP            ; ���ǰһ���ַ�Ϊ�ո񣬼���ѭ���������Ӽ���
    
    INC R18              ; �������ʼ�����
    LDI R17, ' '         ; ����ǰһ���ַ�Ϊ�ո�
    RJMP LOOP            ; ����ѭ��

END:
    STS WORD_COUNT, R18  ; �����ʼ����洢�����ݴ洢���е� WORD_COUNT λ��

WORD_COUNT: .BYTE 1       ; ���� 1 �ֽڵ��ڴ����ڴ洢��������
