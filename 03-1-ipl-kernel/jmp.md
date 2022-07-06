Jump if not carry
```
JNC     next                ; No error
```

Jump if above or equal
```
ADD     SI, 1        
CMP     SI, 5
JAE     error               ; if SI >=5, jump to error
```


Jump if below
```
ADD 	DH,1
CMP		DH,2
JB 		readloop		; 如果DH<2，跳转到readloop
```

Jump if below or equal
```
ADD 	CL,1
CMP		CL,18
JB 		readloop		; 如果CL<=18，跳转到readloop
```
