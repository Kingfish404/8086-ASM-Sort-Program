;   @auther :JinYu
;   @blog   :https:\\blog.achacker.com
;   @school :WUT
;   @date   :2020-07-11
data segment
    array db 6,7,9,6,2,4,1,3,5,8        ; 长度为10的未排序数组
    len db 10                           ; 数组长度
    nextLine db 13,10,'$'               ; 换行
    info db 'Enter the choice:',13,10
         db '0.no sort',13,10
         db '1.bubble sort',13,10
         db '2.insert sort',13,10
         db '3.Quick sort',13,10
         db 'enter:$'                   ; 用于提示操作的字符串
    definfo db 'no sort:',13,10,'$'     ; 未排序输出
    bubinfo db 13,10,'bubble sort:',13,10,'$'     ; 冒泡排序输出
    insinfo db 13,10,'insert sort:',13,10,'$'     ; 插入排序输出
    quiinfo db 13,10,'quick sort:',13,10,'$'      ; 快速排序输出
    finalLine db 'Final:',13,10,'$'     ; 最终输出提示
    err db 13,10,'input error$'         ; 输入错误信息  
data ends

stack segment STACK
    ; 此处是为了不让link警告No stack segment
    ; 而添加的stack声明
stack ends

code segment
main proc far
    assume cs:code,ds:data,ss:stack
start:
    push ds     ; 保存原数据段
    xor ax,ax   ; ax寄存器清零
    push ax     ; 数据段0偏移地址压入堆栈中

    mov ax,data ; 把数据段地址装入数据段寄存器ds
    mov ds,ax   

    lea dx,info ; 显示提示信息
    mov ah,9
    int 21h

    mov ah,1    ; 设定dos为接受输入
	int 21h     ; 调用dos中断

    ; 如果输入正常，则用je语句跳转到相应的程序段
    cmp al,'0'      ;
    je default      ; 跳转到直接输出
    cmp al,'1'      ;
    je bubblesort   ; 跳转到冒泡排序
    cmp al,'2'      ;
    je insertsort   ; 跳转到插入排序
    cmp al,'3'      ;
    je toQuicksort  ; 通过toQuicksort接力跳转到快排算法

    ; 未能成功跳转，默认jmp跳转到异常处理
    jmp error

default:
    lea dx,definfo
    mov ah,9
    int 21h

    jmp output

bubblesort:
    lea dx,bubinfo
    mov ah,9
    int 21h

    ;冒泡排序开始
    mov cl,len  ; outloop循环次数
    outloop:    
        mov al,cl ; inloop循环次数
        dec al

        mov ch,al
        mov bx,offset array+1; 数据指针
        inloop:
            mov ah,[bx-1]
            mov al,[bx]

            cmp ah,al
            jl not_change   ; 如果array[bx-1]小于如果array[bx]，则不需要交换

            mov [bx],ah     ; 交换array[bx-1]与array[bx]
            mov [bx-1],al
            not_change:
                inc bx 
                dec ch 
                jnz inloop  ; 内部循环结束
        call printMid
        dec cl
        cmp cl,1
    jnz outloop  ;冒泡排序结束

    jmp output

toQuicksort:    ; je跳转接力
    jmp quicksort

insertsort:
    lea dx,insinfo
    mov ah,9
    int 21h

    ; 插入排序开始
    mov bx,1 ; 用于标记当前查找到的数
    beginIS: ; 插入排序的起点位置
        cmp bx,11
        je output

        call printMid   ; 显示中间值

        mov ah,array[bx]
        cmp ah,array[bx-1]
        jnb toTheNext

    canMov:   ; 当前节点的值小于前面的，可以向前移动
        mov di,bx
        sub di,1
    movBack:  ; 将已经排序的数组向后移动，以便插入
        cmp ah,array[di]
        jnb change
        mov dh,array[di]
        mov array[di+1],dh  ; 后面的向前移动一位

        sub di,1
        cmp di,0
        jb change
        jmp movBack         ; 继续循环移位

    change:   ; a[j+1]=a[j]
        mov array[di+1],ah  

    toTheNext:  ; 跳转到下一点
        inc bx
        jmp beginIS

quicksort:
    lea dx,insinfo
    mov ah,9
    int 21h

    mov si,offset array
    mov di,offset array
    mov bx,offset array

    mov al,len
    xor ah,ah
    add bx,ax
    dec bx

    ; 快速排序开始
    call qsort


    jmp output

error:
    ; 异常信息输出
    lea dx,err
    mov ah,9
    int 21h
    jmp exit

;子程序名:output
;功能:在屏幕上显示最终结果数组数据
;入口：len为数组长度
;出口：输出
output:
    ; 开始输出数组
    lea dx,finalLine
    mov ah,9
    int 21h
    call printMid
    jmp exit

;函数名：qsort
;子程序功能：递归快速排序
;入口：di，bx分别为起始和结束地址
;出口：内存中的数据已排序
qsort proc near
    push di
    push bx
    cmp di,bx
    jnb next
    push di
    push bx

    ; 输出当前数组的值
    call printMid

    call partition

    pop bx
    pop di
    push bx ; 在下次调用qsort时，需要bx的值不变

    mov bx,ax
    dec bx
    push di
    push bx

    call qsort
    pop bx
    pop di
    pop bx ; push bx

    mov di,ax
    inc di
    push di
    push bx

    call qsort

    pop bx
    pop di

    next:
        pop bx
        pop di
        ret
qsort endp

;子程序名:partition
;功能:将数据按枢轴分为两段,进行一趟排序
;入口：di = &r[low], bx=&r[high]
;出口：返回位置在ax
partition proc near
    mov cl,[di]
    ag: 
    cmp di,bx
    jnb tonext
    left: 
        cmp di,bx
        jnb one
        cmp [bx],cl
        jb one
        dec bx
    jmp left
    one:
        mov ch,[bx]
        mov ah,[di]
        mov [di],ch
        mov [bx],ah
    right:
        cmp di,bx
        jnb two
        cmp [di],cl
        ja two
        inc di
    jmp right
    two:
       mov ch,[bx]
       mov ah,[di]
       mov [di],ch
       mov [bx],ah
    jmp ag
    tonext:
        mov ax,di  ;枢轴地址给ax
        ret
partition endp

;子程序名:printMid
;功能:在屏幕上显示当前的的数组数据
;入口：len为数组长度
;出口：输出
printMid proc near
    push cx

    mov si,0
    mov al,len  ; 由于len是db数据,ax是dw数据,db位宽是dw的一半
    xor ah,ah   ; 因此赋值必须特殊处理
    mov cx,ax
    again:
        mov al,array[si]    ; 从数组中读取array[si]
        xor ah,ah
        add al,'0'          ; 求出ASSII的值
        mov dx,ax
        mov ah,02h
        int 21h             ; DOS断点输出

        cmp cx,1
        je finishPrint      ; 如果到最后一个，则跳过逗号

        mov dx,','          
        mov ah,2
        int 21h

        add si,1
    loop again
    finishPrint:
        lea dx,nextLine
        mov ah,9
        int 21h

    pop cx
    ret
printMid endp

exit:
    ret

main endp
code ends
    end start